class AddressDto {
  final int? id;
  // Campos detallados que espera tu Backend actual
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

  // De Backend a Frontend
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

  // De Frontend a Backend
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