class ProductDto {
  final int id;
  final String nombre;
  final double precio;
  final String descripcion;
  final bool disponible;

  ProductDto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.disponible,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      // Aseguramos que el precio sea double incluso si viene como int
      precio: (json['precio'] ?? 0).toDouble(),
      descripcion: json['descripcion'] ?? '',
      disponible: json['disponible'] ?? true,
    );
  }
}