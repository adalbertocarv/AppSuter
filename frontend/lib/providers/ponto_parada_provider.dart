import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PointProvider with ChangeNotifier {
  List<Map<String, dynamic>> _points = [];

  List<Map<String, dynamic>> get points => [..._points];

  // Carregar dados salvos localmente
  Future<void> loadPoints() async {
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
    required String sentido,
    required String tipo,
    required double longitude,
    required double latitude,
    required bool ativo,
    String? imagemPath,
  }) async {
    final newPoint = {
      "endereco": endereco,
      "sentido": sentido,
      "tipo": tipo,
      "longitude": longitude,
      "latitude": latitude,
      "ativo": ativo,
      "imagemPath": imagemPath,
    };

    // Adicionar localmente
    _points.add(newPoint);
    notifyListeners();
    await _savePoints();

    // Fazer POST no backend
    try {
      final url = Uri.parse("http://100.83.163.53:3000/pontos");
      final request = http.MultipartRequest('POST', url)
        ..fields['endereco'] = endereco
        ..fields['sentido'] = sentido
        ..fields['tipo'] = tipo
        ..fields['geom'] = jsonEncode({"lon": longitude, "lat": latitude})
        ..fields['ativo'] = ativo.toString();

      if (imagemPath != null) {
        request.files.add(await http.MultipartFile.fromPath('imagem', imagemPath));
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
        required String sentido,
        required String tipo,
        required double longitude,
        required double latitude,
        required bool ativo,
        String? imagemPath,
      }) async {
    if (index < 0 || index >= _points.length) {
      print('Índice inválido');
      return;
    }

    final updatedPoint = {
      "endereco": endereco,
      "sentido": sentido,
      "tipo": tipo,
      "longitude": longitude,
      "latitude": latitude,
      "ativo": ativo,
      "imagemPath": imagemPath,
    };

    // Atualizar localmente
    _points[index] = updatedPoint;
    notifyListeners();
    await _savePoints();

    // Fazer PUT no backend
    try {
      final url = Uri.parse("http://100.83.163.53:3000/pontos/${_points[index]['id']}");
      final request = http.MultipartRequest('PUT', url)
        ..fields['endereco'] = endereco
        ..fields['sentido'] = sentido
        ..fields['tipo'] = tipo
        ..fields['geom'] = jsonEncode({"lon": longitude, "lat": latitude})
        ..fields['ativo'] = ativo.toString();

      if (imagemPath != null) {
        request.files.add(await http.MultipartFile.fromPath('imagem', imagemPath));
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
