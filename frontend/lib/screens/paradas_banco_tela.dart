import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
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
  LatLng? _userLocation; // Armazena a localização do usuário
  List<String> _featuresList = [];
  List<List<LatLng>> _PoligonosAtuais = [];

  final BaciaService _baciaService = BaciaService();
  final RAService _rasService = RAService();
  final MapController _mapController = MapController(); // Controlador do mapa

  List<Marker> _markers = [];
  bool _isLoading = true;

  // Adiciona o tile provider com cache
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  @override
  void initState() {
    super.initState();
    _camadaSelecionada = 'Bacias DF';
    _carrgarBacias();
    _localizacaoUsuario(); // Obtém a localização do usuário ao iniciar
  }

  Future<void> _localizacaoUsuario() async {
    try {
      // Verifica se os serviços de localização estão habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, habilite a localização para continuar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Verifica as permissões de localização
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Solicita permissão
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de localização negada.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Se a permissão for negada permanentemente, redirecione para as configurações
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Permissão de localização negada permanentemente. Habilite nas configurações.'),
            backgroundColor: Colors.red,
          ),
        );
        // Abre as configurações do app para o usuário habilitar manualmente
        await Geolocator.openAppSettings();
        return;
      }

      // Obtém a localização atual
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter localização: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
  // Método para centralizar o mapa na localização do usuário
  void _centralizarLocalizacaoUsuario() {
    if (_userLocation != null) {
      _mapController.move(
          _userLocation!, 17.0); // Move o mapa para a localização do usuário
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização do usuário não disponível.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            child: Stack(
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation ?? const LatLng(-15.7942, -47.8822),
                    initialZoom: 12.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ponto.parada.frontend',
                      tileProvider: _tileProvider,
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
                    if (_markers.isNotEmpty || _userLocation != null)
                      MarkerLayer(
                        markers: [
                          if (_userLocation != null)
                            Marker(
                              point: _userLocation!,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                          ..._markers,
                        ],
                      ),
                  ],
                ),
                // Botão para centralizar na localização do usuário
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _centralizarLocalizacaoUsuario,
                    child: const Icon(Icons.my_location),
                    tooltip: 'Minha localização',
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}