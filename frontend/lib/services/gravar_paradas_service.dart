import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PontoParadaService {
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
    required bool baia,
    required List<Map<String, dynamic>> abrigos,
  }) async {
    try {
      final url = Uri.parse('http://10.233.144.111:3000/pontos/criar');

      final List<Map<String, dynamic>> abrigosFormatados = abrigos.map((abrigo) {
        final imagensAbrigo = List<String>.from(abrigo["imgBlobPaths"] ?? []).map((path) {
          final bytes = File(path).readAsBytesSync();
          return {"abrigo_img": base64Encode(bytes)};
        }).toList();

        final List<Map<String, dynamic>> patologias = [];
        if (abrigo["temPatologia"] == true) {
          final imagensPatologia = List<String>.from(abrigo["imagensPatologiaPaths"] ?? []).map((path) {
            final bytes = File(path).readAsBytesSync();
            return {"patologias_img": base64Encode(bytes)};
          }).toList();

          final int idTipoPatologia = abrigo["idTipoPatologia"] ?? 1;

          patologias.add({
            "id_tipo_patologia": idTipoPatologia,
            "imagens": imagensPatologia,
          });
        }

        return {
          "id_tipo_abrigo": abrigo["idTipoAbrigo"],
          "imagens": imagensAbrigo,
          "patologias": patologias,
        };
      }).toList();

      final Map<String, dynamic> bodyJson = {
        "id_usuario": idUsuario,
        "endereco": endereco,
        "latitude": latitude,
        "longitude": longitude,
        "linha_escolar": linhaEscolares,
        "linha_stpc": linhaStpc,
        "latitudeInterpolado": latitudeInterpolado,
        "longitudeInterpolado": longitudeInterpolado,
        "data_visita": dataVisita,
        "baia": baia,
        "rampa_acessivel": rampa,
        "piso_tatil": pisoTatil,
        "patologia": patologia,
        "abrigos": abrigosFormatados,
      };

      print('JSON Enviado:');
      print(JsonEncoder.withIndent('  ').convert(bodyJson));
      print('Enviando requisição para: $url');
      print('Tamanho do JSON: ${utf8.encode(jsonEncode(bodyJson)).length} bytes');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyJson),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        print('✅ Ponto criado com sucesso!');
        return true;
      } else {
        print('❌ Erro ao criar o ponto: ${response.statusCode}');
        print('📥 Resposta: ${await response.body}');
        return false;
      }
    } catch (error) {
      print('❌ Erro na criação do ponto: $error');
      return false;
    }
  }

}
