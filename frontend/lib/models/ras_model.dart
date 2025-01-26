class Ras {
  final Map<String, dynamic> geometry; // Geometria do recurso
  final Map<String, dynamic>? properties; // Propriedades opcionais

  Ras({required this.geometry, this.properties});

  factory Ras.fromJson(Map<String, dynamic> json) {
    return Ras(
      geometry: json['geometry'], // Acessa a geometria diretamente
      properties: json['properties'], // Acessa as propriedades (opcional)
    );
  }
}
