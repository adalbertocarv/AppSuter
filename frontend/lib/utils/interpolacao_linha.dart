import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/enderecoOSM_service.dart';

final EnderecoService _enderecoService = EnderecoService();

class InterpolacaoLinhaService {
  List<Polyline> polylines = [];
  List<LatLng> consolidatedPoints = [];
  String? enderecoAtual;

  InterpolacaoLinhaService({required this.polylines}) {
    consolidatedPoints = consolidarPontos(polylines);
  }

  /// Consolida pontos das `polylines` recebidas.
  List<LatLng> consolidarPontos(List<Polyline> polylines) {
    List<LatLng> allPoints = [];
    for (var polyline in polylines) {
      allPoints.addAll(polyline.points);
    }
    return allPoints;
  }

  /// Calcula o ponto interpolado mais próximo dentro da linha.
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

  /// Calcula o tamanho total da linha interpolada.
  double tamanhoTotalLinha() {
    double length = 0.0;
    for (int i = 0; i < consolidatedPoints.length - 1; i++) {
      length += const Distance().as(
          LengthUnit.Meter, consolidatedPoints[i], consolidatedPoints[i + 1]);
    }
    return length;
  }

  /// Realiza a interpolação ao longo da linha para encontrar um ponto intermediário.
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

  /// Calcula o ponto projetado sobre uma linha entre dois pontos.
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
}
