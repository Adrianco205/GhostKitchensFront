class CartItem {
  final int id;
  final String name;
  final double price;
  int quantity;
  final String? imageUrl;
  final String? kitchenName;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.kitchenName,
  });

  double get total => price * quantity;
}
