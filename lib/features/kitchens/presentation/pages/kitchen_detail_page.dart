import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/kitchens/data/datasource/kitchen_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/kitchens/data/models/kitchen_dto.dart';
import 'package:ghost_kitchens_app/features/menu/presentation/pages/product_detail_page.dart';

class KitchenDetailPage extends StatefulWidget {
  final int kitchenId;

  const KitchenDetailPage({super.key, required this.kitchenId});

  @override
  State<KitchenDetailPage> createState() => _KitchenDetailPageState();
}

class _KitchenDetailPageState extends State<KitchenDetailPage> {
  late KitchenRemoteDataSource _dataSource;
  late Future<KitchenDto> _kitchenDetailFuture;

  @override
  void initState() {
    super.initState();
    _dataSource = KitchenRemoteDataSource(ApiClient());
    _kitchenDetailFuture = _dataSource.getKitchenDetail(widget.kitchenId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      body: FutureBuilder<KitchenDto>(
        future: _kitchenDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar el menú"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Cocina no encontrada"));
          }

          final cocina = snapshot.data!;
          final productos = cocina.productos;

          return CustomScrollView(
            slivers: [
              // --- APP BAR ELÁSTICO CON IMAGEN DE LA COCINA ---
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    cocina.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 10)],
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        cocina.imagenUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
                      ),
                      // Degradado oscuro para que el texto blanco se lea bien
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, shadows: [Shadow(color: Colors.black87, blurRadius: 10)]),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // --- TÍTULO DE SECCIÓN ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    "Menú Principal",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // --- LISTA DE PRODUCTOS ---
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final producto = productos[index];
                    print("🔍 DEBUG PRODUCTO: ${producto.nombre}");
                    print("   -> URL que llegó del JSON: ${producto.imagenUrl}");

                    // --- LÓGICA DE IMAGEN CORREGIDA ---
                    // Determinamos qué imagen mostrar para este producto específico
                    String imageUrlToShow;

                    // Verificamos si imagenUrl existe y NO está vacía
                    if (producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty) {
                      imageUrlToShow = producto.imagenUrl!;
                    } else {
                      // Si no hay imagen en BD, usamos el placeholder
                      imageUrlToShow = 'https://source.unsplash.com/200x200/?food,${producto.nombre.replaceAll(" ", "")}';
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Navegar al Detalle del Producto
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(productId: producto.id),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. IMAGEN DEL PRODUCTO
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrlToShow, // <--- Usamos la variable calculada
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 100, width: 100, color: Colors.grey[800],
                                      child: const Icon(Icons.fastfood, color: Colors.white54),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // 2. INFORMACIÓN DEL PRODUCTO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        producto.nombre,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        producto.descripcion,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "\$${producto.precio.toStringAsFixed(0)}",
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                          // Botón pequeño de agregar (+)
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add, color: Colors.orange, size: 20),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: productos.length,
                ),
              ),
              // Espacio extra al final para que no quede cortado en pantallas con notch
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}