import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapaViasInterpoladas extends StatefulWidget {
  @override
  _MapaViasInterpoladasState createState() => _MapaViasInterpoladasState();
}

class _MapaViasInterpoladasState extends State<MapaViasInterpoladas> {
  List<Polyline> polylinePoints = [];
  List<LatLng> consolidatedPoints = [];
  LatLng? _ultimoPontoInterpolado;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregarViasComLocalizacaoAtual();
    _iniciarAtualizacaoAutomatica();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarAtualizacaoAutomatica() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _carregarViasComLocalizacaoAtual();
    });
  }

  Future<void> _carregarViasComLocalizacaoAtual() async {
    try {
      Position posicaoAtual = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double latitude = posicaoAtual.latitude;
      double longitude = posicaoAtual.longitude;

      await _carregarViasProximas(latitude, longitude);
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  Future<void> _carregarViasProximas(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'http://localhost:3000/vias/proximas?latitude=$latitude&longitude=$longitude'));

    if (response.statusCode == 200) {
      final geojson = json.decode(response.body);
      setState(() {
        polylinePoints = _converterGeoJsonParaPolylines(geojson);
        consolidatedPoints = _consolidarPontos(polylinePoints);
      });
    } else {
      print('Erro ao carregar vias: ${response.statusCode}');
    }
  }

  List<Polyline> _converterGeoJsonParaPolylines(dynamic geojson) {
    List<Polyline> polylines = [];

    for (var feature in geojson['features']) {
      if (feature['geometry']['type'] == 'MultiLineString') {
        for (var linha in feature['geometry']['coordinates']) {
          List<LatLng> points = [];
          for (var coord in linha) {
            points.add(LatLng(coord[1], coord[0]));
          }
          polylines.add(
            Polyline(
              points: points,
              strokeWidth: 4.0,
              color: Colors.blue,
            ),
          );
        }
      }
    }
    return polylines;
  }

  List<LatLng> _consolidarPontos(List<Polyline> polylines) {
    List<LatLng> allPoints = [];
    for (var polyline in polylines) {
      allPoints.addAll(polyline.points);
    }
    return allPoints;
  }

  double tamanhoTotalLinha() {
    double length = 0.0;
    for (int i = 0; i < consolidatedPoints.length - 1; i++) {
      length += const Distance().as(
          LengthUnit.Meter, consolidatedPoints[i], consolidatedPoints[i + 1]);
    }
    return length;
  }

  LatLng acharPontoInterpolado(LatLng point) {
    double distanciaMin = double.infinity;
    double tamanhoTotal = tamanhoTotalLinha();
    double projecaoMaisProxima = 0.0;
    double accumulatedLength = 0.0;

    for (int i = 0; i < consolidatedPoints.length - 1; i++) {
      LatLng start = consolidatedPoints[i];
      LatLng end = consolidatedPoints[i + 1];

      LatLng projectedPoint = pontoSobreLinha(point, start, end);
      double distancia =
      const Distance().as(LengthUnit.Meter, point, projectedPoint);
      double segmentLength =
      const Distance().as(LengthUnit.Meter, start, end);

      if (distancia < distanciaMin) {
        distanciaMin = distancia;
        double projectionFactorOnSegment =
            const Distance().as(LengthUnit.Meter, start, projectedPoint) /
                segmentLength;
        projecaoMaisProxima =
            (accumulatedLength + projectionFactorOnSegment * segmentLength) /
                tamanhoTotal;
      }
      accumulatedLength += segmentLength;
    }

    return interpolateAlongLine(projecaoMaisProxima);
  }

  LatLng interpolateAlongLine(double factor) {
    double targetDistance = factor * tamanhoTotalLinha();
    double accumulatedDistance = 0.0;

    for (int i = 0; i < consolidatedPoints.length - 1; i++) {
      LatLng start = consolidatedPoints[i];
      LatLng end = consolidatedPoints[i + 1];
      double segmentLength =
      const Distance().as(LengthUnit.Meter, start, end);

      if (accumulatedDistance + segmentLength >= targetDistance) {
        double segmentFactor =
            (targetDistance - accumulatedDistance) / segmentLength;
        double interpolatedLat =
            start.latitude + segmentFactor * (end.latitude - start.latitude);
        double interpolatedLng =
            start.longitude + segmentFactor * (end.longitude - start.longitude);
        return LatLng(interpolatedLat, interpolatedLng);
      }
      accumulatedDistance += segmentLength;
    }

    return consolidatedPoints.last;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa com Interpolação de Vias")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: consolidatedPoints.isNotEmpty
              ? consolidatedPoints[0]
              : const LatLng(-15.830970445232637, -48.043485798151124),
          initialZoom: 16.0,
          onTap: (tapPosition, point) {
            LatLng pontoInterpolado = acharPontoInterpolado(point);
            setState(() {
              _ultimoPontoInterpolado = pontoInterpolado;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Ponto interpolado salvo: ${pontoInterpolado.latitude}, ${pontoInterpolado.longitude}'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          if (polylinePoints.isNotEmpty)
            PolylineLayer(
              polylines: polylinePoints,
            ),
          if (_ultimoPontoInterpolado != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _ultimoPontoInterpolado!,
                  width: 10.0,
                  height: 10.0,
                  child: const Icon(
                    Icons.brightness_1,
                    color: Colors.red,
                    size: 10,
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }
}
