import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PontoParadaService {
  static const String baseUrl = "http://100.83.163.53:3000";

  /// Obter o token JWT armazenado no SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Envia os dados de um ponto ao backend
  static Future<bool> criarPonto({
    required String endereco,
    required String sentido,
    required String tipo,
    required double longitude,
    required double latitude,
    required bool ativo,
    String? imagemPath, // Caminho para a imagem (opcional)
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('Token de autenticação não encontrado.');
        return false;
      }

      final url = Uri.parse('$baseUrl/pontos');
      final request = http.MultipartRequest('POST', url)
        ..fields['endereco'] = endereco
        ..fields['sentido'] = sentido
        ..fields['tipo'] = tipo
        ..fields['geom'] = jsonEncode({"lon": longitude, "lat": latitude})
        ..fields['ativo'] = ativo.toString()
        ..headers['Authorization'] = 'Bearer $token'; // Adiciona o token no cabeçalho

      // Adiciona a imagem, se existir
      if (imagemPath != null) {
        request.files.add(await http.MultipartFile.fromPath('imagem', imagemPath));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        print('Ponto criado com sucesso!');
        return true;
      } else if (response.statusCode == 401) {
        print('Erro: Não autorizado. Verifique o token.');
        return false;
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
