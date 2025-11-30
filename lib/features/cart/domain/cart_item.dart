// lib/features/cart/domain/cart_item.dart

class CartItem {
  /// ID interno del carrito (no es el ID real de la BD).
  /// Lo estamos generando en CartProvider con:
  /// 'home-...', 'search-...', 'kitchen-...'
  final String id;

  /// ID real del producto en la base de datos (Product.id)
  final int productId;

  /// ID real de la cocina en la base de datos (Cocina.id)
  final int kitchenId;

  final String name;
  final String kitchenName;
  final int price; // precio unitario en pesos
  int quantity;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.productId,
    required this.kitchenId,
    required this.name,
    required this.kitchenName,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });

  int get total => price * quantity;
}
