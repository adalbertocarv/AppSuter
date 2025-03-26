import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class GeoJsonService {
  /// **Busca e filtra vias próximas da localização do usuário (raio de 50m)**
  Future<List<Polyline>> buscarViasProximas(LatLng userLocation) async {
    try {
      // Lê o arquivo GeoJSON dos assets
      String geojsonStr = await rootBundle.loadString('assets/tab_rede_vias.geojson');
      Map<String, dynamic> geojson = json.decode(geojsonStr);

      List<Polyline> polylines = [];

      if (geojson['type'] == 'FeatureCollection') {
        for (var feature in geojson['features']) {
          if (feature['geometry']['type'] == 'MultiLineString') {
            List<dynamic> coordinates = feature['geometry']['coordinates'];

            for (var linha in coordinates) {
              List<LatLng> pontos = linha.map<LatLng>((coord) {
                return LatLng(coord[1], coord[0]); // Apenas converte array para LatLng
              }).toList();

              // Verifica se pelo menos um ponto da via está dentro do raio de 50m
              bool dentroDoRaio = pontos.any((ponto) {
                return Geolocator.distanceBetween(
                  userLocation.latitude,
                  userLocation.longitude,
                  ponto.latitude,
                  ponto.longitude,
                ) <=
                    50; // Raio de 50 metros
              });

              if (dentroDoRaio) {
                polylines.add(Polyline(
                  points: pontos,
                  strokeWidth: 5.0,
                  color: Colors.blue,
                ));
              }
            }
          }
        }
      }

      return polylines;
    } catch (error) {
      print('Erro ao carregar GeoJSON: $error');
      return [];
    }
  }
}
