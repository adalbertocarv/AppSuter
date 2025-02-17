import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/enderecoOSM_service.dart';

class MapaConsultaScreen extends StatefulWidget {
  @override
  _MapaConsultaScreenState createState() => _MapaConsultaScreenState();
}

class _MapaConsultaScreenState extends State<MapaConsultaScreen> {
  final MapController _mapController = MapController();
  final EnderecoService _enderecoService = EnderecoService();  // Instância do serviço
  String? _enderecoAtual;

/*  Future<void> _buscarEndereco(LatLng coordenadas) async {
    try {
      final endereco = await _enderecoService.buscarEndereco(
          coordenadas.latitude, coordenadas.longitude);

      setState(() {
        _enderecoAtual = endereco.displayName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Endereço: ${endereco.displayName}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar endereço: $e')),
      );
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de Endereço no Mapa')),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(-15.7942, -47.8822),  // Brasília como ponto inicial
          initialZoom: 13.0,
         /* onTap: (tapPosition, latlng) {
            _buscarEndereco(latlng);  // Consulta o endereço ao clicar no mapa
          },*/
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ponto.parada.frontend',
          ),
        ],
      ),
      floatingActionButton: _enderecoAtual != null
          ? FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Endereço Selecionado'),
              content: Text(_enderecoAtual!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        },
        label: const Text('Ver Endereço'),
        icon: const Icon(Icons.location_on),
      )
          : Container(),
    );
  }
}
