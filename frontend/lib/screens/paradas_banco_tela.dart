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
import '../utils/EPGS21983_latlong.dart';
import '../widgets/poppup_parada.dart';
import '../models/ras_model.dart';
import '../models/bacias_model.dart';
import '../widgets/ra_seletor_widget.dart';
import '../services/paradas_bacias_ras_service.dart';

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
  final MapController mapController = MapController();
  List<Marker> markersFiltrados = [];
  List<ParadaModel> paradasFiltradas = [];
  final String openStreetMapUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  final String esriSatelliteUrl = 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';

  List<ParadaModel> pontosRemotos = [];
  final PopupController popupController = PopupController();
  RaModel? raSelecionada;
  List<Polygon> raPolygons = [];
  BaciaModel? baciaSelecionada;
  List<Polygon> baciaPolygons = [];

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

  void _atualizarPoligonoDaRa(RaModel? ra) async {
    if (ra == null) {
      setState(() {
        raPolygons = [];
        markersFiltrados = [];
      });
      return;
    }

    final multiPolygon = ra.geoJson['coordinates'];
    final List<Polygon> parsedPolygons = [];

    for (var polygonGroup in multiPolygon) {
      for (var polygon in polygonGroup) {
        final List<LatLng> latLngs = polygon.map<LatLng>((coord) {
          final double x = coord[0];
          final double y = coord[1];
          return ConverterLatLong.converterParaLatLng(x, y);
        }).toList();

        parsedPolygons.add(Polygon(
          points: latLngs,
          color: Colors.blue.withOpacity(0.3),
          borderStrokeWidth: 2,
          borderColor: Colors.blue,
        ));
      }
    }

    final paradas = await ParadasFiltradasService.buscarPorRa(ra.descNome);

    setState(() {
      raSelecionada = ra;
      raPolygons = parsedPolygons;
      markersFiltrados = paradas.map((ponto) {
        return Marker(
          point: LatLng(ponto.latitude, ponto.longitude),
          width: 35,
          height: 35,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 35),
        );
      }).toList();
    });

    if (parsedPolygons.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(parsedPolygons.expand((p) => p.points).toList());
      mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
      );
    }
  }

  void _atualizarPoligonoDaBacia(BaciaModel? bacia) async {
    if (bacia == null) {
      setState(() {
        baciaPolygons = [];
        markersFiltrados = [];
      });
      return;
    }

    final coordinates = bacia.geoJson['coordinates'];
    final List<LatLng> latLngs = coordinates[0].map<LatLng>((coord) {
      final double x = coord[0];
      final double y = coord[1];
      return ConverterLatLong.converterParaLatLng(x, y);
    }).toList();

    final polygon = Polygon(
      points: latLngs,
      color: Colors.orange.withOpacity(0.3),
      borderStrokeWidth: 2,
      borderColor: Colors.orange,
    );

    final paradas = await ParadasFiltradasService.buscarPorBacia(bacia.descBacia);

    setState(() {
      baciaSelecionada = bacia;
      baciaPolygons = [polygon];
      markersFiltrados = paradas.map((ponto) {
        return Marker(
          point: LatLng(ponto.latitude, ponto.longitude),
          width: 35,
          height: 35,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 35),
        );
      }).toList();
    });

    if (latLngs.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(latLngs);
      mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pontoProvider = Provider.of<PontoProvider>(context);
    final paradasTemporarias = pontoProvider.pontos.map((point) {
      return Marker(
        point: LatLng(point.latitude, point.longitude),
        width: 35,
        height: 35,
        child: const Icon(Icons.location_pin, color: Colors.green, size: 35),
      );
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: RaSeletorWidget(
                onBaciaSelecionada: (bacia) {
                  setState(() {
                    raPolygons = [];
                    markersFiltrados = [];
                    paradasFiltradas = [];
                  });
                  _atualizarPoligonoDaBacia(bacia);
                },

                onRaSelecionada: (ra) {
                  setState(() {
                    baciaPolygons = [];
                    markersFiltrados = [];
                    paradasFiltradas = [];
                  });
                  _atualizarPoligonoDaRa(ra);
                },
              ),
            ),
          ),
        ),
      ),
      // body: _isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     :
      body:
      Stack(
        children: [
          FlutterMap(
            mapController: mapController,

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
              if (raPolygons.isNotEmpty)
                PolygonLayer(
                  polygons: raPolygons,
                ),

              if (baciaPolygons.isNotEmpty)
                PolygonLayer(
                  polygons: baciaPolygons,
                ),
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  markers: [...markersFiltrados],
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