import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/ponto_parada_service.dart';
import '../services/bacias_service.dart';
import '../services/ras_service.dart';

class ParadasTela extends StatefulWidget {
  const ParadasTela({super.key});

  @override
  _ParadasTelaState createState() => _ParadasTelaState();
}

class _ParadasTelaState extends State<ParadasTela> {
  String? _camadaSelecionada; // Layer selecionada (Bacias, RAS, RA)
  String? _featureSelecionada; // feature selecionada
  List<String> _featuresList = []; // Lista das features para o dropdown
  List<List<LatLng>> _currentPolygons = []; // Polygons colocados no mapa

  final BaciaService _baciaService = BaciaService();
  final RAService _rasService = RAService();

  List<Marker> _markers = []; // Lista de markers para o mapa
  bool _isLoading = true; // Indica se os dados estão sendo carregados

  @override
  void initState() {
    super.initState();
    _camadaSelecionada = 'Bacias DF'; // Default layer
    _loadBacias(); // Load Bacias on initialization
    _loadParadas(); // Carrega as paradas ao iniciar a tela
  }

  Future<void> _loadBacias() async {
    try {
      final baciasFeatures = await _baciaService.fetchBacias();
      setState(() {
        _featuresList = baciasFeatures
            .map<String>((feature) => feature['properties']['dsc_bacia'])
            .toList();
        _featureSelecionada = _featuresList.isNotEmpty ? _featuresList.first : null;
        _filterPolygons(baciasFeatures, _featureSelecionada, 'dsc_bacia');
      });
    } catch (e) {
      print('Erro ao carregar Bacias: $e');
    }
  }

  Future<void> _loadRas() async {
    try {
      final rasFeatures = await _rasService.fetchRA();
      setState(() {
        _featuresList = rasFeatures
            .map<String>((feature) => feature['properties']['dsc_nome'])
            .toList();
        _featureSelecionada = _featuresList.isNotEmpty ? _featuresList.first : null;
        _filterPolygons(rasFeatures, _featureSelecionada, 'dsc_nome');
      });
    } catch (e) {
      print('Erro ao carregar RAS: $e');
    }
  }

  void _filterPolygons(
      List<dynamic> features, String? selectedFeature, String propertyKey) {
    if (selectedFeature == null) return;

    final selectedFeatures = features.where((feature) {
      return feature['properties'][propertyKey] == selectedFeature;
    }).toList();

    List<List<LatLng>> polygons = [];
    for (var feature in selectedFeatures) {
      final geometry = feature['geometry'];
      if (geometry['type'] == 'Polygon') {
        for (var polygon in geometry['coordinates']) {
          polygons.add(
            polygon.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList(),
          );
        }
      } else if (geometry['type'] == 'MultiPolygon') {
        for (var multipolygon in geometry['coordinates']) {
          for (var polygon in multipolygon) {
            polygons.add(
              polygon.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList(),
            );
          }
        }
      }
    }

    setState(() {
      _currentPolygons = polygons;
    });
  }
  // Método para carregar as paradas do backend
  Future<void> _loadParadas() async {
    try {
      final paradas = await PontoParadaService.todasAsParadas();
      setState(() {
        _markers = paradas.map((parada) {
          return Marker(
            point: LatLng(parada['latitude'], parada['longitude']),
            width: 32, // Largura do marker
            height: 32, // Altura do marker
            child: GestureDetector(
              onTap: () {
                _mostrarDetalhesParada(parada);
              },
              child: Image.asset(
                'assets/images/paradaComFundo.png',
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar paradas: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar paradas.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Exibe um diálogo com os detalhes da parada
  void _mostrarDetalhesParada(Map<String, dynamic> parada) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(parada['endereco']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sentido: ${parada['sentido']}'),
              Text('Tipo: ${parada['tipo']}'),
              Text('Ativo: ${parada['ativo'] ? 'Sim' : 'Não'}'),
              Text('Latitude: ${parada['latitude']}'),
              Text('Longitude: ${parada['longitude']}'),
              if (parada['imagemUrl'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center( // Centraliza a imagem horizontalmente
                    child: Image.network(
                      parada['imagemUrl'],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paradas Registradas'),
      ),
        body: Column(
          children: [
          // First Dropdown: Layer Selection
          DropdownButton<String>(
          value: _camadaSelecionada,
          hint: const Text('Selecione uma camada'),
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'Bacias DF', child: Text('Bacias DF')),
            DropdownMenuItem(value: 'RAS DF', child: Text('RAS DF')),
          ],
          onChanged: (String? newLayer) {
            setState(() {
              _camadaSelecionada = newLayer;
              _featureSelecionada = null; // Reset the second dropdown selection
              _featuresList.clear(); // Clear the features list
            });

            // Load features based on selected layer
            if (newLayer == 'Bacias DF') {
              _loadBacias();
            } else if (newLayer == 'RAS DF') {
              _loadRas();
            }
          },
        ),

        // Second Dropdown: Feature Selection
        if (_featuresList.isNotEmpty)
    DropdownButton<String>(
      value: _featureSelecionada,
      hint: const Text('Selecione um item'),
      isExpanded: true,
      items: _featuresList.map((feature) {
        return DropdownMenuItem<String>(
          value: feature,
          child: Text(feature),
        );
      }).toList(),
      onChanged: (String? newFeature) {
        setState(() {
          _featureSelecionada = newFeature;
        });

        // Filtra poligonos baseado na feature selecionada
        if (_camadaSelecionada == 'Bacias DF') {
          _filterPolygons(_baciaService.features, newFeature, 'dsc_bacia');
        } else if (_camadaSelecionada == 'RAS DF') {
          _filterPolygons(_rasService.features, newFeature, 'dsc_nome');
        }
      },
    ),
    Expanded(
    child: FlutterMap(
        options: const MapOptions(
          center: LatLng(-15.7942, -47.8822),
          zoom: 14.0,
          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          if (_currentPolygons.isNotEmpty)
            PolygonLayer(
              polygons: _currentPolygons.map((polygon) {
                return Polygon(
                  points: polygon,
                  color: Colors.blue.withOpacity(0.3),
                  isFilled: true,
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2.0,
                );
              }).toList(),
            ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
    )]));
  }
}
