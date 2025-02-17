import 'package:latlong2/latlong.dart';

class Paradas {
  final LatLng point;
  final String codDftrans;

  Paradas({required this.point, required this.codDftrans});

  factory Paradas.fromJson(Map<String, dynamic> json) {
    return Paradas(
      point: LatLng(json['geometry']['coordinates'][1], json['geometry']['coordinates'][0]),
      codDftrans: json['properties']['codDftrans'],
    );
  }
}