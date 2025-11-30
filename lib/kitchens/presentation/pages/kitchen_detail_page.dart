import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/core/network/api_endpoints.dart';
import 'package:ghost_kitchens_app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';

import 'package:ghost_kitchens_app/kitchens/data/models/kitchen_detail_dto.dart';

// Provider carrito
import 'package:provider/provider.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/cart_provider.dart';

class KitchenDetailPage extends StatefulWidget {
  final int kitchenId;

  const KitchenDetailPage({
    super.key,
    required this.kitchenId,
  });

  @override
  State<KitchenDetailPage> createState() => _KitchenDetailPageState();
}

class _KitchenDetailPageState extends State<KitchenDetailPage> {
  final _apiClient = ApiClient();
  final _storage = SecureStorage();

  KitchenDetailDto? _detail;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await _storage.accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de acceso');
      }

      final response = await _apiClient.get(
        ApiEndpoints.kitchenDetail(widget.kitchenId),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final detail = KitchenDetailDto.fromJson(data);

      setState(() {
        _detail = detail;
      });
    } on DioException catch (e) {
      debugPrint(
          'ERROR kitchen detail ${e.response?.statusCode} => ${e.response?.data}');
      setState(() {
        _error = 'No se pudo cargar la información de la cocina.';
      });
    } catch (e) {
      debugPrint('ERROR kitchen detail genérico: $e');
      setState(() {
        _error = 'Ocurrió un error al cargar la cocina.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 👇 Helper para agregar al carrito desde la cocina
  void _addProductToCart(
    BuildContext context,
    CartProvider cart,
    KitchenProductDto product,
    String kitchenName,
  ) {
    cart.addFromKitchenProduct(product, kitchenName);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} agregado al carrito'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();

    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadDetail,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final detail = _detail;

    if (detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Sin datos de la cocina'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.name),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeaderKitchen(detail: detail),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          // Categorías + productos
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = detail.categories[index];
                if (category.products.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _CategorySection(
                    category: category,
                    onAddProduct: (p) =>
                        _addProductToCart(context, cart, p, detail.name),
                  ),
                );
              },
              childCount: detail.categories.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}

// ====================== HEADER ======================

class _HeaderKitchen extends StatelessWidget {
  final KitchenDetailDto detail;

  const _HeaderKitchen({required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final banner = detail.bannerUrl ?? detail.logoUrl;
    final logo = detail.logoUrl ?? detail.bannerUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner
        AspectRatio(
          aspectRatio: 3 / 1.4,
          child: Container(
            color: Colors.grey.shade900,
            child: banner != null
                ? Image.network(
                    banner,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade800),
                  )
                : const SizedBox.shrink(),
          ),
        ),

        // Logo sobrepuesto y datos
        Container(
          color: isDark ? const Color(0xFF05050A) : Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo circular
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: logo != null ? NetworkImage(logo) : null,
                child: logo == null
                    ? const Icon(Icons.storefront, size: 32)
                    : null,
              ),
              const SizedBox(width: 12),
              // Nombre + info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (detail.rating != null) ...[
                          const Icon(Icons.star,
                              size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            detail.rating!.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (detail.deliveryTimeMin != null) ...[
                          const Icon(Icons.timer_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${detail.deliveryTimeMin} min',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (detail.description != null &&
                        detail.description!.isNotEmpty)
                      Text(
                        detail.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ====================== CATEGORÍA + PRODUCTOS ======================

class _CategorySection extends StatelessWidget {
  final KitchenCategoryDto category;
  final void Function(KitchenProductDto) onAddProduct;

  const _CategorySection({
    required this.category,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: category.products
              .map(
                (p) => _ProductTile(
                  product: p,
                  onAdd: () => onAddProduct(p),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final KitchenProductDto product;
  final VoidCallback onAdd;

  const _ProductTile({
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 70,
              width: 70,
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.fastfood, size: 28),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.fastfood, size: 28),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    product.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Botón +
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.white,
              ),
              onPressed: onAdd,
              tooltip: 'Agregar al carrito',
            ),
          ),
        ],
      ),
    );
  }
}
