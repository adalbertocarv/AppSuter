import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginResult {
  final int? idUsuario;
  final bool timeout;

  LoginResult({this.idUsuario, this.timeout = false});
}

class LoginService {
  // Login do usuário
  static Future<LoginResult> login(String nome, String matricula) async {
    final url = Uri.parse('http://100.77.74.55:3003/usuarios/verificar');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nome,
          "matricula": matricula,
        }),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final idUsuario = json['idUsuario'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('idUsuario', idUsuario);

        print('✅ Login OK – ID do usuário: $idUsuario');
        return LoginResult(idUsuario: idUsuario);
      } else {
        return LoginResult(); // Falha comum
      }
    } on TimeoutException {
      print('⏰ Timeout: servidor não respondeu.');
      return LoginResult(timeout: true);
    } catch (e) {
      print('❌ Erro inesperado: $e');
      return LoginResult();
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
