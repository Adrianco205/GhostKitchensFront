// lib/features/shell/presentation/profile_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// API & Datos
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/user_dto.dart';

// Navegación a otras pantallas
import 'package:ghost_kitchens_app/features/orders/presentation/pages/orders_history_page.dart';
import 'package:ghost_kitchens_app/features/support/presentation/pages/pqr_list_page.dart';
import 'package:ghost_kitchens_app/features/addresses/presentation/pages/address_list_page.dart';
import 'package:ghost_kitchens_app/features/support/presentation/pages/legal.dart';
import 'package:ghost_kitchens_app/features/auth/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variables para la carga de datos del usuario
  late AuthRemoteDataSource _authDataSource;
  late Future<UserDto> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Inicializamos el DataSource y la petición al perfil
    _authDataSource = AuthRemoteDataSource(ApiClient());
    _profileFuture = _authDataSource.getUserProfile();
  }

  // Lógica para mostrar la hoja de términos legales (Tu código original)
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              title: const Text('Política de Tratamiento de Datos'),
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

  // Lógica de cierre de sesión
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Seguro que deseas cerrar sesión en este dispositivo?'),
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Borramos token y datos locales

      if (!mounted) return;

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
        automaticallyImplyLeading: false, // Evita la flecha de volver si es una pestaña principal
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================== CABECERA DE USUARIO (DINÁMICA) ==================
          FutureBuilder<UserDto>(
            future: _profileFuture,
            builder: (context, snapshot) {
              // Valores por defecto mientras carga
              String nombreMostrar = "Cargando...";
              String emailMostrar = "";
              bool isLoading = snapshot.connectionState == ConnectionState.waiting;

              if (snapshot.hasData) {
                nombreMostrar = "Hola, ${snapshot.data!.nombre}";
                emailMostrar = snapshot.data!.email;
              } else if (snapshot.hasError) {
                nombreMostrar = "Hola, Invitado";
                emailMostrar = "Error al cargar perfil";
              }

              return Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary, // Color naranja
                    child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreMostrar,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        emailMostrar.isNotEmpty ? emailMostrar : 'Información de tu perfil',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ================== SECCIÓN PEDIDOS ==================
          Text(
            'Pedidos',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          _AccountOptionCard(
            icon: Icons.receipt_long_outlined,
            title: 'Ver historial de pedidos',
            subtitle: 'Consulta pedidos entregados o cancelados y su estado.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrdersHistoryPage()),
              );
            },
          ),

          const SizedBox(height: 16),

          // ================== SECCIÓN SOPORTE / PQR ==================
          Text(
            'Soporte y reclamos',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          _AccountOptionCard(
            icon: Icons.support_agent_outlined,
            title: 'Mis PQR / Reclamos',
            subtitle: 'Revisa el estado de tus Peticiones, Quejas o Reclamos.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PqrListPage()),
              );
            },
          ),

          const SizedBox(height: 24),

          // ================== SECCIÓN CONFIGURACIÓN ==================
          Text(
            'Configuración',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Editar direcciones
          _AccountOptionCard(
            icon: Icons.location_on_outlined,
            title: 'Direcciones de entrega',
            subtitle: 'Administra tus direcciones guardadas.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddressListPage()),
              );
            },
          ),

          const SizedBox(height: 8),

          // Ver términos y políticas
          _AccountOptionCard(
            icon: Icons.description_outlined,
            title: 'Términos y privacidad',
            subtitle: 'Consulta los Términos de uso y la Política de datos.',
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

// Widget auxiliar para las tarjetas de opciones
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
      // Usamos un color oscuro específico si quieres mantener consistencia visual
      color: const Color(0xFF1E2029),
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
              Icon(icon, size: 26, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}