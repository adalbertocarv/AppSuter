import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/paradas_novas.dart';
import '../providers/ponto_parada_provider.dart';
import '../services/paradas_bd.dart';
import '../widgets/poppup_parada.dart';

class ParadasBanco extends StatefulWidget {
  @override
  _ParadasBancoState createState() => _ParadasBancoState();
}

class _ParadasBancoState extends State<ParadasBanco> {
  bool _isLoading = true;
  LatLng? _userLocation;
  bool showSatellite = false;
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  final String openStreetMapUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  final String esriSatelliteUrl = 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';

  List<ParadaModel> pontosRemotos = [];
  final PopupController popupController = PopupController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _localizarUsuario();
    try {
      final dados = await PontoParadaRemoteService.buscarPontos();
      if (mounted) {
        setState(() {
          pontosRemotos = dados;
        });
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _localizarUsuario() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) return;
      Position position = await Geolocator.getCurrentPosition();
      _userLocation = LatLng(position.latitude, position.longitude);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final pointProvider = Provider.of<PointProvider>(context);
    final paradasTemporarias = pointProvider.points.map((point) {
      return Marker(
        point: LatLng(point['latitude'], point['longitude']),
        width: 35,
        height: 35,
        child: const Icon(Icons.location_pin, color: Colors.green, size: 35),
      );
    }).toList();

    final markersRemotos = pontosRemotos.map((ponto) {
      return Marker(
        point: LatLng(ponto.latitude, ponto.longitude),
        width: 35,
        height: 35,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 35),
      );
    }).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _userLocation ?? const LatLng(-15.7942, -47.8822),
              initialZoom: 17.0,
              onTap: (_, __) => popupController.hideAllPopups(),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: openStreetMapUrl,
                userAgentPackageName: 'com.ponto.parada.frontend',
                tileProvider: _tileProvider,
              ),
              if (showSatellite)
                TileLayer(
                  urlTemplate: esriSatelliteUrl,
                  userAgentPackageName: 'com.ponto.parada.frontend',
                ),
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  markers: [...markersRemotos, ...paradasTemporarias],
                  popupController: popupController,
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (BuildContext context, Marker marker) {
                      final ponto = pontosRemotos.firstWhere(
                            (p) =>
                        p.latitude == marker.point.latitude &&
                            p.longitude == marker.point.longitude,
                        orElse: () => ParadaModel.empty(),
                      );

                      if (ponto == null) return const SizedBox.shrink();
                      return PopupPontoParada(
                        pontoParada: ponto,
                        popupController: popupController,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 60,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  showSatellite = !showSatellite;
                });
              },
              child: Icon(showSatellite ? Icons.map : Icons.satellite),
            ),
          ),

          Positioned
            (
              top: 60,
              left: 16,
              child: FloatingActionButton(
          onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back_ios_new),
              tooltip: 'Voltar',
    )
          )],
      ),
    );
  }
}
