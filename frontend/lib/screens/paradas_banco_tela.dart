import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/ponto_parada_provider.dart';

class ParadasBanco extends StatefulWidget {
  @override
  _ParadasBancoState createState() => _ParadasBancoState();
}

class _ParadasBancoState extends State<ParadasBanco> {
  //variáveis
  bool _isLoading = true;
  LatLng? _userLocation;
  bool showSatellite = false; // Estado para alternar sobreposição do satélite
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  // URLs dos tiles
  final String openStreetMapUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  final String esriSatelliteUrl = 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';

//--------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _localizazaoUsuario();
  }

  //LOCALIZACAO DO USUARIO
  Future<void> _localizazaoUsuario() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final pointProvider = Provider.of<PointProvider>(context);
    final paradasTemporarias = pointProvider.points.map((point) {
      return Marker(
          point: LatLng(point['latitude'], point['longitude']),
          child: Transform.translate(
              offset: const Offset(0, -20),
              child: const Icon(
                Icons.location_pin,
                color: Colors.green,
                size: 35,
              ))
      );
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter:
                _userLocation ?? const LatLng(-15.7950, -47.8820),
              initialZoom: 17.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate
              )
            ),
            children: [
              // Camada Base: OpenStreetMap
              TileLayer(
                urlTemplate: openStreetMapUrl,
                userAgentPackageName: 'com.ponto.parada.frontend',
                tileProvider: _tileProvider,
              ),

              // Camada de Satélite: GoogleMaps (Visibilidade controlada)
              if (showSatellite)
                TileLayer(
                  urlTemplate: esriSatelliteUrl,
                  userAgentPackageName: 'com.ponto.parada.frontend',
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
                  ...paradasTemporarias, // Adiciona os markers do provider
                ],
              ),
            ],
          ),
          // Botão para ativar/desativar a sobreposição de satélite
          Positioned(
            top: 60,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  showSatellite = !showSatellite; // Alterna exibição do satélite
                });
              },
              child: Icon(showSatellite ? Icons.map : Icons.satellite),
            ),
          ),
        ],
      ),
    );
  }
}
