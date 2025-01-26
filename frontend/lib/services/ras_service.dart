import 'dart:convert';
import 'package:http/http.dart' as http;

class RAService {
  final String baseUrl = 'http://100.83.163.53:3000'; // Replace with your backend URL
  List<dynamic> features = []; // Cache for RA features

  Future<List<dynamic>> fetchRA() async {
    final response = await http.get(Uri.parse('$baseUrl/ras'));

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
