class EnderecoModel {
  final String displayName;

  EnderecoModel({required this.displayName});

  // Converte JSON para o objeto EnderecoModel
  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    return EnderecoModel(
      displayName: json['display_name'] ?? 'Endereço não encontrado',
    );
  }
}
