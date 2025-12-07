// lib/features/shell/presentation/profile_page.dart

import 'package:flutter/material.dart';

// Historial de pedidos
import 'package:ghost_kitchens_app/features/orders/presentation/pages/orders_history_page.dart';

// PQR / Reclamos
import 'package:ghost_kitchens_app/features/support/presentation/pages/pqr_list_page.dart';

// Direcciones
import 'package:ghost_kitchens_app/features/addresses/presentation/pages/address_list_page.dart';

// Textos legales (términos y política)
import 'package:ghost_kitchens_app/features/support/presentation/pages/legal.dart';

// Login (para simular cierre de sesión)
import 'package:ghost_kitchens_app/features/auth/presentation/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLegalSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Términos y privacidad',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExpansionTile(
                              title: const Text('Términos y Condiciones'),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SelectableText(
                                    kTermsOfServiceText,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ExpansionTile(
                              title: const Text(
                                  'Política de Tratamiento de Datos Personales'),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SelectableText(
                                    kPrivacyPolicyText,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text(
              '¿Seguro que deseas cerrar sesión en este dispositivo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      // Aquí más adelante limpiarás tokens / sesión real.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi cuenta'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cabecera con avatar y nombre (mock por ahora)
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, Cliente',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Aquí verás la información de tu perfil.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================== SECCIÓN PEDIDOS ==================
          Text(
            'Pedidos',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          _AccountOptionCard(
            icon: Icons.receipt_long_outlined,
            title: 'Ver historial de pedidos',
            subtitle:
                'Consulta pedidos entregados o cancelados y su estado.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OrdersHistoryPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // ================== SECCIÓN SOPORTE / PQR ==================
          Text(
            'Soporte y reclamos',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          _AccountOptionCard(
            icon: Icons.support_agent_outlined,
            title: 'Mis PQR / Reclamos',
            subtitle:
                'Revisa el estado de tus Peticiones, Quejas o Reclamos.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PqrListPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ================== SECCIÓN CONFIGURACIÓN ==================
          Text(
            'Configuración',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Editar direcciones
          _AccountOptionCard(
            icon: Icons.location_on_outlined,
            title: 'Direcciones de entrega',
            subtitle: 'Administra tus direcciones guardadas.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddressListPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Ver términos y políticas
          _AccountOptionCard(
            icon: Icons.description_outlined,
            title: 'Términos y privacidad',
            subtitle:
                'Consulta los Términos de uso y la Política de datos.',
            onTap: () => _showLegalSheet(context),
          ),

          const SizedBox(height: 8),

          // Cerrar sesión
          _AccountOptionCard(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta en este dispositivo.',
            onTap: () => _confirmLogout(context),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AccountOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
