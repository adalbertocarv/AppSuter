import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/baseUrl_model.dart';
import '../models/paradas_model.dart';

class ParadasService {
  Future<List<Paradas>> procurarParadas() async {
    final url = Uri.parse("${caminhoBackend.baseUrl}/parada");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer kP\$7g@2n!Vx3X#wQ5^z',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['features'] as List)
          .map((feature) => Paradas.fromJson(feature))
          .toList();
    } else {
      throw Exception('Falha para carregar paradas');
    }
  }
}