import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/baseUrl_model.dart';

class PointProvider with ChangeNotifier {
  List<Map<String, dynamic>> _points = [];

  List<Map<String, dynamic>> get points => [..._points];

  // Carregar dados salvos localmente
  Future<void> carregarPontos() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPoints = prefs.getString('points');
    if (storedPoints != null) {
      _points = List<Map<String, dynamic>>.from(jsonDecode(storedPoints));
      notifyListeners();
    }
  }

  // Salvar pontos localmente
  Future<void> _savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('points', jsonEncode(_points));
  }

  // Adicionar um novo ponto localmente e fazer POST no backend
  Future<void> addPoint({
    required String endereco,
    required bool haAbrigo,
    required List<Map<String, dynamic>> abrigos, // Agora aceita múltiplos abrigos
    required bool linhasTransporte,
    required double longitude,
    required double latitude,
    required List<String> imagensPaths,
    required String latLongInterpolado,
  }) async {
    final newPoint = {
      "endereco": endereco,
      "haAbrigo": haAbrigo,
      "abrigos": abrigos, // Lista de abrigos
      "linhasTransporte": linhasTransporte,
      "longitude": longitude,
      "latitude": latitude,
      "imagensPaths": imagensPaths,
      "latLongInterpolado": latLongInterpolado,
    };

    // Adiciona localmente
    _points.add(newPoint);
    notifyListeners();
    await _savePoints();

    // Fazer POST no backend
    try {
      final url = Uri.parse('${caminhoBackend.baseUrl}/pontos');
      final request = http.MultipartRequest('POST', url)
        ..fields['endereco'] = endereco
        ..fields['haAbrigo'] = haAbrigo.toString()
        ..fields['linhasTransporte'] = linhasTransporte.toString()
        ..fields['geom'] = jsonEncode({"lon": longitude, "lat": latitude})
        ..fields['latLongInterpolado'] = latLongInterpolado
        ..fields['abrigos'] = jsonEncode(abrigos); // Enviar lista de abrigos

      // Adiciona imagens ao request
      for (String imagePath in imagensPaths) {
        request.files.add(await http.MultipartFile.fromPath('imagens', imagePath));
      }

      final response = await request.send();
      if (response.statusCode == 201) {
        print('Ponto criado com sucesso!');
      } else {
        print('Erro ao criar o ponto: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro na criação do ponto: $error');
    }
  }


  // Atualizar um ponto existente
  Future<void> updatePoint(
      int index, {
        required String endereco,
        required bool haAbrigo,
        required List<Map<String, dynamic>> abrigos, // Lista de abrigos
        required bool linhasTransporte,
        required double longitude,
        required double latitude,
        required List<String> imagensPaths,
      }) async {
    if (index < 0 || index >= _points.length) {
      print('Índice inválido');
      return;
    }

    final updatedPoint = {
      "endereco": endereco,
      "haAbrigo": haAbrigo,
      "abrigos": abrigos, // Mantém os abrigos
      "linhasTransporte": linhasTransporte,
      "longitude": longitude,
      "latitude": latitude,
      "imagensPaths": imagensPaths,
    };

    _points[index] = updatedPoint;
    notifyListeners();
    await _savePoints();

    // Fazer PUT no backend
    try {
      final url = Uri.parse('${caminhoBackend.baseUrl}/pontos/${_points[index]['id']}');
      final request = http.MultipartRequest('PUT', url)
        ..fields['endereco'] = endereco
        ..fields['haAbrigo'] = haAbrigo.toString()
        ..fields['linhasTransporte'] = linhasTransporte.toString()
        ..fields['geom'] = jsonEncode({"lon": longitude, "lat": latitude})
        ..fields['abrigos'] = jsonEncode(abrigos);

      for (String imagePath in imagensPaths) {
        request.files.add(await http.MultipartFile.fromPath('imagens', imagePath));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Ponto atualizado com sucesso!');
      } else {
        print('Erro ao atualizar o ponto: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro na atualização do ponto: $error');
    }
  }


  // Remover um ponto por índice
  void removePoint(int index) {
    _points.removeAt(index);
    notifyListeners();
    _savePoints(); // Atualiza os dados persistidos
  }

  // Limpar todos os pontos (opcional, usado no logout ou ao enviar para o banco)
  Future<void> clearPoints() async {
    _points = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('points');
  }
}
