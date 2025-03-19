import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/baseUrl_model.dart';

class PontoParadaService {
  // Método para buscar todas as paradas
  static Future<List<Map<String, dynamic>>> todasAsParadas() async {
    final url = Uri.parse('${caminhoBackend.baseUrl}/paradas');

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception(
            'Erro ao buscar paradas. Código de status: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição GET: $e');
      rethrow;
    }
  }

  // Método para enviar um novo ponto de parada
  static Future<void> enviarPontoParada(Map<String, dynamic> ponto) async {
    final url = Uri.parse('${caminhoBackend.baseUrl}/paradas');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(ponto),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Erro ao enviar ponto de parada. Código de status: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao enviar ponto de parada: $e');
      rethrow;
    }
  }
}
