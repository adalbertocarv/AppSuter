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
      // 🔹 Criar lista de abrigos formatada corretamente
      final List<Map<String, dynamic>> abrigosFormatados =
      List<Map<String, dynamic>>.from(point['abrigos'] ?? []);


      final sucesso = await PontoParadaService.criarPonto(
        idUsuario: point['idUsuario'] as int,
        endereco: point['endereco'] as String,
        latitude: point['latitude'] as double,
        longitude: point['longitude'] as double,
        linhaEscolares: point['LinhaEscolares'] as bool? ?? false,
        linhaStpc: point['LinhaStpc'] as bool? ?? false,
        latitudeInterpolado: point['latitudeInterpolado'] as double? ?? point['latitude'] as double,
        longitudeInterpolado: point['longitudeInterpolado'] as double? ?? point['longitude'] as double,
        dataVisita: point['DataVisita'] as String? ?? DateTime.now().toIso8601String(),
        pisoTatil: point['PisoTatil'] as bool? ?? false,
        rampa: point['Rampa'] as bool? ?? false,
        patologia: point['Patologia'] as bool? ?? false,
        baia: point['Baia'] as bool? ?? false,
        abrigos: abrigosFormatados,

      );

      if (!sucesso) {
        houveErro = true;
      }
    }

    if (!houveErro) {
      provider.limparPontos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as paradas foram enviadas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

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
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // Remove a parada e fecha o alerta
                Provider.of<PointProvider>(context, listen: false).removerPontos(index);
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

  @override
  Widget build(BuildContext context) {
    final points = Provider.of<PointProvider>(context).points;
    Provider.of<PointProvider>(context, listen: false);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<PointProvider>( // Aqui garantimos a atualização automática!
        builder: (context, pointProvider, child) {
          final points = pointProvider.points; // Obtendo os pontos do Provider

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
                      builder: (ctx) => CarregamentoEdicao(
                        pointData: {
                          ...point,
                          "imgBlobPaths": List<String>.from(point["imgBlobPaths"] ?? []),
                          "imagensPatologiaPaths": List<String>.from(point["imagensPatologiaPaths"] ?? []),
                          "abrigos": point['abrigos'] != null
                              ? List<Map<String, dynamic>>.from(point['abrigos']).map((abrigo) => {
                            "idTipoAbrigo": abrigo["idTipoAbrigo"],
                            "temPatologia": abrigo["temPatologia"] ?? false,
                            "imgBlobPaths": List<String>.from(abrigo["imgBlobPaths"] ?? []),
                            "imagensPatologiaPaths": List<String>.from(abrigo["imagensPatologiaPaths"] ?? []),
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
                    side: const BorderSide(color: Colors.grey, width: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: (point['abrigos'] != null && point['abrigos'].isNotEmpty) &&
                        (point['abrigos'][0]['imgBlobPaths'] != null && point['abrigos'][0]['imgBlobPaths'].isNotEmpty)
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
                        Text('Há Abrigo: ${(point['haAbrigo'] ?? false) ? 'Sim' : 'Não'}'),
                        if ((point['haAbrigo'] ?? false) && point['tipoAbrigo'] != null)
                          Text('Tipo de Abrigo: ${point['tipoAbrigo']}'),
                        Text(
                          'Patologias: ${((point['abrigos'] as List<dynamic>?)?.any((abrigo) => abrigo['temPatologia'] == true) ?? false) ? 'Sim' : 'Não'}',
                        ),
                        Text('Acessibilidade: ${(point['PisoTatil'] ?? false) || (point['Rampa'] ?? false) ? 'Sim' : 'Não'}'),
                        Text('Linhas de Transporte: ${(point['LinhaStpc'] ?? false) ? 'Sim' : 'Não'}'),
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
                                    double.tryParse(point['latitude'].toString()) ?? 0.0,
                                    double.tryParse(point['longitude'].toString()) ?? 0.0,
                                  ),
                                  latLongInterpolado: LatLng(
                                    double.tryParse(point['latitudeInterpolado']?.toString() ?? '') ??
                                        double.tryParse(point['latitude'].toString()) ?? 0.0,
                                    double.tryParse(point['longitudeInterpolado']?.toString() ?? '') ??
                                        double.tryParse(point['longitude'].toString()) ?? 0.0,
                                  ),
                                  initialData: {
                                    ...point,
                                    "imgBlobPaths": List<String>.from(point["imgBlobPaths"] ?? []),
                                    "imagensPatologiaPaths": List<String>.from(point["imagensPatologiaPaths"] ?? []),
                                    "abrigos": point['abrigos'] != null
                                        ? List<Map<String, dynamic>>.from(point['abrigos']).map((abrigo) => {
                                      "idTipoAbrigo": abrigo["idTipoAbrigo"],
                                      "temPatologia": abrigo["temPatologia"] ?? false,
                                      "imgBlobPaths": List<String>.from(abrigo["imgBlobPaths"] ?? []),
                                      "imagensPatologiaPaths": List<String>.from(abrigo["imagensPatologiaPaths"] ?? []),
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
                          icon: const Icon(Icons.delete, color: Colors.red),
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
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70), // Move 70px para cima
          child: FloatingActionButton(
            onPressed: () => _enviarParadas(context),
            child: const Icon(Icons.cloud_upload),
            tooltip: 'Enviar Paradas ao Banco de Dados',
          ),
        ),
      ),
    );
  }
}