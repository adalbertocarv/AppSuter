class EnderecoModel {
  final String office;
  final String road;
  final String neighbourhood;
  final String city;
  final String postcode;

  EnderecoModel({
    required this.office,
    required this.road,
    required this.neighbourhood,
    required this.city,
    required this.postcode,
  });

  // Converte JSON para o objeto EnderecoModel
  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};

    return EnderecoModel(
      office: address['office'] ?? '',
      road: address['road'] ?? '',
      neighbourhood: address['neighbourhood'] ?? '',
      city: address['city'] ?? '',
      postcode: address['postcode'] ?? '',
    );
  }

  // Gera a string formatada concatenando os campos
  String get formattedAddress {
    return [
      if (office.isNotEmpty) office,
      if (road.isNotEmpty) road,
      if (neighbourhood.isNotEmpty) neighbourhood,
      if (city.isNotEmpty) city,
      if (postcode.isNotEmpty) 'CEP: $postcode',
    ].join(', ');
  }
}