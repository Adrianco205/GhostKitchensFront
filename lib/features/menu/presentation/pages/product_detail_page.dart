import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/provider/cart_provider.dart';
import 'package:ghost_kitchens_app/features/kitchens/data/models/product_dto.dart';
import 'package:ghost_kitchens_app/features/menu/data/datasource/menu_remote_datasource.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late MenuRemoteDataSource _dataSource;
  late Future<ProductDto> _productFuture;

  @override
  void initState() {
    super.initState();
    _dataSource = MenuRemoteDataSource(ApiClient());
    _productFuture = _dataSource.getProductDetail(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Para que la imagen suba hasta la barra de estado
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 10)]
        ),
      ),
      body: FutureBuilder<ProductDto>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar producto"));
          }

          final product = snapshot.data!;

          // --- LÓGICA DE IMAGEN CORREGIDA ---
          String imageUrlToShow;

          // 1. Verificamos si el producto trae imagenUrl desde la BD
          if (product.imagenUrl != null && product.imagenUrl!.isNotEmpty) {
            imageUrlToShow = product.imagenUrl!;
          } else {
            // 2. Si es null o vacía, usamos el placeholder de Unsplash
            imageUrlToShow = 'https://source.unsplash.com/800x600/?food,${product.nombre.replaceAll(" ", "")}';
          }

          return Stack(
            children: [
              // 1. Imagen de Fondo
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 350,
                child: Image.network(
                  imageUrlToShow, // <--- Usamos la variable calculada
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(
                    color: Colors.grey[900],
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 50)),
                  ),
                ),
              ),

              // 2. Contenido (Scrollable)
              Positioned.fill(
                top: 320, // Empieza un poco antes de que termine la imagen
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F111A), // Fondo oscuro
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView( // Agregado SingleChildScrollView por seguridad en pantallas pequeñas
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Text(
                          product.nombre,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Nombre de la cocina (Estático por ahora, o podrías pasarlo en el constructor si lo tienes)
                        const Text("Ghost Kitchen", style: TextStyle(color: Colors.grey)),

                        const SizedBox(height: 16),

                        // Precio
                        Text(
                          "\$${product.precio.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange // Color primario (naranja)
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          "Descripción",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.descripcion,
                          style: TextStyle(fontSize: 16, color: Colors.grey[400], height: 1.5),
                        ),

                        // Espacio extra al final para que el botón flotante no tape el texto
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Botón Flotante "Agregar al carrito"
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Tu color naranja
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    onPressed: () {
                      // --- LÓGICA DEL CARRITO ---
                      Provider.of<CartProvider>(context, listen: false).addToCart(product);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${product.nombre} agregado al carrito 🛒"),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                      Navigator.pop(context); // Volver al menú
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Agregar al carrito",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}