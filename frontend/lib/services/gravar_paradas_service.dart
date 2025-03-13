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
    required int idUsuario,
    required String endereco,
    required double latitude,
    required double longitude,
    required bool linhaEscolares,
    required bool linhaStpc,
    required int idTipoAbrigo,
    required double latitudeInterpolado,
    required double longitudeInterpolado,
    required String dataVisita,
    required bool pisoTatil,
    required bool rampa,
    required bool patologia,
    required List<String> imgBlobPaths,
    required List<String> imagensPatologiaPaths,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('Token de autenticação não encontrado.');
        return false;
      }

      final url = Uri.parse('${caminhoBackend.baseUrl}/paradas/criar');
      final request = http.MultipartRequest('POST', url);

      // Adicionar os campos normais
      request.fields['idUsuario'] = idUsuario.toString();
      request.fields['endereco'] = endereco;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['LinhaEscolares'] = linhaEscolares.toString();
      request.fields['LinhaStpc'] = linhaStpc.toString();
      request.fields['idTipoAbrigo'] = idTipoAbrigo.toString();
      request.fields['latitudeInterpolado'] = latitudeInterpolado.toString();
      request.fields['longitudeInterpolado'] = longitudeInterpolado.toString();
      request.fields['DataVisita'] = dataVisita;
      request.fields['PisoTatil'] = pisoTatil.toString();
      request.fields['Rampa'] = rampa.toString();
      request.fields['Patologia'] = patologia.toString();

      // Adicionar arquivos imgBlob
      for (String imagePath in imgBlobPaths) {
        request.files.add(await http.MultipartFile.fromPath('imgBlob', imagePath));
      }

      // Adicionar arquivos ImagensPatologia
      for (String imagePath in imagensPatologiaPaths) {
        request.files.add(await http.MultipartFile.fromPath('ImagensPatologia', imagePath));
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
