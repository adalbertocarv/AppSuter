import 'dart:convert';
import 'package:frontend/models/baseUrl_model.dart';
import 'package:http/http.dart' as http;
import '../models/ras_model.dart';

class RaService {
  static Future<RaModel?> buscarRaPorNome(String nomeRa) async {
    final url = Uri.parse('${caminhoBackend.baseUrl}/ras/$nomeRa');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RaModel.fromJson(data);
      } else {
        print('Erro ${response.statusCode} ao buscar RA: $nomeRa');
        return null;
      }
    } catch (e) {
      print('Exceção ao buscar RA: $e');
      return null;
    }
  }
}