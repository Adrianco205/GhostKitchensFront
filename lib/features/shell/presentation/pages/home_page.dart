import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/search/presentation/pages/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedAddress = 'Cl. 35 #103-117, Cartagena';

  final List<String> _addresses = const [
    'Cl. 35 #103-117, Cartagena',
    'Manga, Cartagena',
    'Crespo, Cartagena',
    'Bocagrande, Cartagena',
  ];

  // Cocinas destacadas e “inspirado en tus gustos”
  final List<_KitchenMock> _featuredKitchens = const [
    _KitchenMock(
      name: 'Carlos Burger',
      description: 'Hamburguesas artesanales y combos',
      tags: ['hamburguesa', 'carne', 'rápida'],
      distanceKm: 3.1,
      deliveryTimeMin: 40,
      minPrice: 7000,
      rating: 4.7,
      discount: 'Hasta 30% Off',
      imageUrl:
          'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg',
    ),
    _KitchenMock(
      name: 'La Santa Pizza',
      description: 'Pizzas a la piedra y pastas',
      tags: ['pizza', 'italiano', 'queso'],
      distanceKm: 3.9,
      deliveryTimeMin: 39,
      minPrice: 7000,
      rating: 4.5,
      discount: '15% Off',
      imageUrl:
          'https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg',
    ),
    _KitchenMock(
      name: 'Vir Viri Broaster',
      description: 'Pollo frito crocante y combos',
      tags: ['pollo', 'broaster', 'frito'],
      distanceKm: 11.0,
      deliveryTimeMin: 40,
      minPrice: 13500,
      rating: 3.6,
      discount: 'Hasta 25% Off',
      imageUrl:
          'https://images.pexels.com/photos/60616/fried-chicken-chicken-fried-crunchy-60616.jpeg',
    ),
  ];

  // Todas las cocinas asociadas
  final List<_KitchenMock> _associatedKitchens = const [
    _KitchenMock(
      name: 'Carlos Burger',
      description: 'Hamburguesas artesanales y combos',
      tags: ['hamburguesa', 'carne'],
      distanceKm: 3.1,
      deliveryTimeMin: 40,
      minPrice: 7000,
      rating: 4.7,
      discount: 'Hasta 30% Off',
      imageUrl:
          'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg',
    ),
    _KitchenMock(
      name: 'La Santa Pizza',
      description: 'Pizzas a la piedra y pastas',
      tags: ['pizza', 'italiano'],
      distanceKm: 3.9,
      deliveryTimeMin: 39,
      minPrice: 7000,
      rating: 4.5,
      discount: '15% Off',
      imageUrl:
          'https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg',
    ),
    _KitchenMock(
      name: 'Vir Viri Broaster',
      description: 'Pollo frito crocante y combos',
      tags: ['pollo', 'broaster'],
      distanceKm: 11.0,
      deliveryTimeMin: 40,
      minPrice: 13500,
      rating: 3.6,
      discount: 'Hasta 25% Off',
      imageUrl:
          'https://images.pexels.com/photos/60616/fried-chicken-chicken-fried-crunchy-60616.jpeg',
    ),
    _KitchenMock(
      name: 'Vegan Spot',
      description: 'Bowls saludables y opciones veganas',
      tags: ['vegano', 'ensaladas'],
      distanceKm: 2.3,
      deliveryTimeMin: 25,
      minPrice: 12000,
      rating: 4.8,
      discount: 'Nuevo',
      imageUrl:
          'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
    ),
    _KitchenMock(
      name: 'Sushi Ghost',
      description: 'Sushi, poke bowls y ramen',
      tags: ['sushi', 'japonés'],
      distanceKm: 4.5,
      deliveryTimeMin: 45,
      minPrice: 18000,
      rating: 4.6,
      discount: 'Hasta 20% Off',
      imageUrl:
          'https://images.pexels.com/photos/3298182/pexels-photo-3298182.jpeg',
    ),
    _KitchenMock(
      name: 'Arepas Nocturnas',
      description: 'Arepas rellenas y perros calientes',
      tags: ['arepas', 'perros'],
      distanceKm: 1.8,
      deliveryTimeMin: 30,
      minPrice: 6000,
      rating: 4.2,
      discount: '2x1 Hoy',
      imageUrl:
          'https://images.pexels.com/photos/9788992/pexels-photo-9788992.jpeg',
    ),
  ];

  void _openAddressSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 360,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Selecciona tu dirección',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      final selected = address == _selectedAddress;
                      return ListTile(
                        leading: Icon(
                          Icons.location_on_rounded,
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                        title: Text(address),
                        trailing: selected
                            ? Icon(
                                Icons.check,
                                color:
                                    Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedAddress = address);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SearchPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Altura del carrusel de promos basada en el ancho de pantalla
    final double promoHeight = size.width * 0.65;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _Header(
            address: _selectedAddress,
            onSelectAddress: _openAddressSelector,
            onTapSearch: _openSearch,
          ),

          const SizedBox(height: 24),

          Text(
            '¿Hambre de medianoche? 🌙',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Carrusel totalmente responsivo
          SizedBox(
            height: promoHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredKitchens.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final kitchen = _featuredKitchens[index];
                return _BigPromoCard(kitchen: kitchen);
              },
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Inspirado en tus gustos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Column(
            children: _featuredKitchens
                .map((k) => _KitchenListTile(kitchen: k))
                .toList(),
          ),

          const SizedBox(height: 24),

          Text(
            'Todas nuestras cocinas asociadas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Grid responsivo – se adapta al ancho
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  constraints.maxWidth > 600 ? 3 : 2; // tablets vs móviles
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _associatedKitchens.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  final kitchen = _associatedKitchens[index];
                  return _AssociatedKitchenCard(kitchen: kitchen);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// =================== WIDGETS ===================

class _Header extends StatelessWidget {
  final String address;
  final VoidCallback onSelectAddress;
  final VoidCallback onTapSearch;

  const _Header({
    required this.address,
    required this.onSelectAddress,
    required this.onTapSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1:28', // placeholder
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        InkWell(
          onTap: onSelectAddress,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                address,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ),
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: onTapSearch,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: scaffoldBg == Colors.white
                  ? Colors.grey.shade100
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    scaffoldBg == Colors.white ? 0.05 : 0.25,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: theme.iconTheme.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  '¿Qué quieres hoy?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KitchenMock {
  final String name;
  final String description;
  final List<String> tags;
  final double distanceKm;
  final int deliveryTimeMin;
  final int minPrice;
  final double rating;
  final String discount;
  final String imageUrl;

  const _KitchenMock({
    required this.name,
    required this.description,
    required this.tags,
    required this.distanceKm,
    required this.deliveryTimeMin,
    required this.minPrice,
    required this.rating,
    required this.discount,
    required this.imageUrl,
  });
}

class _BigPromoCard extends StatelessWidget {
  final _KitchenMock kitchen;

  const _BigPromoCard({required this.kitchen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 3 / 2, // siempre proporcional, sin overflow
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Image.network(
                kitchen.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.fastfood, size: 40),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        kitchen.discount,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kitchen.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kitchen.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KitchenListTile extends StatelessWidget {
  final _KitchenMock kitchen;

  const _KitchenListTile({required this.kitchen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: NetworkImage(kitchen.imageUrl),
            onBackgroundImageError: (_, __) {},
            child: kitchen.imageUrl.isEmpty
                ? Text(
                    kitchen.name.characters.first,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kitchen.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.star,
                        size: 14, color: Colors.yellow.shade600),
                    const SizedBox(width: 4),
                    Text(
                      kitchen.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${kitchen.deliveryTimeMin} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• \$${kitchen.minPrice}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${kitchen.distanceKm.toStringAsFixed(1)} km • ${kitchen.tags.join(' · ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssociatedKitchenCard extends StatelessWidget {
  final _KitchenMock kitchen;

  const _AssociatedKitchenCard({required this.kitchen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 3 / 4, // se adapta al grid sin overflow
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101018) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Image.network(
                kitchen.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.fastfood, size: 32),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kitchen.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${kitchen.deliveryTimeMin} min • ${kitchen.distanceKm.toStringAsFixed(1)} km',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
