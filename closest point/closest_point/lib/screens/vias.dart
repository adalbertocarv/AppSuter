import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapaVias extends StatefulWidget {
  @override
  _MapaViasState createState() => _MapaViasState();
}

class _MapaViasState extends State<MapaVias> {
  List<Polyline> _polylines = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregarViasComLocalizacaoAtual(); // Primeira requisição ao iniciar
    _iniciarAtualizacaoAutomatica(); // Atualização a cada 30s
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o timer ao sair da tela
    super.dispose();
  }

  // Método para iniciar a atualização automática
  void _iniciarAtualizacaoAutomatica() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _carregarViasComLocalizacaoAtual();
    });
  }

  // Obter a localização atual do usuário e carregar vias próximas
  Future<void> _carregarViasComLocalizacaoAtual() async {
    try {
      Position posicaoAtual = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double latitude = posicaoAtual.latitude;
      double longitude = posicaoAtual.longitude;

      print('Localização atual: Latitude $latitude, Longitude $longitude');

      await _carregarViasProximas(latitude, longitude);
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  // Fazer a requisição GET para obter vias próximas
  Future<void> _carregarViasProximas(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'http://localhost:3000/vias/proximas?latitude=$latitude&longitude=$longitude'));

    if (response.statusCode == 200) {
      final geojson = json.decode(response.body);
      final List<Polyline> linhas = _converterGeoJsonParaPolylines(geojson);

      setState(() {
        _polylines = linhas;
      });
    } else {
      print('Erro ao carregar vias: ${response.statusCode}');
    }
  }

  // Converter GeoJSON para polylines do mapa
  List<Polyline> _converterGeoJsonParaPolylines(dynamic geojson) {
    List<Polyline> polylines = [];

    for (var feature in geojson['features']) {
      List<LatLng> pontos = [];

      for (var linha in feature['geometry']['coordinates']) {
        for (var coord in linha) {
          pontos.add(LatLng(coord[1], coord[0]));
        }
      }

      polylines.add(Polyline(
        points: pontos,
        strokeWidth: 4.0,
        color: Colors.blue,
      ));
    }

    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Vias')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-15.78051090, -47.98843593),
          initialZoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: _polylines,
          ),
        ],
      ),
    );
  }
}
