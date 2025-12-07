// lib/features/cart/presentation/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ghost_kitchens_app/features/cart/presentation/pages/cart_provider.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/widgets/cart_item_tile.dart';

// 🧾 Orders
import 'package:ghost_kitchens_app/features/orders/domain/order_summary.dart';
import 'package:ghost_kitchens_app/features/orders/presentation/pages/order_history_provider.dart';
import 'package:ghost_kitchens_app/features/orders/presentation/pages/order_tracking_page.dart';

/// Métodos de pago soportados en el flujo simulado.
/// Se mapean a los CUS-05 / CUS-06.
enum PaymentMethodType { efectivo, datafono, online }

extension PaymentMethodTypeX on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.efectivo:
        return 'Efectivo';
      case PaymentMethodType.datafono:
        return 'Datáfono';
      case PaymentMethodType.online:
        return 'Pago en línea';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethodType.efectivo:
        return 'Pagas al recibir tu pedido.';
      case PaymentMethodType.datafono:
        return 'Pagas con tarjeta en datáfono al recibir.';
      case PaymentMethodType.online:
        return 'Simula un pago con pasarela (no real).';
    }
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  PaymentMethodType? _selectedMethod;
  bool _isConfirming = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    // Pedido activo desde el historial (el último que se confirmó)
    final OrderSummary? activeOrder =
        context.watch<OrderHistoryProvider>().activeOrder;

    final bool hasItems = items.isNotEmpty;
    final bool showOrderSummary = !hasItems && activeOrder != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
      ),
      body: showOrderSummary
          ? _OrderConfirmedView(order: activeOrder!)
          : items.isEmpty
              ? Center(
                  child: Text(
                    'Tu carrito está vacío.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CartItemTile(item: item);
                  },
                ),
      bottomNavigationBar: hasItems
          ? _CartBottomBar(
              isDisabled: items.isEmpty || _isConfirming,
              totalAmount: cart.totalAmount,
              selectedMethod: _selectedMethod,
              onSelectMethod: () => _openPaymentMethodSelector(context),
              onConfirmOrder: () => _confirmOrder(context, cart),
            )
          : null,
    );
  }

  /// UI Seleccionar método de pago (CUS-05).
  Future<void> _openPaymentMethodSelector(BuildContext context) async {
    final theme = Theme.of(context);

    final method = await showModalBottomSheet<PaymentMethodType>(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        PaymentMethodType? tempSelected = _selectedMethod;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      'Selecciona el método de pago',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Lista de métodos
                    ...PaymentMethodType.values.map(
                      (m) => RadioListTile<PaymentMethodType>(
                        value: m,
                        groupValue: tempSelected,
                        onChanged: (value) {
                          setModalState(() {
                            tempSelected = value;
                          });
                        },
                        title: Text(m.label),
                        subtitle: Text(
                          m.description,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(null),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: tempSelected == null
                                ? null
                                : () => Navigator.of(context)
                                    .pop(tempSelected),
                            child: const Text('Confirmar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (method != null) {
      setState(() {
        _selectedMethod = method;
      });
    }
  }

  /// Confirmar pedido (incluye CUS-05 y la extensión CUS-06 si aplica).
  Future<void> _confirmOrder(BuildContext context, CartProvider cart) async {
    if (cart.items.isEmpty || _isConfirming) return;

    final method = _selectedMethod;
    if (method == null) {
      // Debe seleccionar un método primero
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un método de pago.')),
      );
      await _openPaymentMethodSelector(context);
      return;
    }

    setState(() {
      _isConfirming = true;
    });

    bool paymentOk = true;

    // Si eligió pago en línea → simular CUS-06
    if (method == PaymentMethodType.online) {
      paymentOk = await _simulateElectronicPayment(context, cart.totalAmount);
    }

    if (!paymentOk) {
      setState(() {
        _isConfirming = false;
      });
      // CUS-06: pago rechazado o cancelado → puede volver a seleccionar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago cancelado o rechazado. El pedido no fue creado.'),
        ),
      );
      return;
    }

    // Registrar pedido en historial (CUS-07) y marcar como activo
    final history = context.read<OrderHistoryProvider>();
    history.registerOrder(
      items: cart.items,
      total: cart.totalAmount,
      metodoPago: method.label,
    );

    cart.clear(); // Limpia carrito tras crear pedido

    setState(() {
      _isConfirming = false;
      _selectedMethod = null;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Pedido creado y guardado en tu historial!'),
      ),
    );

    // 🔴 IMPORTANTE: ya NO hacemos Navigator.pop()
    // Nos quedamos en la página de carrito, que ahora mostrará
    // el resumen del pedido activo.
  }

  /// Simulación de PROCESAR PAGO ELECTRÓNICO (CUS-06).
  Future<bool> _simulateElectronicPayment(
      BuildContext context, double total) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pago en línea (simulado)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total a pagar: \$${total.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 12),
                  if (isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2),
                          SizedBox(width: 8),
                          Text('Procesando pago...'),
                        ],
                      ),
                    )
                  else
                    Text(
                      'Este pago es solo una simulación.\n'
                      'Puedes marcarlo como exitoso o cancelarlo.',
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          setDialogState(() {
                            isProcessing = true;
                          });
                          await Future.delayed(const Duration(seconds: 2));
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  child: const Text('Pagar ahora'),
                ),
              ],
            );
          },
        );
      },
    );

    // true → pago exitoso, false / null → cancelado o error
    return result ?? false;
  }
}

/// Vista que se muestra cuando no hay items en el carrito
/// pero sí hay un pedido activo recién creado.
class _OrderConfirmedView extends StatelessWidget {
  final OrderSummary order;

  const _OrderConfirmedView({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Icon(
              Icons.check_circle_rounded,
              size: 72,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '¡Pedido confirmado!',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Pedido #${order.id} creado correctamente.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Resumen',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...order.items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.name),
              subtitle: Text(
                '${item.quantity} x \$${item.price.toStringAsFixed(0)}',
              ),
              trailing: Text(
                '\$${item.total.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '\$${order.total.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Método de pago: ${order.paymentMethod}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delivery_dining),
              label: const Text('Ver detalle y seguimiento'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingPage(order: order),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra inferior del carrito: total + selección de método + confirmar.
class _CartBottomBar extends StatelessWidget {
  final double totalAmount;
  final PaymentMethodType? selectedMethod;
  final VoidCallback onSelectMethod;
  final VoidCallback onConfirmOrder;
  final bool isDisabled;

  const _CartBottomBar({
    required this.totalAmount,
    required this.selectedMethod,
    required this.onSelectMethod,
    required this.onConfirmOrder,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Método de pago seleccionado
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: isDisabled ? null : onSelectMethod,
                icon: const Icon(Icons.payment),
                label: Text(
                  selectedMethod?.label ?? 'Seleccionar método de pago',
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isDisabled ? null : onConfirmOrder,
                child: const Text('Confirmar pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
