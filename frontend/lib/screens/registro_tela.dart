import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../providers/ponto_parada_provider.dart';
import '../services/gravar_paradas_service.dart';
import 'formulario_parada_tela.dart';

class RegistroTela extends StatefulWidget {
  const RegistroTela({Key? key}) : super(key: key);

  @override
  _RegistroTelaState createState() => _RegistroTelaState();
}

class _RegistroTelaState extends State<RegistroTela> {
  bool _isLoading = false;


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

    setState(() {
      _isLoading = true;
    });

    bool houveErro = false;

    for (var point in points) {
      final sucesso = await PontoParadaService.criarPonto(
        idUsuario: point['idUsuario'],
        endereco: point['endereco'],
        latitude: point['latitude'],
        longitude: point['longitude'],
        linhaEscolares: point['LinhaEscolares'] ?? false,
        linhaStpc: point['LinhaStpc'] ?? false,
        idTipoAbrigo: point['idTipoAbrigo'] ?? 0,
        latitudeInterpolado: point['latitudeInterpolado'] ?? point['latitude'],
        longitudeInterpolado: point['longitudeInterpolado'] ?? point['longitude'],
        dataVisita: point['DataVisita'] ?? DateTime.now().toIso8601String(),
        pisoTatil: point['PisoTatil'] ?? false,
        rampa: point['Rampa'] ?? false,
        patologia: point['Patologia'] ?? false,
        imgBlobPaths: List<String>.from(point['imgBlobPaths'] ?? []),
        imagensPatologiaPaths: List<String>.from(point['imagensPatologiaPaths'] ?? []),
      );

      if (!sucesso) {
        houveErro = true;
      }
    }

    if (!houveErro) {
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

    setState(() {
      _isLoading = false;
    });
  }

  @override
    Widget build(BuildContext context) {
      final points = Provider.of<PointProvider>(context).points;
      final provider = Provider.of<PointProvider>(context, listen: false);

      return Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : points.isEmpty
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
                    Text('Há Abrigo: ${(point['haAbrigo'] ?? false) ? 'Sim' : 'Não'}'),
                    if ((point['haAbrigo'] ?? false) && point['tipoAbrigo'] != null)
                      Text('Tipo de Abrigo: ${point['tipoAbrigo']}'),
                    Text('Patologias: ${(point['patologias'] ?? false) ? 'Sim' : 'Não'}'),
                    Text('Acessibilidade: ${(point['acessibilidade'] ?? false) ? 'Sim' : 'Não'}'),
                    Text('Linhas de Transporte: ${(point['linhasTransporte'] ?? false) ? 'Sim' : 'Não'}'),
                    Text(
                      'Lat: ${point['latitude'] ?? 'Desconhecido'}, Lon: ${point['longitude'] ?? 'Desconhecido'}',
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
                                latLng: LatLng(
                                  point['latitude'] is double
                                      ? point['latitude']
                                      : double.tryParse(point['latitude'].toString()) ?? 0.0,
                                  point['longitude'] is double
                                      ? point['longitude']
                                      : double.tryParse(point['longitude'].toString()) ?? 0.0,
                                ),
                                initialData: point,
                                latLongInterpolado: point['latLongInterpolado'] ?? '',
                                index: index,
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