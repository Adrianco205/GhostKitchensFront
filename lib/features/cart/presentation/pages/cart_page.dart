import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/provider/cart_provider.dart';
import 'package:ghost_kitchens_app/features/orders/data/datasource/orders_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/shell/presentation/pages/main_shell_page.dart';
import 'package:ghost_kitchens_app/features/orders/data/models/order_dto.dart';
import 'package:ghost_kitchens_app/features/payments/presentation/pages/payment_card_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito de Compras"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- LISTA DE PRODUCTOS ---
          Expanded(
            child: cart.items.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final imageUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(item.product.nombre)}&background=random&size=128';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2029),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "\$${item.product.precio.toStringAsFixed(0)} x ${item.quantity}",
                                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                  ),
                                  Text(
                                    "Total: \$${item.total.toStringAsFixed(0)}",
                                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                // TODO: Implementar eliminar
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // --- TOTAL Y BOTÓN DE PAGO ---
          if (cart.items.isNotEmpty)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2029),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total a Pagar", style: TextStyle(fontSize: 18, color: Colors.grey)),
                        Text(
                          "\$${cart.totalToPay.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _handlePaymentFlow(context, cart),
                        child: const Text(
                          "Seleccionar Pago",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("Tu carrito está vacío", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  // --- LÓGICA DE FLUJO DE PAGO ---
  Future<void> _handlePaymentFlow(BuildContext context, CartProvider cart) async {
    // 1. Abrimos el modal y esperamos respuesta (true/false)
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF0F111A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _PaymentModalContent(cart: cart),
    );

    // 2. Si el resultado es TRUE, significa que el pago fue EFECTIVO/DATÁFONO y exitoso.
    // (Si fue LINEA, el modal redirigió a otra pantalla y retornó false/null, así que no entra aquí).
    if (result == true) {
      if (!context.mounted) return;

      cart.clearCart();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E2029),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("¡Pedido Confirmado!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 8),
              Text("Tu comida fantasma está en camino 👻", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShellPage()),
                  (route) => false,
                );
              },
              child: const Text("Ir al Inicio", style: TextStyle(color: Colors.orange)),
            )
          ],
        ),
      );
    }
  }
}

// --- CONTENIDO DEL MODAL ---
class _PaymentModalContent extends StatefulWidget {
  final CartProvider cart;
  const _PaymentModalContent({required this.cart});

  @override
  State<_PaymentModalContent> createState() => _PaymentModalContentState();
}

class _PaymentModalContentState extends State<_PaymentModalContent> {
  String _selectedMethod = "EFECTIVO";
  bool _isProcessing = false;
  final OrdersRemoteDataSource _ordersService = OrdersRemoteDataSource(ApiClient());

  Future<void> _processPayment() async {
    // ---------------------------------------------------------
    // CASO 1: PAGO EN LÍNEA -> Redirigir a PaymentCardPage
    // ---------------------------------------------------------
    if (_selectedMethod == "LINEA") {
      Navigator.pop(context, false); // Cerramos modal (false para que CartPage no muestre éxito aún)

      // Navegamos a la pantalla de tarjeta
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentCardPage(cart: widget.cart),
        ),
      );
      return; // Terminamos aquí, PaymentCardPage se encarga del resto
    }

    // ---------------------------------------------------------
    // CASO 2: EFECTIVO O DATÁFONO -> Procesar directamente
    // ---------------------------------------------------------
    setState(() => _isProcessing = true);

    try {
      final itemsDto = widget.cart.items.map((item) => OrderItemDto(
        productoId: item.product.id,
        cantidad: item.quantity,
      )).toList();

      final orderDto = OrderCreateDto(
        items: itemsDto,
        direccionId: 1, // ID fijo temporalmente
        metodoPago: _selectedMethod,
      );

      await _ordersService.createOrder(orderDto);

      if (!mounted) return;

      // Retornamos TRUE para que CartPage muestre el diálogo de éxito
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          const Text("Método de pago", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          _PaymentOption(
            icon: Icons.money, title: "Efectivo", subtitle: "Pagas al recibir", value: "EFECTIVO",
            groupValue: _selectedMethod, onChanged: (val) => setState(() => _selectedMethod = val!),
          ),
          _PaymentOption(
            icon: Icons.credit_card, title: "Datáfono", subtitle: "Tarjeta contra entrega", value: "DATAFONO",
            groupValue: _selectedMethod, onChanged: (val) => setState(() => _selectedMethod = val!),
          ),
          _PaymentOption(
            icon: Icons.phonelink_ring, title: "Pago en línea", subtitle: "Simulación Wompi", value: "LINEA",
            groupValue: _selectedMethod, onChanged: (val) => setState(() => _selectedMethod = val!),
          ),

          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isProcessing ? null : () => Navigator.pop(context, false),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_selectedMethod == "LINEA" ? "Continuar" : "Confirmar Pedido",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({required this.icon, required this.title, required this.subtitle, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.orange : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E2029),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.orange : Colors.grey),
            const SizedBox(width: 16),
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}