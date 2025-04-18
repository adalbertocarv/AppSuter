 import 'package:proj4dart/proj4dart.dart';
import 'package:latlong2/latlong.dart';

class ConverterLatLong {
  static final _epsg31983 = Projection.parse(
    '+proj=utm +zone=23 +south +datum=WGS84 +units=m +no_defs',
  );
  static final _epsg4326 = Projection.WGS84;

  // Converter coordenadas EPSG:31983 (UTM) para EPSG:4326 (LatLng)
  static LatLng converterParaLatLng(double x, double y) {
    var utmPoint = Point(x: x, y: y);
    var latLngPoint = _epsg31983.transform(_epsg4326, utmPoint);
    return LatLng(latLngPoint.y, latLngPoint.x); // Retorna LatLng (lat, lon)
  }
}
