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
        // Decodificar a resposta JSON em uma lista de mapas
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        // Lançar uma exceção em caso de erro na requisição
        throw Exception(
            'Erro ao buscar paradas. Código de status: ${response.statusCode}');
      }
    } catch (e) {
      // Tratar exceções
      print('Erro na requisição GET: $e');
      rethrow;
    }
  }
}
