class RaModel {
  final int idBacia;
  final String descNome;
  final String descPrefixoRa;
  final Map<String, dynamic> geoJson;

  RaModel({
    required this.idBacia,
    required this.descNome,
    required this.descPrefixoRa,
    required this.geoJson,
  });

  factory RaModel.fromJson(Map<String, dynamic> json) {
    return RaModel(
      idBacia: json['idBacia'],
      descNome: json['descNome'],
      descPrefixoRa: json['descPrefixoRa'],
      geoJson: json['geoRas'],
    );
  }
}