import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/comprimir_imagem.dart';

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
  Future<void> addPoint({
    required int idUsuario,
    required String endereco,
    required double latitude,
    required double longitude,
    required bool linhaEscolares,
    required bool linhaStpc,
    int? idTipoAbrigo,
    required double latitudeInterpolado,
    required double longitudeInterpolado,
    required String dataVisita,
    required bool pisoTatil,
    required bool rampa,
    required bool patologia,
    required List<String> imgBlobPaths,
    required List<String> imagensPatologiaPaths,
    required List<Map<String, dynamic>> abrigos,
  }) async {
    // Comprimir todas as imagens antes de salvar
    List<String> compressedImgBlobPaths = [];
    for (String imagePath in imgBlobPaths) {
      File compressedFile = await compressImage(File(imagePath));
      compressedImgBlobPaths.add(compressedFile.path);
    }

    List<String> compressedImagensPatologiaPaths = [];
    for (String imagePath in imagensPatologiaPaths) {
      File compressedFile = await compressImage(File(imagePath));
      compressedImagensPatologiaPaths.add(compressedFile.path);
    }

    // Criar cópia independente dos abrigos com imagens comprimidas
    List<Map<String, dynamic>> abrigosProcessados = abrigos.map((abrigo) {
      return {
        "idTipoAbrigo": abrigo["idTipoAbrigo"],
        "temPatologia": abrigo["temPatologia"] ?? false,
        "imgBlobPaths": compressedImgBlobPaths, // Armazena as imagens comprimidas
        "imagensPatologiaPaths": compressedImagensPatologiaPaths,
      };
    }).toList();

    final newPoint = {
      "idUsuario": idUsuario,
      "endereco": endereco,
      "latitude": latitude,
      "longitude": longitude,
      "LinhaEscolares": linhaEscolares,
      "LinhaStpc": linhaStpc,
      "idTipoAbrigo": idTipoAbrigo,
      "latitudeInterpolado": latitudeInterpolado,
      "longitudeInterpolado": longitudeInterpolado,
      "DataVisita": dataVisita,
      "PisoTatil": pisoTatil,
      "Rampa": rampa,
      "Patologia": patologia,
      "imgBlobPaths": compressedImgBlobPaths, // Armazena imagens comprimidas
      "imagensPatologiaPaths": compressedImagensPatologiaPaths,
      "abrigos": abrigosProcessados,
    };

    _points.add(newPoint);
    notifyListeners();
    await _savePoints();
  }

  /// Atualizar um ponto existente
  Future<void> updatePoint(
      int index, {
        required int idUsuario,
        required String endereco,
        required double latitude,
        required double longitude,
        required bool linhaEscolares,
        required bool linhaStpc,
        int? idTipoAbrigo,
        required double latitudeInterpolado,
        required double longitudeInterpolado,
        required String dataVisita,
        required bool pisoTatil,
        required bool rampa,
        required bool patologia,
        required List<String> imgBlobPaths,
        required List<String> imagensPatologiaPaths,
        required List<Map<String, dynamic>> abrigos,
      }) async {
    if (index < 0 || index >= _points.length) {
      print('Índice inválido');
      return;
    }

    // Comprimir todas as imagens antes de atualizar
    List<String> compressedImgBlobPaths = [];
    for (String imagePath in imgBlobPaths) {
      File compressedFile = await compressImage(File(imagePath));
      compressedImgBlobPaths.add(compressedFile.path);
    }

    List<String> compressedImagensPatologiaPaths = [];
    for (String imagePath in imagensPatologiaPaths) {
      File compressedFile = await compressImage(File(imagePath));
      compressedImagensPatologiaPaths.add(compressedFile.path);
    }

    // Criar cópia independente dos abrigos com imagens comprimidas
    List<Map<String, dynamic>> abrigosProcessados = abrigos.map((abrigo) {
      return {
        "idTipoAbrigo": abrigo["idTipoAbrigo"],
        "temPatologia": abrigo["temPatologia"] ?? false,
        "imgBlobPaths": compressedImgBlobPaths, // 🔥 Usa imagens comprimidas
        "imagensPatologiaPaths": compressedImagensPatologiaPaths,
      };
    }).toList();

    final updatedPoint = {
      "idUsuario": idUsuario,
      "endereco": endereco,
      "latitude": latitude,
      "longitude": longitude,
      "LinhaEscolares": linhaEscolares,
      "LinhaStpc": linhaStpc,
      "idTipoAbrigo": idTipoAbrigo,
      "latitudeInterpolado": latitudeInterpolado,
      "longitudeInterpolado": longitudeInterpolado,
      "DataVisita": dataVisita,
      "PisoTatil": pisoTatil,
      "Rampa": rampa,
      "Patologia": patologia,
      "imgBlobPaths": compressedImgBlobPaths, // Armazena imagens comprimidas
      "imagensPatologiaPaths": compressedImagensPatologiaPaths,
      "abrigos": abrigosProcessados,
    };

    _points[index] = updatedPoint;
    notifyListeners();
    await _savePoints();
  }


  /// Remover um ponto por índice
  void removePoint(int index) {
    _points.removeAt(index);
    notifyListeners();
    _savePoints();
  }

  /// Limpar todos os pontos (opcional, usado no logout ou ao enviar para o banco)
  Future<void> clearPoints() async {
    _points = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('points');
  }
}
