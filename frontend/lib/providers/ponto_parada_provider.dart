import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointProvider with ChangeNotifier {
  List<Map<String, dynamic>> _points = [];

  List<Map<String, dynamic>> get points => [..._points];

  /// Carregar dados salvos localmente
  Future<void> carregarPontos() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPoints = prefs.getString('points');
    if (storedPoints != null) {
      _points = List<Map<String, dynamic>>.from(jsonDecode(storedPoints));
      notifyListeners();
    }
  }

  /// Salvar pontos localmente
  Future<void> _savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('points', jsonEncode(_points));
  }

  /// Adicionar um novo ponto localmente e fazer POST no backend
  Future<void> adicionarPontos({
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
    required bool baia,
    required bool pisoTatil,
    required bool rampa,
    required bool patologia,
    required List<Map<String, dynamic>> abrigos,
  }) async {
    final newPoint = {
      "idUsuario": idUsuario,
      "endereco": endereco,
      "latitude": latitude,
      "longitude": longitude,
      "LinhaEscolares": linhaEscolares,
      "LinhaStpc": linhaStpc,
      "idTipoAbrigo": abrigos.isNotEmpty ? abrigos.first["idTipoAbrigo"] : null,
      "latitudeInterpolado": latitudeInterpolado,
      "longitudeInterpolado": longitudeInterpolado,
      "DataVisita": dataVisita,
      "Baia": baia,
      "PisoTatil": pisoTatil,
      "Rampa": rampa,
      "Patologia": patologia,
      "abrigos": abrigos,
      "haAbrigo": abrigos.isNotEmpty,
      "acessibilidade": pisoTatil || rampa,
      "linhasTransporte": linhaEscolares || linhaStpc,
    };

    _points.add(newPoint);
    notifyListeners();
    await _savePoints();
  }

  /// Atualizar um ponto existente
  Future<void> atualizarPontos(
      int index, {
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
        required bool baia,
        required bool pisoTatil,
        required bool rampa,
        required bool patologia,
        required List<Map<String, dynamic>> abrigos,
      }) async {
    if (index < 0 || index >= _points.length) {
      print('Índice inválido');
      return;
    }

    final updatedPoint = {
      "idUsuario": idUsuario,
      "endereco": endereco,
      "latitude": latitude,
      "longitude": longitude,
      "LinhaEscolares": linhaEscolares,
      "LinhaStpc": linhaStpc,
      "idTipoAbrigo": abrigos.isNotEmpty ? abrigos.first["idTipoAbrigo"] : null,
      "latitudeInterpolado": latitudeInterpolado,
      "longitudeInterpolado": longitudeInterpolado,
      "DataVisita": dataVisita,
      "Baia": baia, // Correção adicionada
      "PisoTatil": pisoTatil,
      "Rampa": rampa,
      "Patologia": patologia,
      "abrigos": abrigos,
      "haAbrigo": abrigos.isNotEmpty,
      "acessibilidade": pisoTatil || rampa,
      "linhasTransporte": linhaEscolares || linhaStpc,
    };

    _points[index] = updatedPoint;
    notifyListeners();
    await _savePoints();
  }

  /// Remover um ponto por índice
  void removerPontos(int index) {
    _points.removeAt(index);
    notifyListeners();
    _savePoints();
  }

  /// Limpar todos os pontos (opcional, usado no logout ou ao enviar para o banco)
  Future<void> limparPontos() async {
    _points = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('points');
  }
}
