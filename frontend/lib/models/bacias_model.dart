import 'package:latlong2/latlong.dart';

class Bacia {
  final String type;
  final List<BaciaFeature> features;

  Bacia({
    required this.type,
    required this.features,
  });

  factory Bacia.fromJson(Map<String, dynamic> json) {
    return Bacia(
      type: json['type'],
      features: (json['features'] as List)
          .map((feature) => BaciaFeature.fromJson(feature))
          .toList(),
    );
  }
}

class BaciaFeature {
  final Map<String, dynamic> properties;
  final String geometryType;
  final List<List<LatLng>> coordinates;

  BaciaFeature({
    required this.properties,
    required this.geometryType,
    required this.coordinates,
  });

  factory BaciaFeature.fromJson(Map<String, dynamic> json) {
    return BaciaFeature(
      properties: json['properties'],
      geometryType: json['geometry']['type'],
      coordinates: (json['geometry']['coordinates'] as List)
          .map((polygon) => (polygon as List)
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList())
          .toList(),
    );
  }
}
