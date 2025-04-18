import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bacias_model.dart';
import '../models/baseUrl_model.dart';

class BaciaService {
  static Future<BaciaModel?> buscarBaciaPorNome(String nomeBacia) async {
    final url = Uri.parse('${caminhoBackend.baseUrl}/bacias/$nomeBacia');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BaciaModel.fromJson(data);
      } else {
        print('Erro ${response.statusCode} ao buscar Bacia: $nomeBacia');
        return null;
      }
    } catch (e) {
      print('Exceção ao buscar Bacia: $e');
      return null;
    }
  }
}
