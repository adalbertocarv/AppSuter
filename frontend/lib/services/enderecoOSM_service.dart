import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/enderecoOSM_model.dart';

class EnderecoService {
  Future<EnderecoModel> buscarEndereco(double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude';

    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'com.ponto.parada.frontend',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return EnderecoModel.fromJson(data);
    } else {
      throw Exception('Erro ao buscar o endereço: ${response.statusCode}');
    }
  }
}
