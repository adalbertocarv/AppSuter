import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<LatLng> polylinePoints = [
    LatLng(-15.794478, -47.882604),
    LatLng(-15.794422, -47.882602),
    LatLng(-15.794369, -47.882647),
    LatLng(-15.794325, -47.882671),
    LatLng(-15.79406, -47.882584),
    LatLng(-15.793811, -47.882502),
  ];

  final List<LatLng> interpolatedPoints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interpolação de Ponto e Linha")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-15.794478, -47.882604),
          initialZoom: 19.0,
          onTap: (tapPosition, point) {
            LatLng interpolatedPoint = findInterpolatedPoint(point);
            print("Ponto interpolado: ${interpolatedPoint.latitude}, ${interpolatedPoint.longitude}");
            setState(() {
              interpolatedPoints.add(interpolatedPoint);
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
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
                child: const Icon(Icons.my_location, color: Colors.red, size: 20),
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

  LatLng findInterpolatedPoint(LatLng point) {
    double minDistance = double.infinity;
    double totalLength = totalLineLength();
    double closestProjectionFactor = 0.0;

    double accumulatedLength = 0.0;

    for (int i = 0; i < polylinePoints.length - 1; i++) {
      LatLng start = polylinePoints[i];
      LatLng end = polylinePoints[i + 1];

      LatLng projectedPoint = projectPointOntoSegment(point, start, end);

      double distance = const Distance().as(LengthUnit.Meter, point, projectedPoint);

      double segmentLength = const Distance().as(LengthUnit.Meter, start, end);

      if (distance < minDistance) {
        minDistance = distance;
        double projectionFactorOnSegment = const Distance().as(LengthUnit.Meter, start, projectedPoint) / segmentLength;
        closestProjectionFactor = (accumulatedLength + projectionFactorOnSegment * segmentLength) / totalLength;
      }

      accumulatedLength += segmentLength;
    }

    return interpolateAlongLine(closestProjectionFactor);
  }

  LatLng interpolateAlongLine(double factor) {
    double targetDistance = factor * totalLineLength();
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

  double totalLineLength() {
    double length = 0.0;
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      length += const Distance().as(LengthUnit.Meter, polylinePoints[i], polylinePoints[i + 1]);
    }
    return length;
  }

  LatLng projectPointOntoSegment(LatLng point, LatLng start, LatLng end) {
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
