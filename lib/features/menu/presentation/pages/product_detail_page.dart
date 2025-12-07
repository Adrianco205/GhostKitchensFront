// lib/features/menu/presentation/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ghost_kitchens_app/features/cart/presentation/pages/cart_provider.dart';

class ProductDetailPage extends StatelessWidget {
  final String kitchenName;
  final String productName;
  final String? description;
  final double price;
  final String? imageUrl;

  /// Opcional: si luego le pasas el id real del producto desde la cocina.
  final int? productId;

  const ProductDetailPage({
    super.key,
    required this.kitchenName,
    required this.productName,
    this.description,
    required this.price,
    this.imageUrl,
    this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen grande del producto
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151515) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Nombre producto
            Text(
              productName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),

            // Nombre cocina
            Text(
              kitchenName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // Precio
            Text(
              '\$${price.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Descripción
            if (description != null && description!.isNotEmpty) ...[
              Text(
                'Descripción',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description!,
                style: theme.textTheme.bodyMedium,
              ),
            ] else ...[
              Text(
                'Descripción',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Este producto aún no tiene una descripción detallada.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Botón: agregar al carrito usando CartProvider
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final cart = context.read<CartProvider>();

                  // ID simple para pruebas si no tienes id real aún
                  final int id = productId ?? productName.hashCode;

                  cart.addItem(
                    id: id,
                    name: productName,
                    price: price,
                    imageUrl: imageUrl,
                    kitchenName: kitchenName,
                  );

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Producto agregado al carrito 🛒'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                },
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Agregar al carrito'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
