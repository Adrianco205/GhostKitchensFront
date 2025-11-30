import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/core/network/api_endpoints.dart';
import 'package:ghost_kitchens_app/search/data/models/search_dto.dart';

// Provider del carrito
import 'package:provider/provider.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/cart_provider.dart';

import 'package:ghost_kitchens_app/kitchens/presentation/pages/kitchen_detail_page.dart';
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

  bool _isLoading = false;
  String? _errorMessage;

  /// Resultados provenientes del backend
  List<SearchResultItemDto> _results = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _query = widget.initialQuery;

    _fetchResults(_query);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ==================== API ====================

  Future<void> _fetchResults(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ApiClient();
      final response = await client.get(
        ApiEndpoints.search,
        queryParameters: {'q': trimmed},
      );

      final dto = SearchResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      setState(() {
        _query = dto.query;
        _results = dto.results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudieron cargar los resultados.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==================== HANDLERS ====================

  void _onChanged(String value) {
    setState(() => _query = value);
  }

  void _onSubmitted(String value) {
    _fetchResults(value);
  }

  void _clearQuery() {
    setState(() {
      _controller.clear();
      _query = '';
      _results = [];
      _errorMessage = null;
    });
    _focusNode.requestFocus();
  }

  /// Helper para agregar platos al carrito desde search
  void _addDishToCart(
    BuildContext context,
    CartProvider cart,
    SearchResultItemDto kitchen,
    DishPreviewDto dish,
  ) {
    cart.addFromDish(dish, kitchen.name);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${dish.name} agregado al carrito'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                        setState(
                          () => _selectedSection = 'Todas las secciones',
                        );
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

            // LISTA SCROLLABLE DE RESULTADOS
            Expanded(
              child: Builder(
                builder: (_) {
                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (_errorMessage != null) {
                    return Center(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  if (_results.isEmpty) {
                    return Center(
                      child: Text(
                        _query.isEmpty
                            ? 'Empieza a buscar para ver resultados.'
                            : 'No encontramos resultados para "$_query".',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final kitchen = _results[index];
                      return _KitchenResultCard(
                        kitchen: kitchen,
                        onAddDish: (dish) =>
                            _addDishToCart(context, cart, kitchen, dish),
                      );
                    },
                  );
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
  final SearchResultItemDto kitchen;
  final void Function(DishPreviewDto) onAddDish;

  const _KitchenResultCard({
    required this.kitchen,
    required this.onAddDish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final imageUrl = kitchen.imageUrl ?? '';
    final rating = kitchen.rating ?? 0.0;
    final distance = kitchen.distanceKm ?? 0.0;
    final time = kitchen.deliveryTimeMin ?? 0;
    final minPrice = kitchen.minPrice ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => KitchenDetailPage(
              kitchenId: kitchen.id, // 👈 AQUÍ ESTÁ LA MAGIA
            ),
          ),
        );
      },
      child: Container(
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
            AspectRatio(
              aspectRatio: 16 / 9,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.fastfood, size: 40),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.fastfood, size: 40),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((kitchen.discount ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        kitchen.discount!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
                        '$time min',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• \$${minPrice}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${distance.toStringAsFixed(1)} km',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.star,
                          size: 14, color: Colors.yellow.shade600),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (kitchen.dishes.isNotEmpty)
              SizedBox(
                height: 230,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: kitchen.dishes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final dish = kitchen.dishes[index];
                    return _DishCard(
                      dish: dish,
                      onAdd: () => onAddDish(dish),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _DishCard extends StatelessWidget {
  final DishPreviewDto dish;
  final VoidCallback onAdd;

  const _DishCard({
    required this.dish,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = dish.imageUrl ?? '';

    return Container(
      width: 160, // un poco más ancho
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del plato
          AspectRatio(
            aspectRatio: 4 / 3,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.fastfood, size: 32),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.fastfood, size: 32),
                  ),
          ),

          // Texto + precio + botón +
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${dish.price}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: onAdd,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
