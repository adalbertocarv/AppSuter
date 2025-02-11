import 'package:latlong2/latlong.dart';

class PercursoCompleto {
  final String numero;
  final String sentido;
  final List<LatLng> coordinates;

  PercursoCompleto({
    required this.numero,
    required this.sentido,
    required this.coordinates,
  });

  /// Cria um objeto `PercursoCompleto` a partir de uma lista de JSON
  factory PercursoCompleto.fromJsonList(List<dynamic> jsonList) {
    if (jsonList.isEmpty) {
      throw ArgumentError('A lista de percursos está vazia.');
    }

    // Tenta obter a linha de IDA
    final Map<String, dynamic>? linhaIda =
    jsonList.isNotEmpty ? jsonList[0] as Map<String, dynamic>? : null;

    // Tenta obter a linha de VOLTA, se existir
    final Map<String, dynamic>? linhaVolta =
    jsonList.length > 1 ? jsonList[1] as Map<String, dynamic>? : null;

    // Obtém o número da linha (ou um valor padrão se não estiver disponível)
    final String numero = linhaIda?['Numero'] ?? 'Desconhecido';

    // Determina o sentido do percurso (IDA/VOLTA ou CIRCULAR)
    String sentido = 'CIRCULAR';
    if (linhaIda != null && linhaVolta != null) {
      sentido = 'IDA/VOLTA';
    } else if (linhaIda != null) {
      sentido = linhaIda['Sentido'] ?? 'Desconhecido';
    }

    // Obter as coordenadas de IDA e VOLTA com proteção contra `null`
    final List<LatLng> coordinates = [
      ..._parseCoordinates(linhaIda?['GeoLinhas']?['coordinates']),
      ..._parseCoordinates(linhaVolta?['GeoLinhas']?['coordinates']),
    ];

    return PercursoCompleto(
      numero: numero,
      sentido: sentido,
      coordinates: coordinates,
    );
  }

  /// Método auxiliar para converter coordenadas, ignorando valores nulos
  static List<LatLng> _parseCoordinates(List<dynamic>? rawCoordinates) {
    if (rawCoordinates == null) return [];

    return rawCoordinates
        .map((c) {
      if (c.length >= 2 && c[0] != null && c[1] != null) {
        return LatLng(c[1].toDouble(), c[0].toDouble());
      }
      return null;
    })
        .whereType<LatLng>()  // Remove valores nulos
        .toList();
  }

  /// Converte o objeto `PercursoCompleto` em um JSON (para envio ou armazenamento)
  Map<String, dynamic> toJson() {
    return {
      "numero": numero,
      "sentido": sentido,
      "type": "LineString",
      "coordinates": coordinates.map((c) => [c.longitude, c.latitude]).toList(),
    };
  }
}
