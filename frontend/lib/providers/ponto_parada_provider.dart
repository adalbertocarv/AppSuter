import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class PontoParadaProvider {
  final String address;
  final String direction;
  final String type;
  final bool isActive;
  final LatLng latLng;
  final String? imagePath;

  PontoParadaProvider({
    required this.address,
    required this.direction,
    required this.type,
    required this.isActive,
    required this.latLng,
    this.imagePath,
  });
}

class PointProvider with ChangeNotifier {
  final List<PontoParadaProvider> _paradas = [];

  List<PontoParadaProvider> get points => [..._paradas];

  // Adiciona uma nova parada temporariamente
  void addPoint({
    required String address,
    required String direction,
    required String type,
    required bool isActive,
    required LatLng latLng,
    String? imagePath,
  }) {
    _paradas.add(
      PontoParadaProvider(
        address: address,
        direction: direction,
        type: type,
        isActive: isActive,
        latLng: latLng,
        imagePath: imagePath,
      ),
    );
    notifyListeners(); // Notifica ouvintes da atualização
  }

  // Remove uma parada
  void removePoint(int index) {
    _paradas.removeAt(index);
    notifyListeners();
  }

  // Envia os pontos salvos temporariamente para o backend
  Future<void> sendPointsToBackend() async {
    for (var point in _paradas) {
      try {
        // Simulação de envio para o backend (substitua com lógica real)
        // Utilize uma biblioteca como `http` para enviar um POST
        print('Enviando parada: ${point.address}');
        // TODO: Implementar lógica de envio para o backend aqui
      } catch (e) {
        print('Erro ao enviar ponto: ${point.address}');
      }
    }

    // Limpa as paradas após envio
    _paradas.clear();
    notifyListeners();
  }
}
