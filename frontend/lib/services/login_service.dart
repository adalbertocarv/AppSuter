import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginService {
  // Login do usuário
  static Future<String?> login(String email, String senha) async {
    final url = Uri.parse('http://100.87.130.42:3001/usuarios/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "senha": senha}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final token = json['token'];

      // Decodificar o token para obter a data de expiração
      final expirationDate = JwtDecoder.getExpirationDate(token);

      // Salvar o token e a data de expiração localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('token_expiration', expirationDate.toIso8601String());

      return token;
    } else {
      return null; // Login falhou
    }
  }

  // Obter token armazenado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Verificar validade do token
  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    return !JwtDecoder.isExpired(token); // Retorna true se o token ainda for válido
  }

  // Logout do usuário
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('token_expiration');
  }

}
