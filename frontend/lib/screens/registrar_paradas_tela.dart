import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';
import '../models/ponto_model.dart';
import '../services/paradas_service.dart';
import 'carregamento_endereco_tela.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import '../services/enderecoOSM_service.dart';
import '../services/via_service.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class RegistrarParadaTela extends StatefulWidget {
  const RegistrarParadaTela({super.key});

  @override
  _RegistrarParadaTelaState createState() => _RegistrarParadaTelaState();
}

class _RegistrarParadaTelaState extends State<RegistrarParadaTela> with TickerProviderStateMixin {
  LatLng? _pontoSelecionado; // Armazena o ponto selecionado
  LatLng? _pontoParadaConfirmado; // Armazena o ponto de parada confirmado
  LatLng? _pontoInterpolado; // Ponto interpolado confirmado
  LatLng? _userLocation; // Armazena a localização do usuário
  bool _isLoading = true; // Indica se a localização está sendo carregada
  bool _viaConfirmada = false; // Indica se a via foi confirmada
  bool showSatellite = false; // Estado para alternar sobreposição do satélite
  Timer? _timer; //consultar polylines a cada 30s
  List<Marker> _markers = [];
  final ParadasService _paradasService =
  ParadasService(); // Instância do serviço que busca GeoJSON da API
  bool _mostrarMarcadores = false; // Inicialmente visível
  final EnderecoService _enderecoService =
  EnderecoService(); // Serviço de busca de endereço

  // URLs dos tiles
  final String openStreetMapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  final String esriSatelliteUrl = 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';


  List<Polyline> _polylines = [];
  List<LatLng> _consolidatedPoints = [];

  final GeoJsonService _viaService = GeoJsonService();

  final MapController _mapController = MapController(); // Controlador do mapa
  // Adiciona o tile provider com cache
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );


  @override
  void dispose() {
    _carregarViasComLocalizacaoAtual();
    _mapController.dispose();
    _timer?.cancel(); // Cancela o timer ao sair da tela
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _localizacaoUsuario();
    _carregarParadas();
    _carregarViasComLocalizacaoAtual();

    // Escuta mudanças no PointProvider para limpar marcadores
    Provider.of<PontoProvider>(context, listen: false).addListener(() {
      setState(() {
        _pontoSelecionado = null;
        _pontoParadaConfirmado = null;
        _pontoInterpolado = null;
        _viaConfirmada = false;
      });
    });
  }

// Método para obter a localização do usuário
  Future<void> _localizacaoUsuario() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _carregarParadas() async {
    try {
      final paradas = await _paradasService.procurarParadas();
      _markers = paradas.map((parada) {
        final marker = Marker(
          point: parada.point,
          width: 45,
          height: 45,
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: const Icon(
              Icons.location_pin,
              color: Colors.blue,
              size: 45,
            ),
          ),
        );
        return marker;
      }).toList();
    } catch (e) {
      // Lidar com erro, se necessário
    }
  }

  Future<void> _carregarViasComLocalizacaoAtual() async {
    try {
      Position posicaoAtual = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng userLocation = LatLng(posicaoAtual.latitude, posicaoAtual.longitude);
      final vias = await _viaService.buscarViasProximas(userLocation);
      if (!mounted) return;
      setState(() {
        _polylines = vias;
        _consolidatedPoints = _consolidarPontos(_polylines);
      });
    } catch (e) {
      if (mounted) {
        print('Erro ao carregar vias próximas: $e');
      }
    }
  }

  Future<void> _confirmarPonto() async {
    if (_pontoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum ponto selecionado para confirmar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final LatLng ponto = _pontoSelecionado!;

    if (mounted) {
      setState(() {
        _pontoParadaConfirmado = ponto;
        _viaConfirmada = false;
      });
    }

    try {
      final endereco = await _enderecoService.buscarEndereco(
        ponto.latitude,
        ponto.longitude,
      );

      if (endereco.formattedAddress.isNotEmpty) {
        if (mounted) {
          setState(() {
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Endereço não encontrado.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao buscar o endereço'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

//---------INTERPOLAÇÃO DE LINHA
  List<LatLng> _consolidarPontos(List<Polyline> polylines) {
    List<LatLng> allPoints = [];
    for (var polyline in polylines) {
      allPoints.addAll(polyline.points);
    }
    return allPoints;
  }

  LatLng acharPontoInterpolado(LatLng point) {
    double distanciaMin = double.infinity;
    double tamanhoTotal = tamanhoTotalLinha();
    double projecaoMaisProxima = 0.0;
    double accumulatedLength = 0.0;

    for (int i = 0; i < _consolidatedPoints.length - 1; i++) {
      LatLng start = _consolidatedPoints[i];
      LatLng end = _consolidatedPoints[i + 1];

      LatLng projectedPoint = pontoSobreLinha(point, start, end);
      double distancia =
      const Distance().as(LengthUnit.Meter, point, projectedPoint);
      double segmentLength = const Distance().as(LengthUnit.Meter, start, end);

      if (distancia < distanciaMin) {
        distanciaMin = distancia;
        double projectionFactorOnSegment =
            const Distance().as(LengthUnit.Meter, start, projectedPoint) /
                segmentLength;
        projecaoMaisProxima =
            (accumulatedLength + projectionFactorOnSegment * segmentLength) /
                tamanhoTotal;
      }
      accumulatedLength += segmentLength;
    }

    return interpolateAlongLine(projecaoMaisProxima);
  }

  double tamanhoTotalLinha() {
    double length = 0.0;
    for (int i = 0; i < _consolidatedPoints.length - 1; i++) {
      length += const Distance().as(
          LengthUnit.Meter, _consolidatedPoints[i], _consolidatedPoints[i + 1]);
    }
    return length;
  }

  LatLng interpolateAlongLine(double factor) {
    double targetDistance = factor * tamanhoTotalLinha();
    double accumulatedDistance = 0.0;

    for (int i = 0; i < _consolidatedPoints.length - 1; i++) {
      LatLng start = _consolidatedPoints[i];
      LatLng end = _consolidatedPoints[i + 1];
      double segmentLength = const Distance().as(LengthUnit.Meter, start, end);

      if (accumulatedDistance + segmentLength >= targetDistance) {
        double segmentFactor =
            (targetDistance - accumulatedDistance) / segmentLength;
        double interpolatedLat =
            start.latitude + segmentFactor * (end.latitude - start.latitude);
        double interpolatedLng =
            start.longitude + segmentFactor * (end.longitude - start.longitude);
        return LatLng(interpolatedLat, interpolatedLng);
      }
      accumulatedDistance += segmentLength;
    }

    return _consolidatedPoints.last;
  }

  LatLng pontoSobreLinha(LatLng point, LatLng start, LatLng end) {
    final double x1 = start.longitude;
    final double y1 = start.latitude;
    final double x2 = end.longitude;
    final double y2 = end.latitude;
    final double x0 = point.longitude;
    final double y0 = point.latitude;

    final double dx = x2 - x1;
    final double dy = y2 - y1;

    if (dx == 0 && dy == 0) {
      return start;
    }

    double t = ((x0 - x1) * dx + (y0 - y1) * dy) / (dx * dx + dy * dy);
    t = t.clamp(0.0, 1.0);

    double projectedX = x1 + t * dx;
    double projectedY = y1 + t * dy;

    return LatLng(projectedY, projectedX);
  }
//---------FIM DA INTERPOLAÇÃO
  void _confirmarVia() {
    if (_pontoSelecionado != null) {
      LatLng pontoInterpolado = acharPontoInterpolado(_pontoSelecionado!);
      setState(() {
        _pontoInterpolado = pontoInterpolado;
        _viaConfirmada = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um ponto de via antes de confirmar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Função para limpar todos os pontos
  void _limparPontos() {
    if (mounted) {
      setState(() {
        _pontoSelecionado = null;
        _pontoParadaConfirmado = null;
        _pontoInterpolado = null;
        _viaConfirmada = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os pontos foram limpos. Selecione novamente.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Método para centralizar o mapa na localização do usuário (com animação)
  void _centralizarLocalizacaoUsuario() {
    if (_userLocation != null) {
      LatLng startPosition = _mapController.camera.center;
      LatLng targetPosition = _userLocation!;
      double startZoom = _mapController.camera.zoom;
      double targetZoom = 17.0;
      int duration = 350; // Tempo total da animação (em milissegundos)
      int steps = 30; // Número de frames na animação
      int interval = (duration / steps).round(); // Tempo entre cada frame

      int currentStep = 0;
      Timer.periodic(Duration(milliseconds: interval), (timer) {
        currentStep++;

        // Interpola latitude e longitude
        double lat = lerpDouble(startPosition.latitude, targetPosition.latitude, currentStep / steps)!;
        double lng = lerpDouble(startPosition.longitude, targetPosition.longitude, currentStep / steps)!;

        // Interpola o zoom
        double zoom = lerpDouble(startZoom, targetZoom, currentStep / steps)!;

        _mapController.move(LatLng(lat, lng), zoom);

        if (currentStep >= steps) {
          timer.cancel(); // Finaliza a animação
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização do usuário não disponível.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pontoProvider = Provider.of<PontoProvider>(context);
    final paradasTemporarias = pontoProvider.pontos.map((point) {
      return Marker(
        point: LatLng(point.latitude, point.longitude),
        child: Transform.translate(
          offset: const Offset(0, -20),
          child: const Icon(
            Icons.location_pin,
            color: Colors.green,
            size: 35,
          ),
        ),
      );
    }).toList();
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                  initialCenter:
                  _userLocation ?? const LatLng(-15.7942, -47.8822),
                  initialZoom: 17.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onMapEvent: (event) {
                    LatLng novoPonto = _mapController.camera.center;
                    if (_pontoSelecionado == null ||
                        _pontoSelecionado!.latitude != novoPonto.latitude ||
                        _pontoSelecionado!.longitude != novoPonto.longitude) {
                      setState(() {
                        _pontoSelecionado = novoPonto;
                      });
                    }
                  }
              ),
              children: [
                // Camada Base: OpenStreetMap
                TileLayer(
                  urlTemplate: openStreetMapUrl,
                  userAgentPackageName: 'com.ponto.parada.frontend',
                  tileProvider: _tileProvider,
                ),
                // Camada de Satélite: GoogleMaps (Visibilidade controlada)
                if (showSatellite)
                  TileLayer(
                    urlTemplate: esriSatelliteUrl,
                    userAgentPackageName: 'com.ponto.parada.frontend',
                  ),
                // Clusterização apenas para _markers
                if (_mostrarMarcadores && _markers.isNotEmpty)
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 100,
                      size: const Size(40, 40),
                      padding: const EdgeInsets.all(50),
                      markers: _markers,
                      builder: (context, markers) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                      showPolygon: true, // Exibe o polígono de agrupamento
                      polygonOptions: PolygonOptions(
                        borderColor: Colors.blue, // Cor da borda do polígono
                        borderStrokeWidth: 3, // Largura da borda
                        color: Colors.blue.withValues(alpha: 0.2), // Cor de preenchimento com opacidade
                      ),
                    ),
                  ),
                // Outros marcadores não clusterizados
                if (_userLocation != null)
                  MarkerLayer(
                    markers: [
                      if (_userLocation != null)
                        Marker(
                          point: _userLocation!,
                          width: 50,
                          height: 50,
                          child: Transform.translate(
                            offset: const Offset(0, -22),
                            child: Image.asset(
                              'assets/images/user_location.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ...paradasTemporarias, // Adiciona os markers do provider
                    ],
                  ),
                PolylineLayer(polylines: _polylines),
                if (_pontoParadaConfirmado != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pontoParadaConfirmado!,
                        width: 45.0,
                        height: 45.0,
                        child: Transform.translate(
                          offset: const Offset(0, -22),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.greenAccent,
                            size: 45,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_pontoInterpolado != null)
                //ponto interpolado
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pontoInterpolado!,
                        width: 45.0,
                        height: 45.0,
                        child: Transform.translate(
                          offset: const Offset(0, -20),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: 45,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          if (!_isLoading)
            IgnorePointer(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _viaConfirmada
                  ? () {
                if (_pontoParadaConfirmado == null || _pontoInterpolado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dados incompletos para cadastro.')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarregamentoTela(
                      pontoParada: _pontoParadaConfirmado!,
                      enderecoFuture: _enderecoService.buscarEndereco(
                        _pontoParadaConfirmado!.latitude,
                        _pontoParadaConfirmado!.longitude,
                      ).then((endereco) => endereco.formattedAddress),
                      pontoInterpolado: _pontoInterpolado!,
                    ),
                  ),
                );
              }
                  : (_pontoParadaConfirmado == null
                  ? _confirmarPonto
                  : _confirmarVia),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _viaConfirmada
                          ? const Color(0xFF34C759)
                          : (_pontoParadaConfirmado == null
                          ? Colors.blue
                          : Colors.orange),
                      Colors.green.shade600,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _viaConfirmada
                            ? 'Cadastrar Ponto de Parada'
                            : (_pontoParadaConfirmado == null
                            ? 'Confirmar Ponto Parada'
                            : 'Confirmar Via da Parada'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_forward, size: 16, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_pontoParadaConfirmado != null && !_viaConfirmada)
            Positioned(
              bottom: 140,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _pontoInterpolado = const LatLng(0, 0);
                    _viaConfirmada = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Não há Vias',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          if (_pontoSelecionado != null &&
              _pontoParadaConfirmado != null &&
              _pontoInterpolado != null &&
              _viaConfirmada) // Exibe o botão somente se houver marcadores
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                heroTag: null, // Desativa a animação Hero para evitar conflito
                onPressed: _limparPontos,
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete),
                tooltip: 'Limpar todos os pontos',
              ),
            ),
          // Botão para centralizar na localização do usuário
          Positioned(
            top: 16, // Distância do topo
            right: 16, // Distância da direita
            child: FloatingActionButton(
              heroTag: null, // Desativa a animação Hero para evitar conflito
              onPressed: _centralizarLocalizacaoUsuario,
              child: const Icon(Icons.my_location),
              tooltip: 'Minha localização',
              backgroundColor: Colors.blue[900],
            ),
          ),
          Positioned(
              top: 80,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _mostrarMarcadores =
                    !_mostrarMarcadores; // Alterna entre true/false
                  });
                },
                backgroundColor: _mostrarMarcadores ? Colors.blue[900] : Colors.grey,
                child: Icon(_mostrarMarcadores
                    ? Icons.location_pin
                    : Icons.location_off_sharp),
                tooltip: _mostrarMarcadores
                    ? "Ocultar Paradas antigas"
                    : "Mostrar Paradas antigas",
              )),

          // Botão para ativar/desativar a sobreposição de satélite
          Positioned(
            top: 140,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  showSatellite = !showSatellite; // Alterna exibição do satélite
                });
              },
              child: Icon(showSatellite ? Icons.map : Icons.satellite),
              tooltip: 'Alternar entre camadas de mapa'
            ),
          ),
        ],
      ),
    );
  }
}