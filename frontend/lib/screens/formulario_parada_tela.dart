import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/tela_inicio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';

class FormularioParadaTela extends StatefulWidget {
  final LatLng latLng;
  final Map<String, dynamic>? initialData; // Propriedade para edição

  FormularioParadaTela({required this.latLng, this.initialData});

  @override
  _FormularioParadaTelaState createState() => _FormularioParadaTelaState();
}

class _FormularioParadaTelaState extends State<FormularioParadaTela> {
  // Inicializa os controladores com base nos dados existentes ou valores padrão
  late final TextEditingController _addressController =
  TextEditingController(text: widget.initialData?['endereco'] ?? '');
  late final TextEditingController _directionController =
  TextEditingController(text: widget.initialData?['sentido'] ?? '');
  late final TextEditingController _typeController =
  TextEditingController(text: widget.initialData?['tipo'] ?? '');
  late bool _isActive = widget.initialData?['ativo'] ?? false;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  // Função para selecionar uma imagem da galeria
  Future<void> _selecionaImagem() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Função para capturar uma imagem com a câmera
  Future<void> _tirarFoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Salvar a parada usando o provider
  void _savarParada(BuildContext context) {
    final pointProvider = Provider.of<PointProvider>(context, listen: false);

    // Validar os campos obrigatórios
    if (_addressController.text.isEmpty ||
        _directionController.text.isEmpty ||
        _typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Adicionar a parada no provider
    pointProvider.addPoint(
      endereco: _addressController.text,
      sentido: _directionController.text,
      tipo: _typeController.text,
      longitude: widget.latLng.longitude,
      latitude: widget.latLng.latitude,
      ativo: _isActive,
      imagemPath: _imageFile?.path,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Parada salva temporariamente!'),
        backgroundColor: Colors.green,
      ),
    );

    // Resetar o formulário
    _addressController.clear();
    _directionController.clear();
    _typeController.clear();
    setState(() {
      _isActive = false;
      _imageFile = null;
    });
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
              TextField(
                controller: _directionController,
                decoration: const InputDecoration(labelText: 'Sentido'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Ativo'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              _imageFile != null
                  ? Image.file(
                _imageFile!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : const Text(
                'Nenhuma imagem selecionada',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centraliza os botões na linha
                  children: [
                    IntrinsicWidth(
                      child: ElevatedButton.icon(
                        onPressed: _selecionaImagem,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        icon: const Icon(Icons.photo),
                        label: const Text('Galeria'),
                      ),
                    ),
                    const SizedBox(width: 10), // Espaço entre os botões
                    IntrinsicWidth(
                      child: ElevatedButton.icon(
                        onPressed: _tirarFoto,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Câmera'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: IntrinsicWidth(
                  child: ElevatedButton(
                    onPressed: () {
                      // Validar os campos obrigatórios
                      if (_addressController.text.isEmpty ||
                          _directionController.text.isEmpty ||
                          _typeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, preencha todos os campos obrigatórios!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Não navega para a próxima tela
                      }

                      // Salva a parada e navega para RegistroTela
                      _savarParada(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => TelaInicio()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text('Salvar Parada'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
