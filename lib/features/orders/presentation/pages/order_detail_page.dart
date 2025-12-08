import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/orders/data/datasource/orders_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/orders/data/models/order_dto.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<OrderFullDetailDto> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = OrdersRemoteDataSource(ApiClient()).getOrderDetail(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle Pedido #${widget.orderId}")),
      body: FutureBuilder<OrderFullDetailDto>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text("Error al cargar detalle"));

          final order = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado Gigante
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                      const SizedBox(height: 8),
                      Text(order.estado, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.fecha), style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const Divider(height: 40),

                const Text("Productos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),

                // Lista de Items
                ...order.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1E2029), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productoNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          Text("${item.cantidad} x \$${item.precioUnitario.toStringAsFixed(0)}", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Text("\$${item.subtotal.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                    ],
                  ),
                )),

                const Divider(height: 40),

                // Totales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Método de Pago", style: TextStyle(color: Colors.grey)),
                    Text(order.metodoPago, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Pagado", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("\$${order.total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}