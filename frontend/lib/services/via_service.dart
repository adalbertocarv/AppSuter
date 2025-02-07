import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/baseUrl_model.dart';
import '../models/via_model.dart';

class ViaService {
  final String _baseUrl = '${caminhoBackend.baseUrl}/vias/proximas';

  Future<ViaModel> buscarViasProximas(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?latitude=$latitude&longitude=$longitude'),
    );

    if (response.statusCode == 200) {
      final geojson = json.decode(response.body);
      return ViaModel.fromGeoJson(geojson);
    } else {
      throw Exception('Erro ao carregar vias: ${response.statusCode}');
    }
  }
}
