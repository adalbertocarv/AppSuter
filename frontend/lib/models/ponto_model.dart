import 'package:isar/isar.dart';

part 'ponto_model.g.dart';

@collection
class PontoModel {
  Id id = Isar.autoIncrement;

  late int idUsuario;
  late String endereco;
  late double latitude;
  late double longitude;
  late bool linhaEscolares;
  late bool linhaStpc;
  late double latitudeInterpolado;
  late double longitudeInterpolado;
  late String dataVisita;
  late bool pisoTatil;
  late bool rampa;
  late bool patologia;
  late bool baia;
  late List<AbrigoModel> abrigos;
  late List<String> imgBlobPaths;
  late List<String> imagensPatologiaPaths;
}

@embedded
class AbrigoModel {
  int? idTipoAbrigo;
  bool temPatologia = false;
  List<String> imgBlobPaths = [];
  List<String> imagensPatologiaPaths = [];
}
