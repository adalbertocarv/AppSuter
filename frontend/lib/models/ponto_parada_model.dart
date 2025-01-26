import 'package:latlong2/latlong.dart';

class Point {
  String? address;
  String? direction;
  String? type;
  bool? isActive;
  LatLng? latLng;
  String? imagePath;

  Point({
    this.address,
    this.direction,
    this.type,
    this.isActive,
    this.latLng,
    this.imagePath,
  });
}
