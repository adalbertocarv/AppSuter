import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/baseUrl_model.dart';

class PontoParadaService {
  /// Obter o token JWT armazenado no SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Envia os dados de um ponto ao backend
  static Future<bool> criarPonto({
    required String endereco,
    required bool haAbrigo,
    required bool linhasTransporte,
    required double longitude,
    required double latitude,
    required String latLongInterpolado,
    required List<String> imagensPaths,
    required List<Map<String, dynamic>> abrigos, // ✅ Adicionado o parâmetro `abrigos`
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('Token de autenticação não encontrado.');
        return false;
      }

      final url = Uri.parse('${caminhoBackend.baseUrl}/paradas');
      final request = http.MultipartRequest('POST', url);

      // 🔹 Adicionar os campos normais
      request.fields['endereco'] = endereco;
      request.fields['haAbrigo'] = haAbrigo.toString();
      request.fields['linhasTransporte'] = linhasTransporte.toString();
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['latLongInterpolado'] = latLongInterpolado;
      request.fields['abrigos'] = jsonEncode(abrigos); 

      // 🔹 Adicionar imagens corretamente com o nome esperado pelo backend ('imagens')
      for (String imagePath in imagensPaths) {
        request.files.add(await http.MultipartFile.fromPath('imagens', imagePath));
      }

      request.headers['Authorization'] = 'Bearer $token'; // Adiciona o token no cabeçalho

      final response = await request.send();
      if (response.statusCode == 201) {
        print('Ponto criado com sucesso!');
        return true;
      } else {
        print('Erro ao criar o ponto: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Erro na criação do ponto: $error');
      return false;
    }
  }
}
