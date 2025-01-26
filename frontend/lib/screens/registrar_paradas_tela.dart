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
            latLng: _selectedPoint!, initialData: {},
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
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: const LatLng(-15.7942, -47.8822), // Brasília como centro padrão
                    zoom: 17.0,
                    interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedPoint = point; // Atualiza o ponto selecionado
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
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Align(
                    alignment: Alignment.bottomCenter, //botão no centro
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: ElevatedButton(
                        onPressed: _confirmPoint,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text('Confirmar Ponto'),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
