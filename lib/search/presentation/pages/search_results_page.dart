import 'package:flutter/material.dart';

class SearchResultsPage extends StatefulWidget {
  final String initialQuery;

  const SearchResultsPage({
    super.key,
    required this.initialQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  String _query = '';
  String _selectedSection = 'Todas las secciones';
  String _selectedOrder = 'Relevancia';

  // Mocks de cocinas + productos (para la vista tipo Rappi)
  final List<_KitchenResult> _kitchens = const [
    _KitchenResult(
      name: 'Carlos Burger Cartagena',
      distanceKm: 3.1,
      deliveryTimeMin: 40,
      minPrice: 7000,
      rating: 4.7,
      discount: 'Hasta 30% Off',
      imageUrl:
          'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg',
      dishes: [
        _DishMock(
          name: 'Burger Clásica',
          price: 35000,
          imageUrl:
              'https://images.pexels.com/photos/1639562/pexels-photo-1639562.jpeg',
        ),
        _DishMock(
          name: 'Burger Doble Queso',
          price: 42000,
          imageUrl:
              'https://images.pexels.com/photos/1639563/pexels-photo-1639563.jpeg',
        ),
        _DishMock(
          name: 'Papas con tocineta',
          price: 18000,
          imageUrl:
              'https://images.pexels.com/photos/1583884/pexels-photo-1583884.jpeg',
        ),
      ],
    ),
    _KitchenResult(
      name: 'La Santa Pizza',
      distanceKm: 3.9,
      deliveryTimeMin: 39,
      minPrice: 7000,
      rating: 4.5,
      discount: '15% Off',
      imageUrl:
          'https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg',
      dishes: [
        _DishMock(
          name: 'Pizza 35 cm Pollo Champiñón',
          price: 35000,
          imageUrl:
              'https://images.pexels.com/photos/4109083/pexels-photo-4109083.jpeg',
        ),
        _DishMock(
          name: 'Pizza 4 quesos',
          price: 38000,
          imageUrl:
              'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg',
        ),
      ],
    ),
    _KitchenResult(
      name: 'Vir Viri Broaster',
      distanceKm: 11.0,
      deliveryTimeMin: 40,
      minPrice: 13500,
      rating: 3.6,
      discount: 'Hasta 25% Off',
      imageUrl:
          'https://images.pexels.com/photos/60616/fried-chicken-chicken-fried-crunchy-60616.jpeg',
      dishes: [
        _DishMock(
          name: 'Bucket familiar',
          price: 52000,
          imageUrl:
              'https://images.pexels.com/photos/4109132/pexels-photo-4109132.jpeg',
        ),
        _DishMock(
          name: 'Alitas BBQ',
          price: 28000,
          imageUrl:
              'https://images.pexels.com/photos/2773940/pexels-photo-2773940.jpeg',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _query = widget.initialQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _query = value);
  }

  void _onSubmitted(String value) {
    setState(() => _query = value.trim());
    // opcional: hacer scroll arriba, etc.
  }

  void _clearQuery() {
    setState(() {
      _controller.clear();
      _query = '';
    });
    _focusNode.requestFocus();
  }

  List<_KitchenResult> _filterKitchens() {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return _kitchens;

    return _kitchens.where((k) {
      final inName = k.name.toLowerCase().contains(q);
      final inDish =
          k.dishes.any((d) => d.name.toLowerCase().contains(q));
      return inName || inDish;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filterKitchens();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER CON BUSCADOR
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onChanged,
                        onSubmitted: _onSubmitted,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: '¿Qué quieres hoy?',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearQuery,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // FILTROS ("Buscar en", "Ordenar por")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // luego: bottom sheet real
                        setState(() =>
                            _selectedSection = 'Todas las secciones');
                      },
                      child: Row(
                        children: [
                          Text(
                            'Buscar en ',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Flexible(
                            child: Text(
                              _selectedSection,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // luego: bottom sheet real
                        setState(() => _selectedOrder = 'Relevancia');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Ordenar por ',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Flexible(
                            child: Text(
                              _selectedOrder,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // LISTA SCROLLABLE DE RESULTADOS (responsiva)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final kitchen = filtered[index];
                  return _KitchenResultCard(kitchen: kitchen);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== CARDS RESULTADOS ===================

class _KitchenResultCard extends StatelessWidget {
  final _KitchenResult kitchen;

  const _KitchenResultCard({required this.kitchen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101018),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen principal del restaurante
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              kitchen.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.fastfood, size: 40),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (kitchen.discount.isNotEmpty)
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
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          // luego: ir al detalle / añadir al carrito
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  kitchen.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    Text(
                      '${kitchen.deliveryTimeMin} min',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• \$${kitchen.minPrice}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${kitchen.distanceKm.toStringAsFixed(1)} km',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.star,
                        size: 14, color: Colors.yellow.shade600),
                    const SizedBox(width: 2),
                    Text(
                      kitchen.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Platos del restaurante (scroll horizontal)
          if (kitchen.dishes.isNotEmpty) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 190, // AUMENTADO para que quepa todo el contenido
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                scrollDirection: Axis.horizontal,
                itemCount: kitchen.dishes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final dish = kitchen.dishes[index];
                  return _DishCard(dish: dish);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  final _DishMock dish;

  const _DishCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 140, // ancho fijo, altura se adapta
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagen del plato con proporción estable
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              dish.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.fastfood, size: 32),
              ),
            ),
          ),

          // Texto + precio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${dish.price}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
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

// =================== MODELOS MOCK ===================

class _KitchenResult {
  final String name;
  final double distanceKm;
  final int deliveryTimeMin;
  final int minPrice;
  final double rating;
  final String discount;
  final String imageUrl;
  final List<_DishMock> dishes;

  const _KitchenResult({
    required this.name,
    required this.distanceKm,
    required this.deliveryTimeMin,
    required this.minPrice,
    required this.rating,
    required this.discount,
    required this.imageUrl,
    required this.dishes,
  });
}

class _DishMock {
  final String name;
  final int price;
  final String imageUrl;

  const _DishMock({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}
