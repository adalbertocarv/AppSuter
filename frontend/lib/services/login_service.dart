import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  // Login do usuário
  static Future<int?> login(String nome, String matricula) async {
    final url = Uri.parse('http://10.233.144.111:3000/usuarios/verificar');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nome,
        "matricula": matricula,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final idUsuario = json['idUsuario'];

      // Armazenar o ID do usuário localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('idUsuario', idUsuario);

      print('ID do usuário logado: $idUsuario');

      return idUsuario;
    }
    else {

      return null; // Login falhou
    }
  }

  // Obter ID do usuário armazenado
  static Future<int?> getUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('idUsuario');
  }

  // Logout do usuário
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idUsuario');
  }
}
