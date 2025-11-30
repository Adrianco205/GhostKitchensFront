// lib/orders/presentation/pages/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ghost_kitchens_app/features/cart/presentation/cart_provider.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/widgets/cart_item_tile.dart';

// Nueva importación: pantalla que simula la pasarela de pago
import 'package:ghost_kitchens_app/payments/presentation/pages/payment_gateway_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar pedido'),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'Tu carrito está vacío.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
      bottomNavigationBar: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total a pagar',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '\$${cart.totalAmount}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: items.isEmpty
                      ? null
                      : () {
                          // TODO: aquí deberías pasar el addressId real que seleccione el usuario
                          const int fakeAddressId = 1;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PaymentGatewayPage(
                                addressId: fakeAddressId,
                              ),
                            ),
                          );
                        },
                  child: const Text('Ir a pagar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
