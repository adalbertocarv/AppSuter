class BaciaModel {
  final int idBacia;
  final String descBacia;
  final String codBacia;
  final Map<String, dynamic> geoJson;

  BaciaModel({
    required this.idBacia,
    required this.descBacia,
    required this.codBacia,
    required this.geoJson,
  });

  factory BaciaModel.fromJson(Map<String, dynamic> json) {
    return BaciaModel(
      idBacia: json['idBacia'],
      descBacia: json['descBacia'],
      codBacia: json['codBacia'].toString(),
      geoJson: json['geoBacia'],
    );
  }
}