import 'dart:convert';
import 'package:frontend/models/baseUrl_model.dart';
import 'package:http/http.dart' as http;
import '../models/paradas_novas.dart';

class ParadasFiltradasService {
  static Future<List<ParadaModel>> buscarPorBacia(String nomeBacia) async {
    final url = Uri.parse('http://dados.semob.df.gov.br/pontos/novos/pontos/bacias/${Uri.encodeComponent(nomeBacia)}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ParadaModel.fromJson(json)).toList();
      } else {
        print('Erro ${response.statusCode} ao buscar paradas da bacia: $nomeBacia');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar paradas por bacia: $e');
      return [];
    }
  }

  static Future<List<ParadaModel>> buscarPorRa(String nomeRa) async {
    final url = Uri.parse('${caminhoBackend.baseUrl}/pontos/novos/pontos/ras/${Uri.encodeComponent(nomeRa)}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ParadaModel.fromJson(json)).toList();
      } else {
        print('Erro ${response.statusCode} ao buscar paradas da RA: $nomeRa');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar paradas por RA: $e');
      return [];
    }
  }
}
