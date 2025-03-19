import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'formulario_parada_tela.dart';

class CarregamentoEdicao extends StatefulWidget {
  final Map<String, dynamic> pointData;
  final int index;

  const CarregamentoEdicao({
    required this.pointData,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  _CarregamentoEdicaoState createState() => _CarregamentoEdicaoState();
}

class _CarregamentoEdicaoState extends State<CarregamentoEdicao> {
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  /// Simula um carregamento de dados antes de abrir a tela de edição
  Future<void> _carregarDados() async {
    await Future.delayed(const Duration(seconds: 2)); // Simula o delay

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FormularioParadaTela(
          latLng: LatLng(
            double.tryParse(widget.pointData['latitude'].toString()) ?? 0.0,
            double.tryParse(widget.pointData['longitude'].toString()) ?? 0.0,
          ),
          latLongInterpolado: LatLng(
            double.tryParse(widget.pointData['latitudeInterpolado']?.toString() ?? '') ??
                double.tryParse(widget.pointData['latitude'].toString()) ??
                0.0,
            double.tryParse(widget.pointData['longitudeInterpolado']?.toString() ?? '') ??
                double.tryParse(widget.pointData['longitude'].toString()) ??
                0.0,
          ),
          initialData: widget.pointData,
          index: widget.index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Carregando edição...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
