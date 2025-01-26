import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'formulario_parada_tela.dart';

class RegistrarParadaTela extends StatefulWidget {
  @override
  _RegistrarParadaTelaState createState() => _RegistrarParadaTelaState();
}

class _RegistrarParadaTelaState extends State<RegistrarParadaTela> {
  LatLng? _selectedPoint; // Armazena o ponto selecionado
  LatLng? _userLocation; // Armazena a localização do usuário
  bool _isLoading = true; // Indica se a localização está sendo carregada
  final MapController _mapController = MapController(); // Controlador do mapa

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Obtém a localização do usuário ao iniciar
  }

  // Método para obter a localização do usuário
  Future<void> _getUserLocation() async {
    try {
      // Verifica se os serviços de localização estão habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, habilite a localização para continuar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Verifica as permissões de localização
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Solicita permissão
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de localização negada.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Se a permissão for negada permanentemente, redirecione para as configurações
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de localização negada permanentemente. Habilite nas configurações.'),
            backgroundColor: Colors.red,
          ),
        );
        // Abre as configurações do app para o usuário habilitar manualmente
        await Geolocator.openAppSettings();
        return;
      }

      // Obtém a localização atual
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter localização: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para centralizar o mapa na localização do usuário
  void _centerMapOnUserLocation() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 17.0); // Move o mapa para a localização do usuário
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização do usuário não disponível.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmPoint() {
    if (_selectedPoint != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormularioParadaTela(
            latLng: _selectedPoint!,
            initialData: {},
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um ponto no mapa!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _userLocation ?? const LatLng(-15.7942, -47.8822),
                zoom: 17.0,
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                onMapEvent: (event) {
                  setState(() {
                    // Atualiza o ponto selecionado baseado na posição central
                    _selectedPoint = _mapController.center;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (_userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLocation!,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          // Alfinete centralizado com offset
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -20), // Move o ícone para cima
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
          ),
          // Botão para confirmar o ponto
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: ElevatedButton(
                        onPressed: _confirmPoint,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text('Confirmar Ponto'),
                      ),
                    ),
                  ),
                ),
                // Botão para centralizar na localização do usuário
                Positioned(
                  top: 16, // Distância do topo
                  right: 16, // Distância da direita
                  child: FloatingActionButton(
                    onPressed: _centerMapOnUserLocation,
                    child: const Icon(Icons.my_location),
                    tooltip: 'Minha localização',
                    backgroundColor: Colors.blue,
                  ),
                ),
        ],
      ),
    );
  }
}