import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/percurso_model.dart';
import '../models/base_url.dart';

class PercursoCompletoService {
  /// Consulta a API para obter as linhas e retorna uma linha unificada
  Future<PercursoCompleto> buscarPercursoCompleto(String linha) async {
    final url = Uri.parse('${caminhoBackend.baseUrl}/espaciais/0.380');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer kP\$7g@2n!Vx3X#wQ5^z',  // Adiciona o token de autenticação
          'Content-Type': 'application/json',               // Opcional, mas recomendado
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return PercursoCompleto.fromJsonList(data);
      } else {
        throw Exception('Erro ao buscar linha: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar à API: $e');
    }
  }
}
