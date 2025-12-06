// lib/features/cart/presentation/pages/cart_page.dart
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu carrito'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Aquí verás los productos de tu carrito 🧺',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
