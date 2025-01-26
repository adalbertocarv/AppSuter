class UsuarioModel {
  final String email;
  final String token;

  UsuarioModel({required this.email, required this.token});

  // Convertendo JSON para o modelo
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      email: json['email'],
      token: json['token'],
    );
  }
}
