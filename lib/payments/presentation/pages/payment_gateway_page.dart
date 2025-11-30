// lib/payments/presentation/pages/payment_gateway_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/core/storage/secure_storage.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/cart_provider.dart';
import 'package:ghost_kitchens_app/features/cart/domain/cart_item.dart';

class PaymentGatewayPage extends StatefulWidget {
  final int addressId;

  const PaymentGatewayPage({
    super.key,
    required this.addressId,
  });

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  final TextEditingController _notesController = TextEditingController();

  // Campos para tarjeta
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  // Campo para Nequi/Daviplata
  final TextEditingController _phoneController = TextEditingController();

  bool _isProcessing = false;
  String? _errorMessage;
  String _selectedMethod = 'Tarjeta de crédito';

  @override
  void dispose() {
    _notesController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ---------- VALIDACIONES DE FORMATO ----------

  bool _isValidCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\s+'), '');
    // exactamente 16 dígitos
    return RegExp(r'^\d{16}$').hasMatch(digits);
  }

  bool _isValidExpiry(String value) {
    // Formato esperado MM/AA
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value.trim());
    if (match == null) return false;

    final mm = int.tryParse(match.group(1)!);
    final yy = int.tryParse(match.group(2)!);
    if (mm == null || yy == null) return false;
    if (mm < 1 || mm > 12) return false;

    final now = DateTime.now();
    final currentYear2 = now.year % 100;
    final currentMonth = now.month;

    // Año ya pasado
    if (yy < currentYear2) return false;
    // Mismo año pero mes pasado
    if (yy == currentYear2 && mm < currentMonth) return false;

    return true;
  }

  bool _isValidCvv(String value) {
    // exactamente 3 dígitos
    return RegExp(r'^\d{3}$').hasMatch(value.trim());
  }

  bool _isValidPhone(String value) {
    // Asumimos Colombia: 10 dígitos numéricos
    return RegExp(r'^\d{10}$').hasMatch(value.trim());
  }

  /// Valida los datos según el método de pago seleccionado.
  bool _validatePaymentFields() {
    if (_selectedMethod == 'Tarjeta de crédito' ||
        _selectedMethod == 'Tarjeta débito') {
      final number = _cardNumberController.text;
      final expiry = _cardExpiryController.text;
      final cvv = _cardCvvController.text;
      final holder = _cardHolderController.text;

      if (!_isValidCardNumber(number)) {
        _showSnack('Ingresa un número de tarjeta válido (16 dígitos).');
        return false;
      }
      if (!_isValidExpiry(expiry)) {
        _showSnack('Ingresa una fecha de vencimiento válida (MM/AA).');
        return false;
      }
      if (!_isValidCvv(cvv)) {
        _showSnack('Ingresa un CVV válido (3 dígitos).');
        return false;
      }
      if (holder.trim().isEmpty) {
        _showSnack('Ingresa el nombre del titular de la tarjeta.');
        return false;
      }
    } else if (_selectedMethod == 'Nequi / Daviplata') {
      final phone = _phoneController.text;
      if (!_isValidPhone(phone)) {
        _showSnack('Ingresa un número de celular válido (10 dígitos).');
        return false;
      }
    }
    // Efectivo contraentrega no requiere datos adicionales
    return true;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ---------- LÓGICA DE PAGO + CREACIÓN DE PEDIDOS ----------

  Future<void> _processPaymentAndCreateOrder(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final items = cart.items;

    if (items.isEmpty) {
      _showSnack('Tu carrito está vacío.');
      return;
    }

    // Validar datos de pago según método
    if (!_validatePaymentFields()) {
      return;
    }

    // 👉 Filtrar productos válidos (ignoramos silenciosamente los inválidos)
    final List<CartItem> validItems = items
        .where((it) => it.productId > 0 && it.kitchenId > 0)
        .toList();

    // Si no hay nada válido para enviar al backend
    if (validItems.isEmpty) {
      _showSnack(
        'No hay productos válidos en el carrito para procesar el pedido.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ApiClient();
      final storage = SecureStorage();

      final accessToken = await storage.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        setState(() {
          _errorMessage = 'Debes iniciar sesión para completar el pago.';
        });
        _isProcessing = false;
        return;
      }

      // Agrupar ítems por cocina: PERMITE MÚLTIPLES COCINAS
      final Map<int, List<CartItem>> itemsByKitchen = {};
      for (final it in validItems) {
        itemsByKitchen.putIfAbsent(it.kitchenId, () => []).add(it);
      }

      final List<int> createdOrderIds = [];

      for (final entry in itemsByKitchen.entries) {
        final kitchenId = entry.key;
        final kitchenItems = entry.value;

        final payload = {
          'kitchen_id': kitchenId,
          'address_id': widget.addressId,
          'notes': _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          'payment_method': _selectedMethod,
          'items': kitchenItems
              .map(
                (it) => {
                  'product_id': it.productId,
                  'quantity': it.quantity,
                  'notes': '',
                },
              )
              .toList(),
        };

        final response = await apiClient.post(
          '/pedidos/from-cart',
          data: payload,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        final data = response.data;
        final pedidoId = data['id'] as int;
        createdOrderIds.add(pedidoId);
      }

      // Limpia el carrito tras crear los pedidos
      cart.clear();

      if (!mounted) return;

      final String resumenPedidos = createdOrderIds.length == 1
          ? 'Número de pedido: ${createdOrderIds.first}'
          : 'Se crearon ${createdOrderIds.length} pedidos:\n'
              '${createdOrderIds.join(', ')}';

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Pago exitoso'),
          content: Text(
            'Tu pago se procesó correctamente.\n\n$resumenPedidos',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // cierra el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      // Vuelve al inicio
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on DioException catch (e) {
      String message = 'Ocurrió un error al procesar el pago.';

      if (e.response?.data is Map &&
          (e.response?.data as Map).containsKey('detail')) {
        message = (e.response?.data as Map)['detail'].toString();
      } else if (e.message != null) {
        message = e.message!;
      }

      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ---------- UI DINÁMICA SEGÚN MÉTODO DE PAGO ----------

  Widget _buildPaymentFields(ThemeData theme) {
    // Tarjeta crédito/débito
    if (_selectedMethod == 'Tarjeta de crédito' ||
        _selectedMethod == 'Tarjeta débito') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos de la tarjeta',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Número de tarjeta
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Número de tarjeta',
              hintText: '1234567812345678',
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              // Vencimiento MM/AA
              Expanded(
                child: TextField(
                  controller: _cardExpiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ExpiryDateTextInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Vencimiento',
                    hintText: 'MM/AA',
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // CVV (3 dígitos)
              Expanded(
                child: TextField(
                  controller: _cardCvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CVV',
                    hintText: '123',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nombre del titular
          TextField(
            controller: _cardHolderController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Nombre del titular',
            ),
          ),
        ],
      );
    }

    // Nequi / Daviplata
    if (_selectedMethod == 'Nequi / Daviplata') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Número de teléfono',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ej: 3001234567',
            ),
          ),
        ],
      );
    }

    // Efectivo contraentrega
    return Text(
      'Pagarás en efectivo al recibir tu pedido.',
      style: theme.textTheme.bodyMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final total = cart.totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasarela de pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Resumen de pago
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total a pagar',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '\$$total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Método de pago
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Método de pago',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: const [
                DropdownMenuItem(
                  value: 'Tarjeta de crédito',
                  child: Text('Tarjeta de crédito'),
                ),
                DropdownMenuItem(
                  value: 'Tarjeta débito',
                  child: Text('Tarjeta débito'),
                ),
                DropdownMenuItem(
                  value: 'Nequi / Daviplata',
                  child: Text('Nequi / Daviplata'),
                ),
                DropdownMenuItem(
                  value: 'Efectivo contraentrega',
                  child: Text('Efectivo contraentrega'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Notas
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notas para la cocina / repartidor',
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: Sin cebolla, tocar el timbre, etc.',
              ),
            ),
            const SizedBox(height: 16),

            // Campos específicos según el método de pago
            _buildPaymentFields(theme),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _processPaymentAndCreateOrder(context),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Pagar ahora'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formatea el texto como MM/AA mientras el usuario escribe.
/// Solo permite 4 dígitos y coloca la barra automáticamente.
class ExpiryDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');

    // Limitar a 4 dígitos (MM + AA)
    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    String formatted;
    if (text.length >= 3) {
      formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    } else if (text.length >= 1) {
      formatted = text;
    } else {
      formatted = '';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
