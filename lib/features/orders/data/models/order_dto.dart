// lib/features/orders/data/models/order_dto.dart

// --- DTO PARA CREAR PEDIDO (Lo que enviamos al backend) ---
class OrderItemDto {
  final int productoId;
  final int cantidad;

  OrderItemDto({required this.productoId, required this.cantidad});

  Map<String, dynamic> toJson() => {
    'producto_id': productoId,
    'cantidad': cantidad,
  };
}

class OrderCreateDto {
  final List<OrderItemDto> items;
  final int direccionId;
  final String metodoPago;

  OrderCreateDto({
    required this.items,
    required this.direccionId,
    required this.metodoPago,
  });

  Map<String, dynamic> toJson() => {
    'items': items.map((i) => i.toJson()).toList(),
    'direccion_id': direccionId,
    'metodo_pago': metodoPago,
  };
}

// --- DTO PARA HISTORIAL (Lo que recibimos del backend) ---
class OrderHistoryDto {
  final int id;
  final DateTime fecha;
  final double total;
  final String estado;
  final String metodoPago;
  final int cantidadItems;

  OrderHistoryDto({
    required this.id,
    required this.fecha,
    required this.total,
    required this.estado,
    required this.metodoPago,
    required this.cantidadItems,
  });

  factory OrderHistoryDto.fromJson(Map<String, dynamic> json) {
    return OrderHistoryDto(
      id: json['id'],
      // Parseamos la fecha ISO8601
      fecha: DateTime.parse(json['fecha']),
      total: (json['total'] ?? 0).toDouble(),
      estado: json['estado'] ?? 'PENDIENTE',
      metodoPago: json['metodo_pago'] ?? '',
      cantidadItems: json['cantidad_items'] ?? 0,
    );
  }
}

// --- DTO PARA DETALLE COMPLETO DEL PEDIDO ---
class OrderDetailItemDto {
  final String productoNombre;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  OrderDetailItemDto({
    required this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory OrderDetailItemDto.fromJson(Map<String, dynamic> json) {
    return OrderDetailItemDto(
      productoNombre: json['producto_nombre'] ?? 'Producto',
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: (json['precio_unitario'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}

class OrderFullDetailDto {
  final int id;
  final DateTime fecha;
  final String estado;
  final double total;
  final String metodoPago;
  final List<OrderDetailItemDto> items;

  OrderFullDetailDto({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.total,
    required this.metodoPago,
    required this.items,
  });

  factory OrderFullDetailDto.fromJson(Map<String, dynamic> json) {
    return OrderFullDetailDto(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      estado: json['estado'] ?? 'PENDIENTE',
      total: (json['total'] ?? 0).toDouble(),
      metodoPago: json['metodo_pago'] ?? '',
      items: (json['items'] as List?)
              ?.map((i) => OrderDetailItemDto.fromJson(i))
              .toList() ??
          [],
    );
  }
}