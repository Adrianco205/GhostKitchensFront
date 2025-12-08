class ProductDto {
  final int id;
  final String nombre;
  final double precio;
  final String descripcion;
  final bool disponible;
  final String? imagenUrl; // <--- 1. NUEVO CAMPO (Puede ser null)

  ProductDto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.disponible,
    this.imagenUrl, // <--- 2. AGREGAR AL CONSTRUCTOR
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      descripcion: json['descripcion'] ?? '',
      disponible: json['disponible'] ?? true,
      imagenUrl: json['imagen_url'], // <--- 3. MAPEO EXACTO (debe coincidir con el backend)
    );
  }
}