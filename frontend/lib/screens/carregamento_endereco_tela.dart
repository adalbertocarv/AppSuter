import 'package:flutter/material.dart';
import 'formulario_parada_tela.dart';
import 'package:latlong2/latlong.dart';

class CarregamentoTela extends StatelessWidget {
  final LatLng pontoParada;
  final Future<String> enderecoFuture;
  final LatLng pontoInterpolado;

  const CarregamentoTela({
    super.key,
    required this.pontoParada,
    required this.enderecoFuture,
    required this.pontoInterpolado,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: FutureBuilder<String>(
          future: enderecoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    "Buscando endereço...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 20),
                  const Text(
                    "Erro ao buscar endereço:",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Tentar novamente"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormularioParadaTela(
                                latLng: pontoParada,
                                initialData: {'endereco': ""}, // Envia vazio
                                latLongInterpolado: pontoInterpolado,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                        ),
                        child: const Text("Prosseguir sem endereço"),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              // Navegar automaticamente quando os dados estiverem carregados
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormularioParadaTela(
                      latLng: pontoParada,
                      initialData: {'endereco': snapshot.data ?? ""},
                      latLongInterpolado: pontoInterpolado,
                    ),
                  ),
                );
              });

              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
