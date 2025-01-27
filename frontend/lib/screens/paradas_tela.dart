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
  String? _camadaSelecionada;
  String? _featureSelecionada;
  List<String> _featuresList = [];
  List<List<LatLng>> _PoligonosAtuais = [];

  final BaciaService _baciaService = BaciaService();
  final RAService _rasService = RAService();

  List<Marker> _markers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _camadaSelecionada = 'Bacias DF';
    _carrgarBacias();
  }

  // Algoritmo Ray Casting otimizado para verificar se um ponto está dentro do polígono
  //Foi a implementação que funcionou, mas vai ser trocado por consulta direto no banco com within
  bool _paradaDentroPoligono(LatLng point, List<LatLng> polygon) {
    if (polygon.isEmpty) return false;

    bool inside = false;
    int i, j = polygon.length - 1;

    for (i = 0; i < polygon.length; j = i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) *
              (point.latitude - polygon[i].latitude) / (polygon[j].latitude - polygon[i].latitude) +
              polygon[i].longitude)) {
        inside = !inside;
      }
    }

    return inside;
  }

  Future<void> _carrgarBacias() async {
    try {
      final baciasFeatures = await _baciaService.buscarBacias();
      setState(() {
        _featuresList = baciasFeatures
            .map<String>((feature) => feature['properties']['dsc_bacia'])
            .toList();
        _featureSelecionada = _featuresList.isNotEmpty ? _featuresList.first : null;
        _filtrarPoligonos(baciasFeatures, _featureSelecionada, 'dsc_bacia');
      });
    } catch (e) {
      print('Erro ao carregar Bacias: $e');
    }
  }

  Future<void> _carregarRas() async {
    try {
      final rasFeatures = await _rasService.buscarRA();
      setState(() {
        _featuresList = rasFeatures
            .map<String>((feature) => feature['properties']['dsc_nome'])
            .toList();
        _featureSelecionada = _featuresList.isNotEmpty ? _featuresList.first : null;
        _filtrarPoligonos(rasFeatures, _featureSelecionada, 'dsc_nome');
      });
    } catch (e) {
      print('Erro ao carregar RAS: $e');
    }
  }

  void _filtrarPoligonos(List<dynamic> features, String? selectedFeature, String propertyKey) {
    if (selectedFeature == null) return;

    final selectedFeatures = features.where((feature) {
      return feature['properties'][propertyKey] == selectedFeature;
    }).toList();

    List<List<LatLng>> poligonos = [];
    for (var feature in selectedFeatures) {
      final geometry = feature['geometry'];
      if (geometry['type'] == 'Polygon') {
        for (var polygon in geometry['coordinates']) {
          poligonos.add(
            polygon.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList(),
          );
        }
      } else if (geometry['type'] == 'MultiPolygon') {
        for (var multipolygon in geometry['coordinates']) {
          for (var polygon in multipolygon) {
            poligonos.add(
              polygon.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList(),
            );
          }
        }
      }
    }

    setState(() {
      _PoligonosAtuais = poligonos;
      _carregarParadas(); // Carregar paradas após atualizar polígonos
    });
  }

  Future<void> _carregarParadas() async {
    if (_PoligonosAtuais.isEmpty) return;

    try {
      final paradas = await PontoParadaService.todasAsParadas();
      List<Marker> paradasFiltradas = [];

      for (var parada in paradas) {
        final point = LatLng(
            double.parse(parada['latitude'].toString()),
            double.parse(parada['longitude'].toString())
        );

        // Verifica se o ponto está em qualquer um dos polígonos
        bool estaDentro = _PoligonosAtuais.any((polygon) => _paradaDentroPoligono(point, polygon));

        if (estaDentro) {
          paradasFiltradas.add(
            Marker(
              point: point,
              width: 32,
              height: 32,
              child: GestureDetector(
                onTap: () => _mostrarDetalhesParada(parada),
                child: Image.asset(
                  'assets/images/paradaComFundo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }
      }

      setState(() {
        _markers = paradasFiltradas;
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
                  child: Center(
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
                _featureSelecionada = null;
                _featuresList.clear();
              });

              if (newLayer == 'Bacias DF') {
                _carrgarBacias();
              } else if (newLayer == 'RAS DF') {
                _carregarRas();
              }
            },
          ),

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

                if (_camadaSelecionada == 'Bacias DF') {
                  _filtrarPoligonos(_baciaService.features, newFeature, 'dsc_bacia');
                } else if (_camadaSelecionada == 'RAS DF') {
                  _filtrarPoligonos(_rasService.features, newFeature, 'dsc_nome');
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
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (_PoligonosAtuais.isNotEmpty)
                  PolygonLayer(
                    polygons: _PoligonosAtuais.map((polygon) {
                      return Polygon(
                        points: polygon,
                        color: Colors.blue.withOpacity(0.3),
                        isFilled: true,
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2.0,
                      );
                    }).toList(),
                  ),
                if (_markers.isNotEmpty)
                  MarkerLayer(
                    markers: _markers,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}