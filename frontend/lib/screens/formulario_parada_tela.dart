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
  bool _temHabrigo = false;
  bool _temPatologia = false;
  bool _temAcessibilidade = false;
  bool _transportePublico = false;
  String? _selectedShelterType;
  List<String> _shelterTypes = [];
  List<File> _imageFiles = []; // Armazena múltiplas imagens
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<Map<String, dynamic>> _shelters = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _addressController.text = widget.initialData?['endereco'] ?? '';
      _temHabrigo = widget.initialData?['haAbrigo'] ?? false;
      _temPatologia = widget.initialData?['patologias'] ?? false;
      _temAcessibilidade = widget.initialData?['acessibilidade'] ?? false;
      _transportePublico = widget.initialData?['linhasTransporte'] ?? false;
      _selectedShelterType = widget.initialData?['tipoAbrigo'];

      // Carregar as imagens previamente salvas
      if (widget.initialData?['imagensPaths'] != null) {
        _imageFiles = List<String>.from(widget.initialData?['imagensPaths'] ?? [])
            .map((path) => File(path))
            .toList();
      }
      if (widget.initialData != null && widget.initialData?['abrigos'] != null) {
        _shelters = List<Map<String, dynamic>>.from(widget.initialData?['abrigos']);
      }

    }
    _buscarTiposAbrigos();
  }

  void _addShelter() {
    setState(() {
      _shelters.add({
        "tipoAbrigo": null,
        "temPatologia": false,
        "temAcessibilidade": false
      });
    });
  }

  void _removeShelter(int index) {
    setState(() {
      _shelters.removeAt(index);
    });
  }


  Future<void> _buscarTiposAbrigos() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _shelterTypes = ['Abrigo Tipo C Novo','Abrigo Tipo C', 'Abrigo Tipo Reduzido', 'Abrigo Padrão I', 'Abrigo Padrão II', 'Abrigo tradicional (Niemayer- Sabino Barroso)', 'Abrigo Concretado in loco', 'Abrigo Concreto DER', 'Abrigo Canalete 90', 'Metrobel', 'Abrigo Cemusa 2001', 'Abrigo Cemusa Foste', 'Abrigo Cemusa Grimshaw', 'Abrigo Metálico/Brasileirinho', 'Abrigo Especial (Aeroporto)', 'Abrigo Oval', 'Abrigo Lelé'];
    });
  }

  Future<void> _selecionarMultiplasimagens() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

// Função para capturar uma imagem com a câmera e adicioná-la à lista
  Future<void> _tirarFoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path)); // Adiciona a foto à lista de imagens
      });
    }
  }

  void _removerImagem(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _salvarParada(BuildContext context) {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o campo de endereço!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_temHabrigo && _shelters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um abrigo!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pointProvider = Provider.of<PointProvider>(context, listen: false);

    if (widget.index != null) {
      pointProvider.updatePoint(
        widget.index!,
        endereco: _addressController.text,
        haAbrigo: _temHabrigo,
        abrigos: _shelters, // Passa a lista completa de abrigos
        linhasTransporte: _transportePublico,
        latitude: widget.latLng.latitude,
        longitude: widget.latLng.longitude,
        imagensPaths: _imageFiles.map((file) => file.path).toList(),
      );
    } else {
      pointProvider.addPoint(
        endereco: _addressController.text,
        haAbrigo: _temHabrigo,
        abrigos: _shelters, // Passa a lista completa de abrigos
        linhasTransporte: _transportePublico,
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

    Navigator.of(context).pop();
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
                value: _temHabrigo,
                onChanged: (value) {
                  setState(() {
                    _temHabrigo = value;
                    if (!value) {
                      _selectedShelterType = null;
                      _temPatologia = false;
                      _temAcessibilidade = false;
                    }
                  });
                },
              ),
              if (_temHabrigo) ...[
                const SizedBox(height: 10),
                for (int i = 0; i < _shelters.length; i++) ...[
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _shelters[i]["tipoAbrigo"],
                            hint: const Text('Selecione o tipo de abrigo'),
                            items: _shelterTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type.length > 30 ? '${type.substring(0, 27)}...' : type,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _shelters[i]["tipoAbrigo"] = value;
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
                            value: _shelters[i]["temPatologia"],
                            onChanged: (value) {
                              setState(() {
                                _shelters[i]["temPatologia"] = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Acessibilidade'),
                            value: _shelters[i]["temAcessibilidade"],
                            onChanged: (value) {
                              setState(() {
                                _shelters[i]["temAcessibilidade"] = value;
                              });
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeShelter(i),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addShelter,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Abrigo'),
                  ),
                ),
              ],
              SwitchListTile(
                title: const Text('Linhas de transporte público ou escolar?'),
                value: _transportePublico,
                onChanged: (value) {
                  setState(() {
                    _transportePublico = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                'LatLong do ponto interpolado com rede de vias: ${widget.latLongInterpolado}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Botões lado a lado para selecionar imagens e tirar foto
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150, // Define uma largura fixa para manter uniformidade
                    height: 50, // Mantém altura fixa para ambos os botões
                    child: ElevatedButton.icon(
                      onPressed: _selecionarMultiplasimagens,
                      icon: const Icon(Icons.image),
                      label: const Text('Galeria'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Mantém formato quadrado
                        ),
                        fixedSize: const Size(150, 50), // Garante que ambos os botões tenham o mesmo tamanho
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _tirarFoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Câmera'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fixedSize: const Size(150, 50),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Exibir imagens selecionadas
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
                            onPressed: () => _removerImagem(index),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _salvarParada(context),
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