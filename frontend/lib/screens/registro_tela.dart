import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../providers/ponto_parada_provider.dart';
import '../services/gravar_paradas_service.dart';
import 'carregamento_edicao_tela.dart';
import 'formulario_parada_tela.dart';

class RegistroTela extends StatefulWidget {
  const RegistroTela({Key? key}) : super(key: key);

  @override
  _RegistroTelaState createState() => _RegistroTelaState();
}

class _RegistroTelaState extends State<RegistroTela> {
  double _progresso = 0.0;


// Função auxiliar para formatar JSON no console
  void printJson(Map<String, dynamic> json) {
    const JsonEncoder encoder = JsonEncoder.withIndent("  ");
    print(encoder.convert(json));
  }

  void _confirmarExclusao(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Excluir parada"),
          content: const Text("Tem certeza que deseja remover esta parada?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Fecha o alerta sem excluir
              },
              child: const Text(
                  "Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // Remove a parada e fecha o alerta
                Provider.of<PointProvider>(context, listen: false)
                    .removerPontos(index);
                Navigator.of(ctx).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Parada removida.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text("Remover", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _enviarEmSegundoPlano(BuildContext context) {
    final envioStatus = Provider.of<EnvioStatus>(context, listen: false);
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

    envioStatus.iniciarEnvio();

    Future(() async {
      final antes = provider.points.length;

      await provider.enviarTodosOsPontosSeparadamente((progress) {
        envioStatus.atualizarProgresso(progress);
      });

      envioStatus.finalizarEnvio();

      final depois = provider.points.length;

      if (depois == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas as paradas foram enviadas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao enviar ${depois} de ${antes} paradas. Apenas ${antes - depois} foram enviadas.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EnvioStatus>(
        builder: (context, envioStatus, _) {
          if (envioStatus.emExecucao) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Enviando paradas...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Barra de progresso
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: envioStatus.progresso,
                          minHeight: 18,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Texto de percentual
                      Text(
                        '${(envioStatus.progresso * 100).toStringAsFixed(1)}% concluído',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          else {
            return Consumer<PointProvider>(
              builder: (context, pointProvider, child) {
                final points = pointProvider.points;

                return points.isEmpty
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
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                CarregamentoEdicao(
                                  pointData: {
                                    ...point,
                                    "imgBlobPaths": List<String>.from(
                                        point["imgBlobPaths"] ?? []),
                                    "imagensPatologiaPaths": List<String>.from(
                                        point["imagensPatologiaPaths"] ?? []),
                                    "abrigos": point['abrigos'] != null
                                        ? List<Map<String, dynamic>>.from(
                                        point['abrigos']).map((abrigo) =>
                                    {
                                      "idTipoAbrigo": abrigo["idTipoAbrigo"],
                                      "temPatologia": abrigo["temPatologia"] ??
                                          false,
                                      "imgBlobPaths": List<String>.from(
                                          abrigo["imgBlobPaths"] ?? []),
                                      "imagensPatologiaPaths": List<
                                          String>.from(
                                          abrigo["imagensPatologiaPaths"] ??
                                              []),
                                    }).toList()
                                        : [],
                                  },
                                  index: index,
                                ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              color: Colors.grey, width: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: (point['abrigos'] != null &&
                              point['abrigos'].isNotEmpty) &&
                              (point['abrigos'][0]['imgBlobPaths'] != null &&
                                  point['abrigos'][0]['imgBlobPaths']
                                      .isNotEmpty)
                              ? Image.file(
                            File(point['abrigos'][0]['imgBlobPaths'][0]),
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
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Há Abrigo: ${(point['idTipoAbrigo'] == 19 || !(point['haAbrigo'] ?? false))
                                    ? 'Não'
                                    : 'Sim'}',
                              ),
                              if ((point['haAbrigo'] ?? false) &&
                                  point['tipoAbrigo'] != null)
                                Text('Tipo de Abrigo: ${point['tipoAbrigo']}'),
                              Text(
                                'Patologias: ${((point['abrigos'] as List<
                                    dynamic>?)
                                    ?.any((abrigo) =>
                                abrigo['temPatologia'] == true) ?? false)
                                    ? 'Sim'
                                    : 'Não'}',
                              ),
                              Text('Acessibilidade: ${(point['PisoTatil'] ??
                                  false) ||
                                  (point['Rampa'] ?? false) ? 'Sim' : 'Não'}'),
                              Text(
                                  'Linhas de Transporte: ${(point['LinhaStpc'] ??
                                      false) ? 'Sim' : 'Não'}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          FormularioParadaTela(
                                            latLng: LatLng(
                                              double.tryParse(
                                                  point['latitude']
                                                      .toString()) ??
                                                  0.0,
                                              double.tryParse(
                                                  point['longitude']
                                                      .toString()) ??
                                                  0.0,
                                            ),
                                            latLongInterpolado: LatLng(
                                              double.tryParse(
                                                  point['latitudeInterpolado']
                                                      ?.toString() ?? '') ??
                                                  double.tryParse(
                                                      point['latitude']
                                                          .toString()) ??
                                                  0.0,
                                              double.tryParse(
                                                  point['longitudeInterpolado']
                                                      ?.toString() ?? '') ??
                                                  double.tryParse(
                                                      point['longitude']
                                                          .toString()) ?? 0.0,
                                            ),
                                            initialData: {
                                              ...point,
                                              "imgBlobPaths": List<String>.from(
                                                  point["imgBlobPaths"] ?? []),
                                              "imagensPatologiaPaths": List<
                                                  String>.from(
                                                  point["imagensPatologiaPaths"] ??
                                                      []),
                                              "abrigos": point['abrigos'] !=
                                                  null
                                                  ? List<
                                                  Map<String, dynamic>>.from(
                                                  point['abrigos']).map((
                                                  abrigo) =>
                                              {
                                                "idTipoAbrigo": abrigo["idTipoAbrigo"],
                                                "temPatologia": abrigo["temPatologia"] ??
                                                    false,
                                                "imgBlobPaths": List<
                                                    String>.from(
                                                    abrigo["imgBlobPaths"] ??
                                                        []),
                                                "imagensPatologiaPaths": List<
                                                    String>.from(
                                                    abrigo["imagensPatologiaPaths"] ??
                                                        []),
                                              }).toList()
                                                  : [],
                                            },
                                            index: index,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmarExclusao(context, index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: FloatingActionButton(
            onPressed: () => _enviarEmSegundoPlano(context),
            child: const Icon(Icons.cloud_upload),
            tooltip: 'Enviar Paradas ao Banco de Dados',
          ),
        ),
      ),
    );
  }
}