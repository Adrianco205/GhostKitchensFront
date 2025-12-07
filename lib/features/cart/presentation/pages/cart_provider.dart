// lib/features/cart/presentation/pages/cart_provider.dart

import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/features/cart/domain/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.total);

  /// ✅ Método genérico para agregar ítems al carrito
  /// Lo puedes usar desde ProductDetailPage, KitchenDetailPage, etc.
  void addItem({
    required int id,
    required String name,
    required double price,
    String? imageUrl,
    required String kitchenName,
  }) {
    final existingIndex = _items.indexWhere((i) => i.id == id);

    if (existingIndex != -1) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(
          id: id,
          name: name,
          price: price,
          quantity: 1,
          imageUrl: imageUrl,
          kitchenName: kitchenName,
        ),
      );
    }

    notifyListeners();
  }

  /// 🔁 Mantengo tu método original para compatibilidad,
  /// pero ahora delega al método tipado de arriba.
  void addFromKitchenProduct(dynamic product, String kitchenName) {
    addItem(
      id: product.id,
      name: product.name,
      price: product.price.toDouble(),
      imageUrl: product.imageUrl,
      kitchenName: kitchenName,
    );
  }

  /// Incrementar
  void increment(int id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// Decrementar
  void decrement(int id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Eliminar totalmente
  void remove(int id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  /// Vaciar carrito (se usa después de confirmar pedido)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
