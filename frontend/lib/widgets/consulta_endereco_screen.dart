import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaConsultaScreen extends StatefulWidget {
  @override
  _MapaConsultaScreenState createState() => _MapaConsultaScreenState();
}

class _MapaConsultaScreenState extends State<MapaConsultaScreen> {
  final MapController _mapController = MapController();
// Instância do serviço
  String? _enderecoAtual;


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
