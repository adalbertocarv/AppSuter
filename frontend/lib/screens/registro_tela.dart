import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../providers/ponto_parada_provider.dart';
import '../models/ponto_model.dart';
import '../services/gravar_paradas_service.dart';
import 'carregamento_edicao_tela.dart';
import 'formulario_parada_tela.dart';

class RegistroTela extends StatefulWidget {
  const RegistroTela({Key? key}) : super(key: key);

  @override
  State<RegistroTela> createState() => _RegistroTelaState();
}

class _RegistroTelaState extends State<RegistroTela> {
  void _confirmarExclusao(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir parada"),
        content: const Text("Tem certeza que deseja remover esta parada?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PontoProvider>(context, listen: false).removerPonto(index);
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
      ),
    );
  }

  void _enviarEmSegundoPlano(BuildContext context) {
    final envioStatus = Provider.of<EnvioStatus>(context, listen: false);
    final provider = Provider.of<PontoProvider>(context, listen: false);
    final pontos = provider.pontos;

    if (pontos.isEmpty) {
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
      int enviadosComSucesso = 0;

      for (int i = 0; i < pontos.length; i++) {
        final ponto = pontos[i];
        final abrigos = ponto.abrigos.map((abrigo) => {
          "idTipoAbrigo": abrigo.idTipoAbrigo,
          "temPatologia": abrigo.temPatologia,
          "imgBlobPaths": abrigo.imgBlobPaths,
          "imagensPatologiaPaths": abrigo.imagensPatologiaPaths,
        }).toList();

        final sucesso = await PontoParadaService.criarPonto(
          idUsuario: ponto.idUsuario,
          endereco: ponto.endereco,
          latitude: ponto.latitude,
          longitude: ponto.longitude,
          linhaEscolares: ponto.linhaEscolares,
          linhaStpc: ponto.linhaStpc,
          latitudeInterpolado: ponto.latitudeInterpolado,
          longitudeInterpolado: ponto.longitudeInterpolado,
          dataVisita: ponto.dataVisita,
          pisoTatil: ponto.pisoTatil,
          rampa: ponto.rampa,
          patologia: ponto.patologia,
          baia: ponto.baia,
          abrigos: abrigos,
          onProgress: (progress) {
            final globalProgress = (i + progress) / pontos.length;
            envioStatus.atualizarProgresso(globalProgress);
          },
        );

        if (sucesso) {
          enviadosComSucesso++;
        } else {
          debugPrint('Erro ao enviar ponto ${i + 1}');
        }
      }

      envioStatus.finalizarEnvio();

      if (enviadosComSucesso == pontos.length) {
        await provider.limparPontos();
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
                'Erro ao enviar ${pontos.length - enviadosComSucesso} de ${pontos.length} paradas.'),
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
              children: [
                const Text('Enviando paradas...', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LinearProgressIndicator(value: envioStatus.progresso),
                ),
              ],
            );
          }

          return Consumer<PontoProvider>(
            builder: (context, pontoProvider, _) {
              final pontos = pontoProvider.pontos;

              if (pontos.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(80.0),
                    child: Text(
                      'Paradas criadas estarão disponíveis aqui para gravar ao banco de dados',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: pontos.length,
                itemBuilder: (ctx, index) {
                  final ponto = pontos[index];
                  final abrigo = ponto.abrigos.isNotEmpty ? ponto.abrigos.first : null;

                  return Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey, width: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarregamentoEdicao(
                            pointData: {
                              "idUsuario": ponto.idUsuario,
                              "endereco": ponto.endereco,
                              "latitude": ponto.latitude,
                              "longitude": ponto.longitude,
                              "linhaEscolares": ponto.linhaEscolares,
                              "linhaStpc": ponto.linhaStpc,
                              "latitudeInterpolado": ponto.latitudeInterpolado,
                              "longitudeInterpolado": ponto.longitudeInterpolado,
                              "dataVisita": ponto.dataVisita,
                              "pisoTatil": ponto.pisoTatil,
                              "rampa": ponto.rampa,
                              "patologia": ponto.patologia,
                              "baia": ponto.baia,
                              "imgBlobPaths": ponto.imgBlobPaths,
                              "imagensPatologiaPaths": ponto.imagensPatologiaPaths,
                              "abrigos": ponto.abrigos.map((abrigo) => {
                                "idTipoAbrigo": abrigo.idTipoAbrigo,
                                "temPatologia": abrigo.temPatologia,
                                "imgBlobPaths": abrigo.imgBlobPaths,
                                "imagensPatologiaPaths": abrigo.imagensPatologiaPaths,
                              }).toList()
                            },
                            index: index,
                          ),
                        ),
                      ),
                      leading: abrigo != null && abrigo.imgBlobPaths.isNotEmpty
                          ? Image.file(File(abrigo.imgBlobPaths.first),
                          width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.location_on, size: 40, color: Colors.blue),
                      title: Text(
                        ponto.endereco.length > 40
                            ? '${ponto.endereco.substring(0, 37)}...'
                            : ponto.endereco,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Há Abrigo: ${ponto.abrigos.isNotEmpty ? 'Sim' : 'Não'}'),
                          Text('Patologias: ${ponto.abrigos.any((a) => a.temPatologia) ? 'Sim' : 'Não'}'),
                          Text('Acessibilidade: ${(ponto.pisoTatil || ponto.rampa) ? 'Sim' : 'Não'}'),
                          Text('Linhas de Transporte: ${ponto.linhaStpc ? 'Sim' : 'Não'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormularioParadaTela(
                                  latLng: LatLng(ponto.latitude, ponto.longitude),
                                  latLongInterpolado: LatLng(ponto.latitudeInterpolado, ponto.longitudeInterpolado),
                                  initialData: {}, // Caso deseje preencher no formulário
                                  index: index,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarExclusao(context, index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: () => _enviarEmSegundoPlano(context),
          child: const Icon(Icons.cloud_upload),
          tooltip: 'Enviar Paradas ao Banco de Dados',
        ),
      ),
    );
  }
}
