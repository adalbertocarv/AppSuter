import 'package:flutter/material.dart';
import 'package:frontend/models/ponto_model.dart';
import 'package:isar/isar.dart';

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
}
//envio segundo plano
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
