import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/EPGS21983_latlong.dart';

class ViaModel {
  final List<Polyline> polylines;

  ViaModel({required this.polylines});

  /// Converte um JSON que pode conter múltiplos `MultiLineString` em polylines
  static ViaModel fromApiResponse(List<dynamic> geojsonList) {
    List<Polyline> allPolylines = [];

    for (var item in geojsonList) {
      if (item['vias_proximas'] != null && item['vias_proximas']['type'] == 'MultiLineString') {
        List<dynamic> coordinates = item['vias_proximas']['coordinates'];

        for (var linha in coordinates) {
          List<LatLng> pontos = [];

          for (var coord in linha) {
            double x = coord[0];
            double y = coord[1];

            // Converte EPSG:31983 para EPSG:4326
            LatLng latLng = ConverterLatLong.converterParaLatLng(x, y);
            pontos.add(latLng);
          }

          allPolylines.add(Polyline(
            points: pontos,
            strokeWidth: 4.0,
            color: Colors.blue,
          ));
        }
      }
    }

    return ViaModel(polylines: allPolylines);
  }
}