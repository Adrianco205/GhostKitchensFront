// lib/features/cart/presentation/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ghost_kitchens_app/features/cart/presentation/cart_provider.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:ghost_kitchens_app/payments/presentation/pages/payment_gateway_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'Tu carrito está vacío.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                    'Total',
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
                  child: const Text('Continuar al pago'),
                  onPressed: items.isEmpty
                      ? null
                      : () {
                          const int fakeAddressId = 1;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PaymentGatewayPage(
                                addressId: fakeAddressId,
                              ),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
