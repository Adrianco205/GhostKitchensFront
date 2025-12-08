import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/orders/data/datasource/orders_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/orders/data/models/order_dto.dart';
import 'package:ghost_kitchens_app/features/orders/presentation/pages/order_detail_page.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  late Future<List<OrderHistoryDto>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = OrdersRemoteDataSource(ApiClient()).getHistory();
  }

  Color _getStatusColor(String status) {
    if (status == 'PAGADO' || status == 'CONFIRMADO') return Colors.green;
    if (status == 'CANCELADO') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Pedidos")),
      body: FutureBuilder<List<OrderHistoryDto>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No has realizado pedidos aún."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return Card(
                color: const Color(0xFF1E2029),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text("Pedido #${order.id}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.fecha), style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(height: 4),
                      Text("${order.cantidadItems} productos • \$${order.total.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.estado).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(order.estado)),
                    ),
                    child: Text(order.estado, style: TextStyle(color: _getStatusColor(order.estado), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}