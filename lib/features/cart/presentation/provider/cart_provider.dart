import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/features/kitchens/data/models/product_dto.dart';

class CartItem {
  final ProductDto product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.precio * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalToPay => _items.fold(0, (sum, item) => sum + item.total);
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(ProductDto product) {
    // Verificar si ya existe para sumar cantidad
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners(); // Avisar a toda la app que el carrito cambió
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}