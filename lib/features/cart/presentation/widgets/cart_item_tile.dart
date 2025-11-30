// lib/features/cart/presentation/widgets/cart_item_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ghost_kitchens_app/features/cart/domain/cart_item.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();

    final imageUrl = item.imageUrl ?? '';

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 50,
          height: 50,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.fastfood, color: Colors.white),
                  ),
                )
              : Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.fastfood, color: Colors.white),
                ),
        ),
      ),
      title: Text(item.name),
      subtitle: Text(
        '\$${item.price.toStringAsFixed(0)} x ${item.quantity} = \$${item.total.toStringAsFixed(0)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => cart.decrement(item.id),
          ),
          Text(item.quantity.toString()),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => cart.increment(item.id),
          ),
        ],
      ),
    );
  }
}
