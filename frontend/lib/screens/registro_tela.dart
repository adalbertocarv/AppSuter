import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';
import '../services/gravar_ponto_parada_service.dart';
import 'formulario_parada_tela.dart';
import 'package:latlong2/latlong.dart';

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
        sentido: point['sentido'],
        tipo: point['tipo'],
        longitude: point['longitude'],
        latitude: point['latitude'],
        ativo: point['ativo'],
        imagemPath: point['imagemPath'],
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
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(80.0), // Deadzone
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
            margin:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: point['imagemPath'] != null
                  ? Image.file(
                File(point['imagemPath']),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(
                Icons.location_on,
                size: 40,
                color: Colors.blue,
              ),
              title: Text(point['endereco']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sentido: ${point['sentido']}'),
                  Text('Tipo: ${point['tipo']}'),
                  Text('Ativo: ${point['ativo'] ? 'Sim' : 'Não'}'),
                  Text(
                    'Lat: ${point['latitude']}, Lon: ${point['longitude']}',
                    style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
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
                            latLng: LatLng(
                              point['latitude'],
                              point['longitude'],
                            ),
                            initialData: point, // Passa os dados para edição
                          ),
                        ),
                      );
                    },
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
