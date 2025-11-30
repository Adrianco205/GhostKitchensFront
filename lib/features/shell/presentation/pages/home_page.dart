import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/search/presentation/pages/search_page.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/core/network/api_endpoints.dart';
import 'package:ghost_kitchens_app/features/shell/data/models/home_dto.dart';
import 'package:dio/dio.dart';
import 'package:ghost_kitchens_app/core/storage/secure_storage.dart';

import 'package:ghost_kitchens_app/features/addresses/data/models/address_dto.dart';
import 'package:ghost_kitchens_app/features/addresses/presentation/pages/address_form_page.dart';

import 'package:provider/provider.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/cart_provider.dart';

// Detalle de cocina
import 'package:ghost_kitchens_app/kitchens/presentation/pages/kitchen_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _secureStorage = SecureStorage();

  HomeResponseDto? _homeData;
  bool _isLoading = false;
  String? _errorMessage;

  String? _selectedAddressText;
  int? _selectedAddressId;

  List<AddressDto> _addresses = [];
  bool _isLoadingAddresses = false;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome({int? addressId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _secureStorage.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de acceso, inicia sesión de nuevo.');
      }

      final queryParameters = <String, dynamic>{};
      if (addressId != null) {
        queryParameters['address_id'] = addressId.toString();
      }

      final response = await _apiClient.get(
        ApiEndpoints.home,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final home = HomeResponseDto.fromJson(data);

      debugPrint(
          'HOME loaded => featured: ${home.featuredProducts.length}, recommended: ${home.recommendedProducts.length}, kitchens: ${home.allKitchens.length}');

      setState(() {
        _homeData = home;
        _selectedAddressText =
            home.address?.direccionTexto ?? _selectedAddressText;
        _selectedAddressId = home.address?.id ?? _selectedAddressId;
      });
    } on DioException catch (e) {
      debugPrint(
          'ERROR HOME ${e.response?.statusCode} => ${e.response?.data}');
      setState(() {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          _errorMessage =
              'No tienes autorización para ver el inicio. Vuelve a iniciar sesión.';
        } else {
          _errorMessage =
              'Error ${e.response?.statusCode ?? ''} al cargar la información del inicio.';
        }
      });
    } catch (e) {
      debugPrint('ERROR HOME genérico: $e');
      setState(() {
        _errorMessage = 'Error al cargar la información del inicio.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final token = await _secureStorage.accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de acceso');
      }

      final response = await _apiClient.get(
        ApiEndpoints.userAddresses,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as List;
      final addresses = data
          .map((json) => AddressDto.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        _addresses = addresses;
      });
    } catch (e) {
      debugPrint('ERROR al cargar direcciones: $e');
    } finally {
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _openAddressSelector() async {
    await _loadAddresses();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: SizedBox(
            height: 420,
            child: Column(
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
                Text(
                  'Selecciona tu dirección',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoadingAddresses
                      ? const Center(child: CircularProgressIndicator())
                      : _addresses.isEmpty
                          ? Center(
                              child: Text(
                                'Aún no tienes direcciones guardadas.',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _addresses.length,
                              itemBuilder: (context, index) {
                                final addr = _addresses[index];
                                final isSelected =
                                    addr.id == _selectedAddressId;
                                return ListTile(
                                  leading: Icon(
                                    Icons.location_on_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  title: Text(
                                    addr.alias != null &&
                                            addr.alias!.isNotEmpty
                                        ? '${addr.alias} · ${addr.direccionTexto}'
                                        : addr.direccionTexto,
                                  ),
                                  subtitle: addr.ciudad != null
                                      ? Text(addr.ciudad!)
                                      : null,
                                  trailing: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.green)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedAddressId = addr.id;
                                      _selectedAddressText =
                                          addr.direccionTexto;
                                    });
                                    Navigator.of(context).pop();
                                    _loadHome(addressId: addr.id);
                                  },
                                );
                              },
                            ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final created = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const AddressFormPage(),
                          ),
                        );

                        if (created == true) {
                          await _loadAddresses();
                          Navigator.of(context).pop();
                          if (_addresses.isNotEmpty) {
                            final last = _addresses.last;
                            setState(() {
                              _selectedAddressId = last.id;
                              _selectedAddressText = last.direccionTexto;
                            });
                            _loadHome(addressId: last.id);
                          }
                        }
                      },
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Agregar nueva dirección'),
                    ),
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

  /// 👇 Helper para agregar al carrito y mostrar feedback
  void _addProductToCart(
    BuildContext context,
    CartProvider cart,
    ProductHomeDto product,
  ) {
    cart.addFromProduct(product);

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
    final size = MediaQuery.of(context).size;

    final cart = context.watch<CartProvider>();

    final double promoHeight = size.width * 0.65;

    final addressLabel =
        _selectedAddressText ?? 'Selecciona una dirección de entrega';

    final featuredProducts =
        _homeData?.featuredProducts ?? const <ProductHomeDto>[];
    final recommendedProducts =
        _homeData?.recommendedProducts ?? const <ProductHomeDto>[];
    final allKitchens = _homeData?.allKitchens ?? const <CocinaHomeDto>[];

    if (_isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _loadHome(addressId: _selectedAddressId),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _Header(
            address: addressLabel,
            onSelectAddress: _openAddressSelector,
            onTapSearch: _openSearch,
          ),

          const SizedBox(height: 24),

          Text(
            '¿Un antojo?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          /// 🔥 SECCIÓN "¿Un antojo?" CON BOTÓN +
          if (featuredProducts.isNotEmpty)
            SizedBox(
              height: promoHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featuredProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = featuredProducts[index];
                  return _BigProductCard(
                    product: product,
                    onAdd: () =>
                        _addProductToCart(context, cart, product), // 👈+
                  );
                },
              ),
            )
          else
            Text(
              'Pronto verás productos destacados aquí.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),

          const SizedBox(height: 24),

          Text(
            'Inspirado en tus gustos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          if (recommendedProducts.isNotEmpty)
            Column(
              children: recommendedProducts
                  .map(
                    (p) => _ProductListTile(
                      product: p,
                      onAdd: () => _addProductToCart(context, cart, p), // 👈+
                    ),
                  )
                  .toList(),
            )
          else
            Text(
              'Cuando empieces a pedir, te mostraremos recomendaciones aquí.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),

          const SizedBox(height: 24),

          Text(
            'Todas nuestras cocinas asociadas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          if (allKitchens.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allKitchens.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final kitchen = allKitchens[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => KitchenDetailPage(
                              kitchenId: kitchen.id,
                            ),
                          ),
                        );
                      },
                      child: _AssociatedKitchenCard(kitchen: kitchen),
                    );
                  },
                );
              },
            )
          else
            Text(
              'Aún no hay cocinas activas en tu zona.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

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
          '1:28',
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
                  color: Colors.black
                      .withOpacity(scaffoldBg == Colors.white ? 0.05 : 0.25),
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

class _BigProductCard extends StatelessWidget {
  final ProductHomeDto product;
  final VoidCallback onAdd;

  const _BigProductCard({
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageUrl = product.imageUrl;

    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Stack(
        children: [
          Container(
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
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
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
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.kitchenName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${product.price.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 👇 Botón flotante de "+"
          Positioned(
            right: 10,
            bottom: 10,
            child: Material(
              color: theme.colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onAdd,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.add,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final ProductHomeDto product;
  final VoidCallback onAdd;

  const _ProductListTile({
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 64,
              width: 64,
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.fastfood, size: 24),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.fastfood, size: 24),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.kitchenName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _AssociatedKitchenCard extends StatelessWidget {
  final CocinaHomeDto kitchen;

  const _AssociatedKitchenCard({required this.kitchen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final imageUrl = kitchen.imageUrl;

    return AspectRatio(
      aspectRatio: 3 / 4,
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
              child: imageUrl != null
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
                    Row(
                      children: [
                        if (kitchen.deliveryTimeMin != null)
                          Text(
                            '${kitchen.deliveryTimeMin} min',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        if (kitchen.deliveryTimeMin != null &&
                            kitchen.distanceKm != null)
                          const Text(' • '),
                        if (kitchen.distanceKm != null)
                          Text(
                            '${kitchen.distanceKm!.toStringAsFixed(1)} km',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                      ],
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
