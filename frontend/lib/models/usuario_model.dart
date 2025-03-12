class UsuarioModel {
  final int IdUsuario;
  final String NomeUsuario;
  final String MatriculaUsuario;
  final String EmailUsuario;
  final String SenhaUsuario;

  UsuarioModel({
    required this.IdUsuario,
    required this.NomeUsuario,
    required this.MatriculaUsuario,
    required this.EmailUsuario,
    required this.SenhaUsuario
  });

  // Convertendo JSON para o modelo
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      IdUsuario: json['IdUsuario'],
      NomeUsuario: json['NomeUsuario'],
      MatriculaUsuario: json['NomeUsuario'],
      EmailUsuario: json['EmailUsuario'],
      SenhaUsuario: json['SenhaUsuario'],
    );
  }
}
