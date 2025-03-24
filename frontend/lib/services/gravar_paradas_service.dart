import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    required double latitudeInterpolado,
    required double longitudeInterpolado,
    required String dataVisita,
    required bool pisoTatil,
    required bool rampa,
    required bool patologia,
    required int idTipoAbrigo,
    required List<String> imgBlobPaths,
    required List<String> imagensPatologiaPaths,
    required List<Map<String, dynamic>> abrigos, // 🔹 Adicionado o parâmetro `abrigos`
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ Token de autenticação não encontrado.');
        return false;
      }

      final url = Uri.parse('http://seu_backend.com/paradas/criar');
      final request = http.MultipartRequest('POST', url);

      // Criando o body JSON
      final Map<String, dynamic> bodyJson = {
        "idUsuario": idUsuario,
        "endereco": endereco,
        "latitude": latitude,
        "longitude": longitude,
        "LinhaEscolares": linhaEscolares,
        "LinhaStpc": linhaStpc,
        "latitudeInterpolado": latitudeInterpolado,
        "longitudeInterpolado": longitudeInterpolado,
        "DataVisita": dataVisita,
        "PisoTatil": pisoTatil,
        "Rampa": rampa,
        "Patologia": patologia,
        "idTipoAbrigo": idTipoAbrigo,
        "imgBlob": imgBlobPaths.map((e) => e.split('/').last).toList(),
        "ImagensPatologia": imagensPatologiaPaths.map((e) => e.split('/').last).toList(),
        "abrigos": abrigos, // 🔹 Adicionado `abrigos` ao JSON final
      };

      // 🔹 Printar JSON antes do envio (debug)
      print('📌 JSON Enviado:');
      print(JsonEncoder.withIndent('  ').convert(bodyJson));

      // Adicionar os campos ao request
      request.fields['data'] = jsonEncode(bodyJson);
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      if (response.statusCode == 201) {
        print('✅ Ponto criado com sucesso!');
        return true;
      } else {
        print('❌ Erro ao criar o ponto: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('❌ Erro na criação do ponto: $error');
      return false;
    }
  }
}
