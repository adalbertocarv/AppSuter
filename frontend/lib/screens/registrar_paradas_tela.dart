import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'formulario_parada_tela.dart';

class RegistrarParadaTela extends StatefulWidget {
  @override
  _RegistrarParadaTelaState createState() => _RegistrarParadaTelaState();
}

class _RegistrarParadaTelaState extends State<RegistrarParadaTela> {
  LatLng? _selectedPoint; // Stores the selected LatLng

  void _confirmPoint() {
    if (_selectedPoint != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormularioParadaTela(
            latLng: _selectedPoint!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um ponto no mapa!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: const LatLng(-15.7942, -47.8822), // Brasília as the default center
                zoom: 17.0,
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedPoint = point; // Update the selected point
                  });
                },
              ),

              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (_selectedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

          ),
          ElevatedButton(
            onPressed: _confirmPoint,
            child: const Text('Confirmar Ponto'),
          ),
        ],
      ),
    );
  }
}
