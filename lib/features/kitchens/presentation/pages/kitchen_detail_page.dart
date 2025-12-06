import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/features/menu/presentation/pages/product_detail_page.dart';

/// MODELOS UI TEMPORALES (solo front, sin backend)

class KitchenDetailUiModel {
  final int id;
  final String name;
  final String? description;
  final double? rating;
  final int? deliveryTimeMin;
  final String? bannerUrl;
  final String? logoUrl;
  final List<KitchenCategoryUiModel> categories;

  const KitchenDetailUiModel({
    required this.id,
    required this.name,
    this.description,
    this.rating,
    this.deliveryTimeMin,
    this.bannerUrl,
    this.logoUrl,
    this.categories = const [],
  });
}

class KitchenCategoryUiModel {
  final String name;
  final List<KitchenProductUiModel> products;

  const KitchenCategoryUiModel({
    required this.name,
    this.products = const [],
  });
}

class KitchenProductUiModel {
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;

  const KitchenProductUiModel({
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
  });
}

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
  late final KitchenDetailUiModel _detail;

  @override
  void initState() {
    super.initState();
    _detail = _getMockDetail(widget.kitchenId);
  }

  KitchenDetailUiModel _getMockDetail(int id) {
    return KitchenDetailUiModel(
      id: id,
      name: 'Sazón Caribeño',
      description:
          'Platos típicos de la costa caribeña con sabor casero y toques modernos.',
      rating: 4.7,
      deliveryTimeMin: 30,
      bannerUrl:
          'https://images.pexels.com/photos/958545/pexels-photo-958545.jpeg',
      logoUrl:
          'https://images.pexels.com/photos/1639562/pexels-photo-1639562.jpeg',
      categories: const [
        KitchenCategoryUiModel(
          name: 'Platos fuertes',
          products: [
            KitchenProductUiModel(
              name: 'Arroz de mariscos',
              description:
                  'Arroz cremoso con mezcla de mariscos frescos y vegetales.',
              price: 38000,
              imageUrl:
                  'https://images.pexels.com/photos/1351238/pexels-photo-1351238.jpeg',
            ),
            KitchenProductUiModel(
              name: 'Mojarra frita',
              description:
                  'Mojarra crocante acompañada de patacones y ensalada.',
              price: 32000,
              imageUrl:
                  'https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg',
            ),
          ],
        ),
        KitchenCategoryUiModel(
          name: 'Acompañantes',
          products: [
            KitchenProductUiModel(
              name: 'Patacones con hogao',
              description: 'Porción de patacones con hogao casero.',
              price: 12000,
              imageUrl:
                  'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg',
            ),
            KitchenProductUiModel(
              name: 'Yuca frita',
              description: 'Yuca dorada y crocante por fuera, suave por dentro.',
              price: 10000,
            ),
          ],
        ),
        KitchenCategoryUiModel(
          name: 'Bebidas',
          products: [
            KitchenProductUiModel(
              name: 'Limonada de coco',
              description: 'Clásica limonada de coco fría.',
              price: 9000,
            ),
            KitchenProductUiModel(
              name: 'Jugo de maracuyá',
              description: 'Jugo natural de maracuyá sin conservantes.',
              price: 8000,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;

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
                    kitchenName: detail.name,
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
  final KitchenDetailUiModel detail;

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
        Container(
          color: isDark ? const Color(0xFF05050A) : Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: logo != null ? NetworkImage(logo) : null,
                child: logo == null
                    ? const Icon(Icons.storefront, size: 32)
                    : null,
              ),
              const SizedBox(width: 12),
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

// ====================== CATEGORÍAS + PRODUCTOS ======================

class _CategorySection extends StatelessWidget {
  final KitchenCategoryUiModel category;
  final String kitchenName;

  const _CategorySection({
    required this.category,
    required this.kitchenName,
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
                  kitchenName: kitchenName,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final KitchenProductUiModel product;
  final String kitchenName;

  const _ProductTile({
    required this.product,
    required this.kitchenName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(
                kitchenName: kitchenName,
                productName: product.name,
                description: product.description,
                price: product.price,
                imageUrl: product.imageUrl,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
          ],
        ),
      ),
    );
  }
}
