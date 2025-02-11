import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';
import 'formulario_parada_tela.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
//import '../widgets/progresso_download_widget.dart';
import '../services/enderecoOSM_service.dart';
import '../services/via_service.dart';

final EnderecoService _enderecoService = EnderecoService(); // Serviço de busca de endereço
String? _enderecoAtual;

class RegistrarParadaTela extends StatefulWidget {
  const RegistrarParadaTela({super.key});

  @override
  _RegistrarParadaTelaState createState() => _RegistrarParadaTelaState();
}

class _RegistrarParadaTelaState extends State<RegistrarParadaTela> {
  LatLng? _pontoSelecionado; // Armazena o ponto selecionado
  LatLng? _pontoParadaConfirmado; // Armazena o ponto de parada confirmado
  LatLng? _pontoInterpolado; // Ponto interpolado confirmado
  LatLng? _userLocation; // Armazena a localização do usuário
  bool _isLoading = true; // Indica se a localização está sendo carregada
  //bool _baixando = false; // Controla se o download está ativo
  bool _viaConfirmada = false; // Indica se a via foi confirmada
  Timer? _timer; //consultar polylines a cada 30s

  //double _downloadProgress = 0.0; // Progresso do download (0 a 1)

  List<Polyline> _polylines = [];
  List<LatLng> _consolidatedPoints = [];

  final ViaService _viaService = ViaService();

  final MapController _mapController = MapController(); // Controlador do mapa
  // Adiciona o tile provider com cache
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );
  final _store = const FMTCStore('mapStore'); // Store de cache de tiles

  // Assinaturas do stream
  StreamSubscription<DownloadProgress>? _downloadProgressSubscription;
  StreamSubscription<TileEvent>? _tileEventSubscription;

  @override
  void initState() {
    super.initState();
    _localizacaoUsuario();
    //_baixarTilesBrasilia();
    _carregarViasComLocalizacaoAtual();

    // Escuta mudanças no PointProvider para limpar marcadores
    Provider.of<PointProvider>(context, listen: false).addListener(() {
      setState(() {
        _pontoSelecionado = null;
        _pontoParadaConfirmado = null;
        _pontoInterpolado = null;
        _viaConfirmada = false;
      });
    });
  }
  @override
  void dispose() {
    // Cancela os streams ao desmontar o widget
    //_downloadProgressSubscription?.cancel();
    //_tileEventSubscription?.cancel();
    _iniciarAtualizacaoAutomatica();
    _mapController.dispose();
    _timer?.cancel(); // Cancela o timer ao sair da tela
    super.dispose();
  }
  /// Função para limpar todos os pontos
  void _limparPontos() {
    setState(() {
      _pontoSelecionado = null;
      _pontoParadaConfirmado = null;
      _pontoInterpolado = null;
      _viaConfirmada = false;
      _enderecoAtual = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todos os pontos foram limpos. Selecione novamente.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _carregarViasComLocalizacaoAtual() async {
    try {
      Position posicaoAtual = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double latitude = posicaoAtual.latitude;
      double longitude = posicaoAtual.longitude;

      final vias = await _viaService.buscarViasProximas(latitude, longitude);
      setState(() {
        _polylines = vias.polylines;
        _consolidatedPoints = _consolidarPontos(_polylines);
      });
    } catch (e) {
      print('Erro ao carregar vias: $e');
    }
  }

  // Método para iniciar a atualização automática
  void _iniciarAtualizacaoAutomatica() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _carregarViasComLocalizacaoAtual();
    });
  }

  Future<void> _confirmarPonto() async {
    if (_pontoSelecionado != null) {
      try {
        // Mostra feedback visual enquanto busca o endereço
        /*ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buscando endereço...'),
            backgroundColor: Colors.blueAccent,
          ),
        );
         */

        // Chama o serviço para buscar o endereço
        final endereco = await _enderecoService.buscarEndereco(
          _pontoSelecionado!.latitude,
          _pontoSelecionado!.longitude,
        );

        // Atualiza o estado com os dados recebidos
        setState(() {
          _pontoParadaConfirmado = _pontoSelecionado;
          _enderecoAtual = endereco.formattedAddress;  // Usa o endereço formatado corretamente
          _viaConfirmada = false;  // Reinicia o estado da via
        });

        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ponto confirmado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Mostra o erro no SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar o endereço: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum ponto selecionado para confirmar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      double segmentLength =
      const Distance().as(LengthUnit.Meter, start, end);

      if (distancia < distanciaMin) {
        distanciaMin = distancia;
        double projectionFactorOnSegment =
            const Distance().as(LengthUnit.Meter, start, projectedPoint) /
                segmentLength;
        projecaoMaisProxima = (accumulatedLength +
            projectionFactorOnSegment * segmentLength) /
            tamanhoTotal;
      }
      accumulatedLength += segmentLength;
    }

    return interpolateAlongLine(projecaoMaisProxima);
  }

  double tamanhoTotalLinha() {
    double length = 0.0;
    for (int i = 0; i < _consolidatedPoints.length - 1; i++) {
      length += const Distance()
          .as(LengthUnit.Meter, _consolidatedPoints[i], _consolidatedPoints[i + 1]);
    }
    return length;
  }

  LatLng interpolateAlongLine(double factor) {
    double targetDistance = factor * tamanhoTotalLinha();
    double accumulatedDistance = 0.0;

    for (int i = 0; i < _consolidatedPoints.length - 1; i++) {
      LatLng start = _consolidatedPoints[i];
      LatLng end = _consolidatedPoints[i + 1];
      double segmentLength =
      const Distance().as(LengthUnit.Meter, start, end);

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

/*  Future<void> _baixarTilesBrasilia() async {
    setState(() {
      _baixando = true;
    });
    //área de Brasília usando um retângulo aproximado
    final region = RectangleRegion(
      LatLngBounds(
        const LatLng(-15.95, -48.05), // Sudoeste
        const LatLng(-15.75, -47.85), // Nordeste
      ),
    );

    try {
      // Convertendo para uma região de download com zoom e parâmetros do servidor de tiles (camada do mapa)
      final downloadableRegion = region.toDownloadable(
        minZoom: 10,
        maxZoom: 19,
        options: TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ponto.parada.frontend',
        ),
      );

      final downloadResult = await _store.download.startForeground(
        region: downloadableRegion,
      );

      // Escutando o progresso do download
      _downloadProgressSubscription = downloadResult.downloadProgress.listen((progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress.percentageProgress / 100.0;
          });
        }

        if (progress.percentageProgress == 100 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download de tiles concluído!')),
          );
        }
      });


    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao baixar a camada do mapa: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _baixando = false;
        });
      }
    }
  }
*/
  // Método para obter a localização do usuário
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation ?? const LatLng(-15.7942, -47.8822),
                initialZoom: 17.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onMapEvent: (event) {
                  if (mounted) {
                    setState(() {
                      _pontoSelecionado = _mapController.camera.center;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ponto.parada.frontend',
                  tileProvider: _tileProvider,
                ),
                if (_userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLocation!,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
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
                            color: Colors.green,
                            size: 45,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_pontoInterpolado != null)
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
                /*if (_baixando)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ProgressoDownloadWidget(progresso: _downloadProgress),
                  ),
                 */
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
            bottom: 60,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _viaConfirmada
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormularioParadaTela(
                      latLng: _pontoParadaConfirmado!,
                      initialData: {'endereco': _enderecoAtual},
                      latLongInterpolado:
                      '${_pontoInterpolado!.latitude}, ${_pontoInterpolado!.longitude}',
                    ),
                  ),
                );
              }
                  : (_pontoParadaConfirmado == null ? _confirmarPonto : _confirmarVia),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: _viaConfirmada
                    ? Colors.green
                    : (_pontoParadaConfirmado == null ? Colors.blue : Colors.orange),
              ),
              child: Text(
                _viaConfirmada
                    ? 'Cadastrar Ponto de Parada'
                    : (_pontoParadaConfirmado == null
                    ? 'Confirmar Ponto Parada'
                    : 'Confirmar Via da Parada'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (_pontoSelecionado != null &&
              _pontoParadaConfirmado != null &&
              _pontoInterpolado != null &&
              _viaConfirmada)  // Exibe o botão somente se houver marcadores
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
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
              onPressed: _centralizarLocalizacaoUsuario,
              child: const Icon(Icons.my_location),
              tooltip: 'Minha localização',
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}