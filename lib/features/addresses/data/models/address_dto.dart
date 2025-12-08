class AddressDto {
  final int? id;
  final String direccionExacta;
  final String departamento;
  final String municipio;
  final String barrio;
  final String? apartamentoCasa;
  final String? indicaciones;

  AddressDto({
    this.id,
    required this.direccionExacta,
    required this.departamento,
    required this.municipio,
    required this.barrio,
    this.apartamentoCasa,
    this.indicaciones,
  });

  // De JSON (Backend snake_case) a Dart (camelCase)
  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      id: json['id'],
      direccionExacta: json['direccion_exacta'] ?? '',
      departamento: json['departamento'] ?? '',
      municipio: json['municipio'] ?? '',
      barrio: json['barrio'] ?? '',
      apartamentoCasa: json['apartamento_casa'],
      indicaciones: json['indicaciones'],
    );
  }

  // De Dart (camelCase) a JSON (Backend snake_case)
  Map<String, dynamic> toJson() {
    return {
      'direccion_exacta': direccionExacta,
      'departamento': departamento,
      'municipio': municipio,
      'barrio': barrio,
      'apartamento_casa': apartamentoCasa,
      'indicaciones': indicaciones,
    };
  }
}