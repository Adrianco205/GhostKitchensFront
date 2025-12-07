// lib/features/orders/presentation/pages/order_history_provider.dart

import 'package:flutter/foundation.dart';

import 'package:ghost_kitchens_app/features/cart/domain/cart_item.dart';
import 'package:ghost_kitchens_app/features/orders/domain/order_summary.dart';

/// Provider que gestiona:
/// - Historial de pedidos (CUS-07)
/// - Pedido activo (para el botón flotante en Home)
/// - Cambios de estado y cancelación (CUS-08, CUS-09)
class OrderHistoryProvider extends ChangeNotifier {
  final List<OrderSummary> _orders = [];
  int _nextId = 1;

  int? _activeOrderId;

  List<OrderSummary> get orders => List.unmodifiable(_orders);

  /// Devuelve el pedido activo (no entregado ni cancelado), si existe.
  OrderSummary? get activeOrder {
    if (_activeOrderId == null) return null;
    try {
      return _orders.firstWhere((o) => o.id == _activeOrderId);
    } catch (_) {
      return null;
    }
  }

  /// Permite buscar un pedido por ID (útil para tracking).
  OrderSummary? getById(int id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Registrar un nuevo pedido a partir de los ítems del carrito.
  /// Usado en CUS-04/CUS-05 cuando se confirma el pedido.
  void registerOrder({
    required List<CartItem> items,
    required double total,
    required String metodoPago,
  }) {
    final now = DateTime.now();

    final orderItems = items
        .map(
          (i) => OrderItemSummary(
            name: i.name,
            quantity: i.quantity,
            price: i.price,
            imageUrl: i.imageUrl,
          ),
        )
        .toList();

    final order = OrderSummary(
      id: _nextId++,
      createdAt: now,
      total: total,
      paymentMethod: metodoPago,
      items: orderItems,
      status: OrderStatus.confirmado,
    );

    // Lo insertamos al inicio para que los más recientes queden arriba.
    _orders.insert(0, order);
    _activeOrderId = order.id;

    notifyListeners();
  }

  /// Actualizar el estado de un pedido (por ejemplo desde tracking).
  void updateStatus(int orderId, OrderStatus newStatus) {
    final order = getById(orderId);
    if (order == null) return;

    order.status = newStatus;

    if (order.status.isFinal && _activeOrderId == orderId) {
      _activeOrderId = null;
    }

    notifyListeners();
  }

  /// Cancelar pedido (CUS-09).
  void cancelOrder(int orderId, {String? reason}) {
    final order = getById(orderId);
    if (order == null) return;

    // Solo permite cancelar si está en estados iniciales
    if (order.status == OrderStatus.confirmado) {
      order.status = OrderStatus.cancelado;
      order.cancelReason = reason;

      if (_activeOrderId == orderId) {
        _activeOrderId = null;
      }

      notifyListeners();
    }
  }
}
