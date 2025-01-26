import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/registro_tela.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';

class FormularioParadaTela extends StatefulWidget {
  final LatLng latLng;

  FormularioParadaTela({required this.latLng});

  @override
  _FormularioParadaTelaState createState() => _FormularioParadaTelaState();
}

class _FormularioParadaTelaState extends State<FormularioParadaTela> {
  final _addressController = TextEditingController();
  final _directionController = TextEditingController();
  final _typeController = TextEditingController();
  bool _isActive = false;
  File? _imageFile; // File for storing the selected or captured image

  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Function to capture an image with the camera
  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveParada(BuildContext context) {
    final pointProvider = Provider.of<PointProvider>(context, listen: false);

    // Adiciona a parada no provider
    pointProvider.addPoint(
      address: _addressController.text,
      direction: _directionController.text,
      type: _typeController.text,
      isActive: _isActive,
      latLng: widget.latLng,
      imagePath: _imageFile?.path,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Parada salva temporariamente!'),
        backgroundColor: Colors.green,
      ),
    );

    // Opcionalmente, resetar o formulário
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('Galeria'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _captureImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveParada(context),
                child: const Text('Salvar Parada'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => RegistroTela()),
                  );
                },
                child: const Text('Ver Paradas Temporárias'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
