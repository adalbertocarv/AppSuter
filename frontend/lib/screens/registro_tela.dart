import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../providers/ponto_parada_provider.dart';
import '../services/gravar_ponto_parada_service.dart';
import 'formulario_parada_tela.dart';

class RegistroTela extends StatelessWidget {
  const RegistroTela({Key? key}) : super(key: key);

  Future<void> _enviarParadas(BuildContext context) async {
    final provider = Provider.of<PointProvider>(context, listen: false);
    final points = provider.points;

    if (points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma parada para enviar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool houveErro = false;

    for (var point in points) {
      final sucesso = await PontoParadaService.criarPonto(
        endereco: point['endereco'],
        haAbrigo: point['haAbrigo'],
        tipoAbrigo: point['tipoAbrigo'],
        patologias: point['patologias'],
        acessibilidade: point['acessibilidade'],
        linhasTransporte: point['linhasTransporte'],
        longitude: point['longitude'],
        latitude: point['latitude'],
        ativo: point['ativo'],
        imagensPaths: List<String>.from(point['imagensPaths'] ?? []),
        latLongInterpolado: point['latLongInterpolado'] ?? '', sentido: '', tipo: '',
      );

      if (!sucesso) {
        houveErro = true;
      }
    }

    if (!houveErro) {
      // Limpa as paradas locais após envio bem-sucedido
      provider.clearPoints();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as paradas foram enviadas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro ao enviar algumas paradas.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = Provider.of<PointProvider>(context).points;

    return Scaffold(
      body: points.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(80.0),
          child: Text(
            'Paradas criadas estarão disponíveis aqui para gravar ao banco de dados',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      )
          : ListView.builder(
        itemCount: points.length,
        itemBuilder: (ctx, index) {
          final point = points[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: point['imagensPaths'] != null && point['imagensPaths'].isNotEmpty
                  ? Image.file(
                File(point['imagensPaths'][0]),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(
                Icons.location_on,
                size: 40,
                color: Colors.blue,
              ),
              title: Text(
                point['endereco'].length > 40
                    ? '${point['endereco'].substring(0, 37)}...'
                    : point['endereco'],
                overflow: TextOverflow.ellipsis, // Garante o truncamento se necessário
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Há Abrigo: ${point['haAbrigo'] ? 'Sim' : 'Não'}'),
                  if (point['haAbrigo'] && point['tipoAbrigo'] != null)
                    Text('Tipo de Abrigo: ${point['tipoAbrigo']}'),
                  Text('Patologias: ${point['patologias'] ? 'Sim' : 'Não'}'),
                  Text('Acessibilidade: ${point['acessibilidade'] ? 'Sim' : 'Não'}'),
                  Text('Linhas de Transporte: ${point['linhasTransporte'] ? 'Sim' : 'Não'}'),
                  Text('Ativo: ${point['ativo'] ? 'Sim' : 'Não'}'),
                  Text(
                    'Lat: ${point['latitude']}, Lon: ${point['longitude']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => FormularioParadaTela(
                              latLng: LatLng(point['latitude'], point['longitude']),
                              initialData: point,
                              latLongInterpolado: point['latLongInterpolado'] ?? '',
                              index: index, // Passa o índice do ponto atual
                            ),
                          ),
                        );
                      }
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Provider.of<PointProvider>(context, listen: false)
                          .removePoint(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Parada removida.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _enviarParadas(context),
        child: const Icon(Icons.cloud_upload),
        tooltip: 'Enviar Paradas ao Banco de Dados',
      ),
    );
  }
}
