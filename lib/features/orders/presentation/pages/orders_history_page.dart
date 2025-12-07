// lib/features/orders/presentation/pages/orders_history_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ghost_kitchens_app/features/orders/domain/order_summary.dart';
import 'package:ghost_kitchens_app/features/orders/presentation/pages/order_history_provider.dart';
import 'package:ghost_kitchens_app/features/orders/presentation/pages/order_tracking_page.dart';

/// Pantalla que muestra el historial de pedidos del cliente.
/// - Incluye pedidos entregados y cancelados.
/// - Desde aquí se puede entrar al detalle / tracking del pedido.
class OrdersHistoryPage extends StatelessWidget {
  const OrdersHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final orders = context.watch<OrderHistoryProvider>().orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de pedidos'),
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                'Aún no tienes pedidos registrados.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            ),
    );
  }
}

/// Tarjeta para cada pedido en el historial.
class _OrderCard extends StatelessWidget {
  final OrderSummary order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dateStr =
        '${order.createdAt.day.toString().padLeft(2, '0')}/'
        '${order.createdAt.month.toString().padLeft(2, '0')}/'
        '${order.createdAt.year} '
        '${order.createdAt.hour.toString().padLeft(2, '0')}:'
        '${order.createdAt.minute.toString().padLeft(2, '0')}';

    final statusLabel = order.statusLabel;
    final statusColor = order.statusColor;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderTrackingPage(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: #id + estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${order.id}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Fecha
              Text(
                'Realizado el $dateStr',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 8),

              // Total + método de pago
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Pago: ${order.paymentMethod}',
                style: theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 8),

              // Resumen de productos (ej: "2 productos")
              Text(
                '${order.items.length} producto(s)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extensiones de ayuda para mostrar el estado en texto y color.
/// (Si ya tienes algo similar en `order_summary.dart`, puedes borrar esto
///  o mantenerlo solo aquí para la capa de presentación).
extension OrderSummaryUiX on OrderSummary {
  String get statusLabel {
    switch (status) {
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

  Color get statusColor {
    switch (status) {
      case OrderStatus.confirmado:
        return Colors.blue;
      case OrderStatus.enPreparacion:
        return Colors.orange;
      case OrderStatus.enCamino:
        return Colors.deepPurple;
      case OrderStatus.entregado:
        return Colors.green;
      case OrderStatus.cancelado:
        return Colors.red;
    }
  }
}
