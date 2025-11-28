import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Más adelante aquí conectarás tu estado real del carrito
    // (lista de productos, totales, botón de ir a pagar, etc.)
    final bool hasItems = false; // placeholder

    if (!hasItems) {
      return const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tu carrito está vacío por ahora.\n'
              'Explora las cocinas y añade algo delicioso 😋',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Ejemplo de estructura cuando ya tengas items
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: const [
                // Aquí irían tus CartItemTile cuando los tengas integrados
                // CartItemTile(...),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navegar a checkout
                },
                child: const Text('Continuar al pago'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
