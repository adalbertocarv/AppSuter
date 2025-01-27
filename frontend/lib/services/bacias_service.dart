import 'dart:convert';
import 'package:http/http.dart' as http;

class BaciaService {
  final String baseUrl = 'http://100.83.163.53:3000'; // Altere para seu endpoint
  List<dynamic> features = []; // Cache for features

  Future<List<dynamic>> buscarBacias() async {
    final response = await http.get(Uri.parse('$baseUrl/bacias'));

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
      throw Exception('alha para buscar Bacias. Status Code: ${response.statusCode}');
    }
  }
}
