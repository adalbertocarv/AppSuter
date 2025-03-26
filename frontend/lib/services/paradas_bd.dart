import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/paradas_novas.dart';

class PontoParadaRemoteService {
  static Future<List<ParadaModel>> buscarPontos() async {
    final url = Uri.parse('http://100.77.74.55:3003/pontos/novos/pontos');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((json) => ParadaModel.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar pontos. Código: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}
