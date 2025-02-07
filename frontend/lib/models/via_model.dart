import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ViaModel {
  final List<Polyline> polylines;

  ViaModel({required this.polylines});

  // Converte o GeoJSON para uma lista de polylines
  static ViaModel fromGeoJson(Map<String, dynamic> geojson) {
    List<Polyline> polylines = [];

    for (var feature in geojson['features']) {
      List<LatLng> pontos = [];

      for (var linha in feature['geometry']['coordinates']) {
        for (var coord in linha) {
          pontos.add(LatLng(coord[1], coord[0]));
        }
      }

      polylines.add(Polyline(
        points: pontos,
        strokeWidth: 4.0,
        color: Colors.blue,
      ));
    }

    return ViaModel(polylines: polylines);
  }
}
