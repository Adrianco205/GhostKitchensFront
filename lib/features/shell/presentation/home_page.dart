// lib/features/shell/presentation/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ghost_kitchens_app/features/kitchens/presentation/pages/kitchen_detail_page.dart';

// 📍 Addresses
import 'package:ghost_kitchens_app/features/addresses/presentation/pages/address_form_page.dart';
import 'package:ghost_kitchens_app/features/addresses/presentation/pages/address_list_page.dart';

// 🧾 Orders
import 'package:ghost_kitchens_app/features/orders/presentation/pages/order_history_provider.dart';
import 'package:ghost_kitchens_app/features/orders/presentation/pages/order_tracking_page.dart';
import 'package:ghost_kitchens_app/features/orders/domain/order_summary.dart';

/// Modelo UI temporal para representar una cocina en la Home.
/// Más adelante esto vendrá del backend usando ApiClient y ApiEndpoints.home.
class KitchenUiModel {
  final int id;
  final String name;
  final String? imageUrl;
  final double? distanceKm;
  final int? deliveryTimeMin;

  const KitchenUiModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.distanceKm,
    this.deliveryTimeMin,
  });
}

/// Modelo UI temporal de dirección solo para el selector.
/// En el futuro esto vendrá del backend (AddressDto).
class AddressUiModel {
  final int id;
  final String direccionTexto;
  final String? alias;
  final String? ciudad;

  const AddressUiModel({
    required this.id,
    required this.direccionTexto,
    this.alias,
    this.ciudad,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 🔹 Datos mock para la demo de front
  final List<KitchenUiModel> _mockKitchens = const [
    KitchenUiModel(
      id: 1,
      name: 'Sazón Caribeño',
      imageUrl:
          'https://images.pexels.com/photos/958545/pexels-photo-958545.jpeg',
      distanceKm: 1.2,
      deliveryTimeMin: 25,
    ),
    KitchenUiModel(
      id: 2,
      name: 'Pizzería Río Cartagena',
      imageUrl:
          'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg',
      distanceKm: 2.8,
      deliveryTimeMin: 35,
    ),
    KitchenUiModel(
      id: 3,
      name: 'Wok & Roll Asia',
      imageUrl:
          'https://images.pexels.com/photos/3577565/pexels-photo-3577565.jpeg',
      distanceKm: 3.4,
      deliveryTimeMin: 30,
    ),
    KitchenUiModel(
      id: 4,
      name: 'Veggie Lovers',
      imageUrl:
          'https://images.pexels.com/photos/1640770/pexels-photo-1640770.jpeg',
      distanceKm: 1.9,
      deliveryTimeMin: 20,
    ),
    KitchenUiModel(
      id: 5,
      name: 'Parrilla del Puerto',
      imageUrl:
          'https://images.pexels.com/photos/4106483/pexels-photo-4106483.jpeg',
      distanceKm: 4.1,
      deliveryTimeMin: 40,
    ),
  ];

  /// 🔹 Direcciones mock para el selector (estilo screenshot).
  /// Luego esto se reemplaza por AddressDto + ApiClient.
  final List<AddressUiModel> _mockAddresses = const [
    AddressUiModel(
      id: 1,
      direccionTexto: 'San Jose',
      alias: 'casa',
      ciudad: 'cartagena',
    ),
    AddressUiModel(
      id: 2,
      direccionTexto: 'pepe',
      alias: 'trabajo',
      ciudad: 'monteria',
    ),
    AddressUiModel(
      id: 3,
      direccionTexto: 'jaja',
      alias: 'jaja',
      ciudad: 'jaja',
    ),
  ];

  String? _selectedAddressText;
  int? _selectedAddressId;

  Future<void> _openAddressSelector() async {
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
          child: Container(
            height: 420,
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                // Handle
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

                // Lista de direcciones
                Expanded(
                  child: _mockAddresses.isEmpty
                      ? Center(
                          child: Text(
                            'Aún no tienes direcciones guardadas.',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _mockAddresses.length,
                          itemBuilder: (context, index) {
                            final addr = _mockAddresses[index];
                            final isSelected = addr.id == _selectedAddressId;

                            return ListTile(
                              leading: Icon(
                                Icons.location_on_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                addr.alias != null && addr.alias!.isNotEmpty
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
                                // Seleccionar dirección
                                setState(() {
                                  _selectedAddressId = addr.id;
                                  _selectedAddressText = addr.direccionTexto;
                                });
                                Navigator.of(context).pop();

                                // 🔻 Cuando tengas backend:
                                // _loadHomeFromBackend(addressId: addr.id);
                              },
                            );
                          },
                        ),
                ),

                const SizedBox(height: 4),

                // Botón para administrar/editar direcciones
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddressListPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt_outlined),
                      label: const Text('Administrar direcciones'),
                    ),
                  ),
                ),

                // Botón para agregar nueva dirección
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddressFormPage(),
                          ),
                        );
                        // Aquí luego podrías recargar direcciones desde backend.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final addressLabel =
        _selectedAddressText ?? 'Selecciona una dirección de entrega';

    // 🔥 Pedido activo desde el OrderHistoryProvider
    final OrderSummary? activeOrder =
        context.watch<OrderHistoryProvider>().activeOrder;

    return Stack(
      children: [
        // Contenido principal
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              // -------- HEADER CON DIRECCIÓN --------
              _Header(
                address: addressLabel,
                onSelectAddress: _openAddressSelector,
              ),

              const SizedBox(height: 24),

              // -------- TÍTULO PRINCIPAL --------
              Text(
                'Todas nuestras cocinas asociadas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explora las cocinas disponibles en tu ciudad y descubre nuevos sabores.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // -------- GRID DE COCINAS --------
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      constraints.maxWidth > 600 ? 3 : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mockKitchens.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, index) {
                      final kitchen = _mockKitchens[index];
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
              ),
            ],
          ),
        ),

        // 🔵 Botón flotante de pedido activo (solo si hay uno)
        if (activeOrder != null)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingPage(
                      order: activeOrder,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.delivery_dining),
              label: const Text('Pedido en curso'),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String address;
  final VoidCallback onSelectAddress;

  const _Header({
    required this.address,
    required this.onSelectAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hora decorativa
        Text(
          '1:28',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        // Chip de dirección
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
              Flexible(
                child: Text(
                  address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssociatedKitchenCard extends StatelessWidget {
  final KitchenUiModel kitchen;

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
            // Imagen de la cocina
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

            // Info de la cocina
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
