import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/ponto_model.dart';
import '../services/gravar_paradas_service.dart';

class PontoProvider with ChangeNotifier {
  final Isar isar;

  PontoProvider(this.isar) {
    carregarPontos();
  }

  List<PontoModel> _pontos = [];

  List<PontoModel> get pontos => [..._pontos];

  Future<void> carregarPontos() async {
    _pontos = await isar.pontoModels.where().findAll();
    notifyListeners();
  }

  Future<void> adicionarPonto(PontoModel ponto) async {
    await isar.writeTxn(() async => await isar.pontoModels.put(ponto));
    _pontos.add(ponto);
    notifyListeners();
  }

  Future<void> atualizarPonto(int index, PontoModel pontoAtualizado) async {
    final ponto = _pontos[index];
    pontoAtualizado.id = ponto.id;
    await isar.writeTxn(() => isar.pontoModels.put(pontoAtualizado));
    _pontos[index] = pontoAtualizado;
    notifyListeners();
  }

  Future<void> removerPonto(int index) async {
    final ponto = _pontos[index];
    await isar.writeTxn(() => isar.pontoModels.delete(ponto.id));
    _pontos.removeAt(index);
    notifyListeners();
  }

  Future<void> limparPontos() async {
    await isar.writeTxn(() async => await isar.pontoModels.clear());
    _pontos.clear();
    notifyListeners();
  }

  Future<void> enviarTodosOsPontosSeparadamente(void Function(double) onProgress) async {
    final List<PontoModel> pontosQueFalharam = [];
    final total = _pontos.length;

    for (int i = 0; i < total; i++) {
      final ponto = _pontos[i];
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
          final globalProgress = (i + progress) / total;
          onProgress(globalProgress);
        },
      );

      if (!sucesso) {
        pontosQueFalharam.add(ponto);
      }
    }

    await isar.writeTxn(() async {
      await isar.pontoModels.clear();
      await isar.pontoModels.putAll(pontosQueFalharam);
    });

    _pontos = pontosQueFalharam;
    notifyListeners();
  }
}

class EnvioStatus with ChangeNotifier {
  double progresso = 0.0;
  bool emExecucao = false;

  void atualizarProgresso(double value) {
    progresso = value;
    notifyListeners();
  }

  void iniciarEnvio() {
    emExecucao = true;
    progresso = 0.0;
    notifyListeners();
  }

  void finalizarEnvio() {
    emExecucao = false;
    progresso = 0.0;
    notifyListeners();
  }
}
