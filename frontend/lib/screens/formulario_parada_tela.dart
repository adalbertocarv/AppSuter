import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/tela_inicio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';


class FormularioParadaTela extends StatefulWidget {
  final LatLng latLng;
  final String latLongInterpolado;
  final Map<String, dynamic>? initialData;
  final int? index; // Para identificar se é uma edição

  FormularioParadaTela({
    required this.latLng,
    required this.latLongInterpolado,
    this.initialData,
    this.index,
  });

  @override
  _FormularioParadaTelaState createState() => _FormularioParadaTelaState();
}

class _FormularioParadaTelaState extends State<FormularioParadaTela> {
  final TextEditingController _addressController = TextEditingController();
  bool _hasShelter = false;
  bool _hasPathologies = false;
  bool _hasAccessibility = false;
  bool _isPublicTransport = false;
  bool _isActive = false;
  String? _selectedShelterType;
  List<String> _shelterTypes = [];
  List<File> _imageFiles = []; // Armazena múltiplas imagens
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _addressController.text = widget.initialData?['endereco'] ?? '';
      _hasShelter = widget.initialData?['haAbrigo'] ?? false;
      _hasPathologies = widget.initialData?['patologias'] ?? false;
      _hasAccessibility = widget.initialData?['acessibilidade'] ?? false;
      _isPublicTransport = widget.initialData?['linhasTransporte'] ?? false;
      _isActive = widget.initialData?['ativo'] ?? false;
      _selectedShelterType = widget.initialData?['tipoAbrigo'];

      // Carregar as imagens previamente salvas
      if (widget.initialData?['imagensPaths'] != null) {
        _imageFiles = List<String>.from(widget.initialData?['imagensPaths'] ?? [])
            .map((path) => File(path))
            .toList();
      }
    }
    _fetchShelterTypes();
  }

  Future<void> _fetchShelterTypes() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _shelterTypes = ['Abrigo Tipo II', 'Abrigo Tipo C Novo', 'Abrigo Tipo Reduzido'];
    });
  }

  Future<void> _selectMultipleImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _saveParada(BuildContext context) {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o campo de endereço!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hasShelter && _selectedShelterType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione o tipo de abrigo!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pointProvider = Provider.of<PointProvider>(context, listen: false);

    if (widget.index != null) {
      // Atualiza a parada existente
      pointProvider.updatePoint(
        widget.index!,
        endereco: _addressController.text,
        haAbrigo: _hasShelter,
        tipoAbrigo: _selectedShelterType,
        patologias: _hasPathologies,
        acessibilidade: _hasAccessibility,
        linhasTransporte: _isPublicTransport,
        ativo: _isActive,
        latitude: widget.latLng.latitude,
        longitude: widget.latLng.longitude,
        imagensPaths: _imageFiles.map((file) => file.path).toList(),
      );
    } else {
      // Cria uma nova parada
      pointProvider.addPoint(
        endereco: _addressController.text,
        haAbrigo: _hasShelter,
        tipoAbrigo: _selectedShelterType,
        patologias: _hasPathologies,
        acessibilidade: _hasAccessibility,
        linhasTransporte: _isPublicTransport,
        ativo: _isActive,
        latitude: widget.latLng.latitude,
        longitude: widget.latLng.longitude,
        latLongInterpolado: widget.latLongInterpolado,
        imagensPaths: _imageFiles.map((file) => file.path).toList(),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Parada salva com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();  // Retorna à tela anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulário da Parada')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coordenadas Selecionadas: ${widget.latLng.latitude}, ${widget.latLng.longitude}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Há abrigo?'),
                value: _hasShelter,
                onChanged: (value) {
                  setState(() {
                    _hasShelter = value;
                    if (!value) {
                      _selectedShelterType = null;
                      _hasPathologies = false;
                      _hasAccessibility = false;
                    }
                  });
                },
              ),
              if (_hasShelter) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedShelterType,
                  hint: const Text('Selecione o tipo de abrigo'),
                  items: _shelterTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedShelterType = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Abrigo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Patologias'),
                  value: _hasPathologies,
                  onChanged: (value) {
                    setState(() {
                      _hasPathologies = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Acessibilidade'),
                  value: _hasAccessibility,
                  onChanged: (value) {
                    setState(() {
                      _hasAccessibility = value;
                    });
                  },
                ),
              ],
              SwitchListTile(
                title: const Text('Linhas de transporte público ou escolar?'),
                value: _isPublicTransport,
                onChanged: (value) {
                  setState(() {
                    _isPublicTransport = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Ativo'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                'LatLong do ponto interpolado com rede de vias: ${widget.latLongInterpolado}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: _selectMultipleImages,
                icon: const Icon(Icons.image),
                label: const Text('Selecionar Imagens'),
              )),
              const SizedBox(height: 10),
              if (_imageFiles.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Image.file(
                          _imageFiles[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _saveParada(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Salvar Parada'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}