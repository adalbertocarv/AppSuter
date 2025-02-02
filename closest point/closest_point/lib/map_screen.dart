import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:turf/turf.dart' as turf;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<LatLng> polylinePoints = [
    const LatLng(-15.794478, -47.882604),
    const LatLng(-15.794422, -47.882602),
    const LatLng(-15.794369, -47.882647),
    const LatLng(-15.794325, -47.882671),
    const LatLng(-15.79406, -47.882584),
    const LatLng(-15.793811, -47.882502),
  ];

  LatLng? markerPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Polyline Marker")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: polylinePoints[0],
          initialZoom: 15.0,
          onTap: (_, point) {
            setState(() {
              markerPosition = getNearestPointOnPolyline(point);
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylinePoints,
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
            ],
          ),
          if (markerPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: markerPosition!,
                  child: const Icon(Icons.location_pin, color: Colors.red),
                ),
              ],
            ),
        ],
      ),
    );
  }

  LatLng getNearestPointOnPolyline(LatLng tapPoint) {
    // Converte os pontos da polyline para posições do tipo turf.Position
    List<turf.Position> linePositions = polylinePoints
        .map((p) => turf.Position(p.longitude, p.latitude))
        .toList();

    // Cria a LineString com as posições
    var lineString = turf.LineString(coordinates: linePositions);

    // Cria um ponto Feature com a posição tocada usando coordinates corretamente
    var tappedPoint = turf.Feature<turf.Point>(
      geometry: turf.Point(coordinates: [tapPoint.longitude, tapPoint.latitude]),
    );

    // Encontra o ponto mais próximo na linha
    var nearestPointFeature = turf.nearestPointOnLine(lineString, tappedPoint as turf.Point);

    // Verifica se o resultado não é nulo e retorna o ponto correto
    if (nearestPointFeature.geometry == null) {
      throw Exception("Coordenadas inválidas retornadas");
    }

    // Extrai as coordenadas do ponto mais próximo
    List<double> nearestCoordinates = nearestPointFeature.geometry!.coordinates! as List<double>;

    // Retorna o ponto mais próximo como LatLng
    return LatLng(nearestCoordinates[1], nearestCoordinates[0]);
  }
}