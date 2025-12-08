import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para formateo de inputs
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/provider/cart_provider.dart';
import 'package:ghost_kitchens_app/features/orders/data/datasource/orders_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/shell/presentation/pages/main_shell_page.dart';
import 'package:ghost_kitchens_app/features/orders/data/models/order_dto.dart';
class PaymentCardPage extends StatefulWidget {
  final CartProvider cart; // Recibimos el carrito para saber el total y limpiarlo

  const PaymentCardPage({super.key, required this.cart});

  @override
  State<PaymentCardPage> createState() => _PaymentCardPageState();
}

class _PaymentCardPageState extends State<PaymentCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;
  final OrdersRemoteDataSource _ordersService = OrdersRemoteDataSource(ApiClient());

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      // 1. Preparar datos del pedido
      final itemsDto = widget.cart.items.map((item) => OrderItemDto(
        productoId: item.product.id,
        cantidad: item.quantity,
      )).toList();

      final orderDto = OrderCreateDto(
        items: itemsDto,
        direccionId: 1, // ID fijo temporalmente
        metodoPago: "LINEA", // Forzamos método en línea
      );

      // 2. Enviar al Backend (Aquí el backend simula la demora de 2 seg)
      await _ordersService.createOrder(orderDto);

      if (!mounted) return;

      // 3. Éxito: Limpiar carrito y Navegar
      widget.cart.clearCart();

      _showSuccessDialog();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en el pago: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
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
            Text("¡Pago Aprobado!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Tu pedido ha sido registrado exitosamente.", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
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
            child: const Text("Volver al Inicio", style: TextStyle(color: Colors.orange)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Datos de la Tarjeta"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visualización Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Text("Total a Pagar", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      "\$${widget.cart.totalToPay.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const Text("Número de Tarjeta", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(16), FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration("0000 0000 0000 0000", Icons.credit_card),
                validator: (v) => (v!.length < 16) ? "Número inválido" : null,
              ),

              const SizedBox(height: 16),
              const Text("Nombre del Titular", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Como aparece en la tarjeta", Icons.person),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Vencimiento", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.datetime,
                          inputFormatters: [LengthLimitingTextInputFormatter(5)], // MM/YY
                          decoration: _inputDecoration("MM/AA", Icons.calendar_today),
                          validator: (v) => v!.isEmpty ? "Requerido" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("CVV", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [LengthLimitingTextInputFormatter(3)],
                          decoration: _inputDecoration("123", Icons.lock),
                          validator: (v) => v!.length < 3 ? "Inválido" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Pagar Ahora", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1E2029),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange)),
    );
  }
}