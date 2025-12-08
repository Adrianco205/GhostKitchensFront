import 'product_dto.dart';

class KitchenDto {
  final int id;
  final String nombre;
  final String imagenUrl;
  final String descripcion;
  final String ubicacion;
  final List<ProductDto> productos; // Lista de platos (puede venir vacía en el home)

  KitchenDto({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.descripcion,
    required this.ubicacion,
    this.productos = const [],
  });

  factory KitchenDto.fromJson(Map<String, dynamic> json) {
    var listProductos = json['productos'] as List? ?? [];
    List<ProductDto> productosList = listProductos
        .map((i) => ProductDto.fromJson(i))
        .toList();

    return KitchenDto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      // Mapeamos snake_case (backend) a camelCase (Dart)
      imagenUrl: json['imagen_url'] ?? 'https://via.placeholder.com/300',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      productos: productosList,
    );
  }
}