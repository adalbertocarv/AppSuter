import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';

class ParadasTemporarioTela extends StatefulWidget {
  const ParadasTemporarioTela({super.key});

  @override
  _ParadasTemporarioTelaState createState() => _ParadasTemporarioTelaState();
}

class _ParadasTemporarioTelaState extends State<ParadasTemporarioTela> {
  LatLng? _userLocation;
  final MapController _mapController = MapController();
  bool _isLoading = true;

  // Tile provider com cache
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  Future<void> _localizacaoUsuario() async {
    try {
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

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
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

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão negada permanentemente. Habilite nas configurações.'),
            backgroundColor: Colors.red,
          ),
        );
        await Geolocator.openAppSettings();
        return;
      }

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

  void _centralizarLocalizacaoUsuario() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 17.0);
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
    super.initState();
    _localizacaoUsuario();
    Provider.of<PointProvider>(context, listen: false).carregarPontos();
  }

  @override
  Widget build(BuildContext context) {
    final pointProvider = Provider.of<PointProvider>(context);
    final markers = pointProvider.points.map((point) {
      return Marker(
        point: LatLng(point['latitude'], point['longitude']),
      child: Transform.translate(
      offset: const Offset(0, -20),
      child: const Icon(
      Icons.location_pin,
      color: Colors.blue,
      size: 35,
      ))
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Paradas Temporárias', style: TextStyle(color: Colors.white, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                      initialCenter: _userLocation ?? const LatLng(-15.7942, -47.8822),
                      initialZoom: 12.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ponto.parada.frontend',
                        tileProvider: _tileProvider,
                      ),
                      MarkerLayer(
                        markers: [
                          if (_userLocation != null)
                            Marker(
                              point: _userLocation!,
                              width: 50,
                              height: 50,
                              child: Transform.translate(
                                offset: const Offset(0, -22),
                                child: Image.asset(
                                  'assets/images/user_location.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ...markers, // Adiciona os markers do provider
                        ],
                      ),
                    ],
                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}
