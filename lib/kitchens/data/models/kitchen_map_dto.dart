class KitchenMapDto {
  final int id;
  final String nombre;
  final double latitud;
  final double longitud;
  final String? logoUrl;

  KitchenMapDto({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    this.logoUrl,
  });

  factory KitchenMapDto.fromJson(Map<String, dynamic> json) {
    return KitchenMapDto(
      id: json['id'],
      nombre: json['nombre'],
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      logoUrl: json['logo_url'],
    );
  }
}
