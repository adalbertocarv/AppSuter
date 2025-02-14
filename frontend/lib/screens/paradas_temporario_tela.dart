import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ParadasTemporarioTela extends StatefulWidget {
  const ParadasTemporarioTela({super.key});

  @override
  _ParadasTemporarioTelaState createState() => _ParadasTemporarioTelaState();
}

class _ParadasTemporarioTelaState extends State<ParadasTemporarioTela> {
  LatLng? _userLocation;
  final MapController _mapController = MapController(); // Controlador do mapa
  bool _isLoading = true;

  // Adiciona o tile provider com cache
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  Future<void> _localizacaoUsuario() async {
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
            content: Text(
                'Permissão de localização negada permanentemente. Habilite nas configurações.'),
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
  void _centralizarLocalizacaoUsuario() {
    if (_userLocation != null) {
      _mapController.move(
          _userLocation!, 17.0); // Move o mapa para a localização do usuário
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização do usuário não disponível.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    _localizacaoUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Paradas Temporárias'),
        ),
        body: Column(
          children: [
            Expanded(
                child: Stack(
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter:
                            _userLocation ?? const LatLng(-15.7942, -47.8822),
                        initialZoom: 12.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.ponto.parada.frontend',
                          tileProvider: _tileProvider,
                        ),
                        MarkerLayer(
                          markers: [
                            if (_userLocation != null)
                              Marker(
                                point: _userLocation!,
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              )
                          ],
                        )
                      ]),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _centralizarLocalizacaoUsuario,
                    child: const Icon(Icons.my_location),
                    tooltip: 'Minha localização',
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ))
          ],
        ),
      );
  }
}
