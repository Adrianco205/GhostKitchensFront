// lib/features/cart/presentation/cart_provider.dart
import 'package:flutter/foundation.dart';

import 'package:ghost_kitchens_app/features/cart/domain/cart_item.dart';

// Para construir items desde distintas pantallas:
import 'package:ghost_kitchens_app/features/shell/data/models/home_dto.dart';
import 'package:ghost_kitchens_app/search/data/models/search_dto.dart';
import 'package:ghost_kitchens_app/kitchens/data/models/kitchen_detail_dto.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get totalAmount =>
      _items.values.fold(0, (sum, item) => sum + item.total);

  void _addInternal({
    required String id,
    required int productId,
    required int kitchenId,
    required String name,
    required String kitchenName,
    required int price,
    String? imageUrl,
  }) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(
        id: id,
        productId: productId,
        kitchenId: kitchenId,
        name: name,
        kitchenName: kitchenName,
        price: price,
        imageUrl: imageUrl,
      );
    }
    notifyListeners();
  }

  // ========= Desde HOME: ProductHomeDto =========
  void addFromProduct(ProductHomeDto p) {
    // Aquí SÍ tenemos todo: id de producto y de cocina
    final int productId = p.id;
    final int kitchenId = p.kitchenId;

    final id = 'home-$kitchenId-$productId';

    _addInternal(
      id: id,
      productId: productId,
      kitchenId: kitchenId,
      name: p.name,
      kitchenName: p.kitchenName,
      price: p.price.toInt(),
      imageUrl: p.imageUrl,
    );
  }

  // ========= Desde SEARCH: DishPreviewDto =========
  void addFromDish(DishPreviewDto d, String kitchenName) {
    // OJO: DishPreviewDto NO tiene id ni kitchenId en tu modelo actual.
    // Como no tenemos IDs reales de backend, metemos -1 para marcar
    // que este item NO se puede mandar al backend todavía.
    const int fakeProductId = -1;
    const int fakeKitchenId = -1;

    final id = 'search-$kitchenName-${d.name}';

    _addInternal(
      id: id,
      productId: fakeProductId,
      kitchenId: fakeKitchenId,
      name: d.name,
      kitchenName: kitchenName,
      price: d.price,
      imageUrl: d.imageUrl,
    );
  }

  // ========= Desde KITCHEN DETAIL: KitchenProductDto =========
  void addFromKitchenProduct(KitchenProductDto p, String kitchenName) {
    // Aquí SOLO tienes el id del producto. El id de la cocina no viene
    // en KitchenProductDto, sino en KitchenDetailDto (la pantalla lo sabe).
    //
    // Por ahora, como CartProvider no recibe el kitchenId aquí,
    // guardamos un valor "desconocido" (-1) y evitaremos procesar
    // pedidos con estos items en la pasarela de pago.
    const int fakeKitchenId = -1;
    final int productId = p.id;

    final id = 'kitchen-$kitchenName-${p.name}';

    _addInternal(
      id: id,
      productId: productId,
      kitchenId: fakeKitchenId,
      name: p.name,
      kitchenName: kitchenName,
      price: p.price.toInt(),
      imageUrl: p.imageUrl,
    );
  }

  // ========= Controles de cantidad =========
  void increment(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
      notifyListeners();
    }
  }

  void decrement(String id) {
    if (!_items.containsKey(id)) return;

    if (_items[id]!.quantity > 1) {
      _items[id]!.quantity -= 1;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
