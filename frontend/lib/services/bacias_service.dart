import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/baseUrl_model.dart';

class BaciaService {
  List<dynamic> features = []; // Cache para features

  Future<List<dynamic>> buscarBacias() async {
    final response = await http.get(Uri.parse('${caminhoBackend.baseUrl}/bacias'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Access the "features" within "geojson"
      if (data is List && data.isNotEmpty && data[0]['geojson'] != null) {
        features = data[0]['geojson']['features']; // Cache the features
        return features;
      } else {
        throw Exception('Invalid JSON structure or "features" missing.');
      }
    } else {
      throw Exception('Falha para buscar Bacias. Status Code: ${response.statusCode}');
    }
  }
}
