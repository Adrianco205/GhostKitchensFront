// lib/features/orders/domain/order_summary.dart

/// Estado de un pedido según el flujo de la app.
/// Mapea a: Confirmado → En preparación → En camino → Entregado / Cancelado.
enum OrderStatus {
  confirmado,
  enPreparacion,
  enCamino,
  entregado,
  cancelado,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.confirmado:
        return 'Confirmado';
      case OrderStatus.enPreparacion:
        return 'En preparación';
      case OrderStatus.enCamino:
        return 'En camino';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }

  bool get isFinal =>
      this == OrderStatus.entregado || this == OrderStatus.cancelado;
}

/// Ítem resumido dentro de un pedido (derivado del carrito).
class OrderItemSummary {
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;

  OrderItemSummary({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  double get total => price * quantity;
}

/// Resumen de un pedido para historial y seguimiento.
class OrderSummary {
  final int id;
  final DateTime createdAt;
  final double total;
  final String paymentMethod;
  final List<OrderItemSummary> items;

  OrderStatus status;
  String? cancelReason;

  OrderSummary({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.paymentMethod,
    required this.items,
    this.status = OrderStatus.confirmado,
    this.cancelReason,
  });
}
