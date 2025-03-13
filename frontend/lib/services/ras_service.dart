import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/baseUrl_model.dart';

class RAService {
  List<dynamic> features = []; // Cache for RA features

  Future<List<dynamic>> buscarRA() async {
    final response = await http.get(Uri.parse('${caminhoBackend.baseUrl}/ras/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Access the "features" within "geojson"
      if (data is List && data.isNotEmpty && data[0]['geojson'] != null) {
        features = data[0]['geojson']['features']; // Cache the features
        return features;
      } else {
        throw Exception('Estrutura de JSON invalida  ou "features" faltando.');
      }
    } else {
      throw Exception('Falha para buscar RAs. Status Code: ${response.statusCode}');
    }
  }
}
