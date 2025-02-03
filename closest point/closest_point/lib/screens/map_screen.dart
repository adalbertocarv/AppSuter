import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../service/percurso_service.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<LatLng> polylinePoints = [];
  final List<LatLng> interpolatedPoints = [];
  bool _isLoading = true;  // Indica se os pontos estão sendo carregados

  @override
  void initState() {
    super.initState();
    _buscarPoliline();  // Busca os pontos ao inicializar
  }

  // Método para buscar os pontos da API
  Future<void> _buscarPoliline() async {
    try {
      final PercursoCompletoService service = PercursoCompletoService();
      final percursoCompleto = await service.buscarPercursoCompleto('linha');

      setState(() {
        polylinePoints = percursoCompleto.coordinates;  // Atualiza os pontos da linha
        _isLoading = false;  // Finaliza o carregamento
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar o percurso: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interpolação de Ponto e Linha")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(
          initialCenter: polylinePoints.isNotEmpty
              ? polylinePoints[0]
              : const LatLng(-15.794478, -47.882604),
          initialZoom: 16.0,
          onTap: (tapPosition, point) {
            LatLng pontoInterpolado = acharPontoInterpolado(point);
            print("Ponto interpolado: ${pontoInterpolado.latitude}, ${pontoInterpolado.longitude}");
            setState(() {
              interpolatedPoints.add(pontoInterpolado);
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          if (polylinePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: polylinePoints,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              ],
            ),
          MarkerLayer(
            markers: interpolatedPoints
                .map(
                  (point) => Marker(
                point: point,
                width: 10.0,
                height: 10.0,
                child: const Icon(
                  Icons.brightness_1,
                  color: Colors.red,
                  size: 10,
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (interpolatedPoints.isEmpty) {
            print("Nenhum ponto interpolado foi adicionado.");
          } else {
            print("Pontos interpolados no mapa:");
            for (var point in interpolatedPoints) {
              print("Lat: ${point.latitude}, Lng: ${point.longitude}");
            }
          }
        },
        child: const Icon(Icons.list),
      ),
    );
  }

  LatLng acharPontoInterpolado(LatLng point) {
    double distanciaMin = double.infinity;
    double tamanhoTotal = tamanhoTotalLinha();
    double projecaoMaisProxima = 0.0;

    double accumulatedLength = 0.0;

    for (int i = 0; i < polylinePoints.length - 1; i++) {
      LatLng start = polylinePoints[i];
      LatLng end = polylinePoints[i + 1];

      LatLng projectedPoint = pontoSobreLinha(point, start, end);

      double distancia = const Distance().as(LengthUnit.Meter, point, projectedPoint);

      double segmentLength = const Distance().as(LengthUnit.Meter, start, end);

      if (distancia < distanciaMin) {
        distanciaMin = distancia;
        double projectionFactorOnSegment = const Distance().as(LengthUnit.Meter, start, projectedPoint) / segmentLength;
        projecaoMaisProxima = (accumulatedLength + projectionFactorOnSegment * segmentLength) / tamanhoTotal;
      }

      accumulatedLength += segmentLength;
    }

    return interpolateAlongLine(projecaoMaisProxima);
  }

  LatLng interpolateAlongLine(double factor) {
    double targetDistance = factor * tamanhoTotalLinha();
    double accumulatedDistance = 0.0;

    for (int i = 0; i < polylinePoints.length - 1; i++) {
      LatLng start = polylinePoints[i];
      LatLng end = polylinePoints[i + 1];

      double segmentLength = const Distance().as(LengthUnit.Meter, start, end);

      if (accumulatedDistance + segmentLength >= targetDistance) {
        double segmentFactor = (targetDistance - accumulatedDistance) / segmentLength;
        double interpolatedLat = start.latitude + segmentFactor * (end.latitude - start.latitude);
        double interpolatedLng = start.longitude + segmentFactor * (end.longitude - start.longitude);
        return LatLng(interpolatedLat, interpolatedLng);
      }

      accumulatedDistance += segmentLength;
    }

    return polylinePoints.last;
  }

  double tamanhoTotalLinha() {
    double length = 0.0;
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      length += const Distance().as(LengthUnit.Meter, polylinePoints[i], polylinePoints[i + 1]);
    }
    return length;
  }

  LatLng pontoSobreLinha(LatLng point, LatLng start, LatLng end) {
    final double x1 = start.longitude;
    final double y1 = start.latitude;
    final double x2 = end.longitude;
    final double y2 = end.latitude;
    final double x0 = point.longitude;
    final double y0 = point.latitude;

    final double dx = x2 - x1;
    final double dy = y2 - y1;

    if (dx == 0 && dy == 0) {
      return start;
    }

    double t = ((x0 - x1) * dx + (y0 - y1) * dy) / (dx * dx + dy * dy);
    t = t.clamp(0.0, 1.0);

    double projectedX = x1 + t * dx;
    double projectedY = y1 + t * dy;

    return LatLng(projectedY, projectedX);
  }
}
