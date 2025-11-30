// lib/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/core/network/api_endpoints.dart';
import 'package:ghost_kitchens_app/core/storage/secure_storage.dart';

import 'package:ghost_kitchens_app/features/addresses/data/models/address_dto.dart';
import 'package:ghost_kitchens_app/features/addresses/presentation/pages/address_form_page.dart';

import 'package:ghost_kitchens_app/legal/terms_policies.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Estos valores se llenan desde el backend
  String? _userName;
  String? _email;

  bool _isLoadingProfile = false;

  final ApiClient _apiClient = ApiClient();
  final SecureStorage _secureStorage = SecureStorage();

  List<AddressDto> _addresses = [];
  bool _isLoadingAddresses = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ======== PERFIL (nombre + correo desde /me) ========

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final token = await _secureStorage.accessToken;
      if (token == null || token.isEmpty) {
        // No hay sesión → dejamos los valores por defecto
        return;
      }

      final response = await _apiClient.get(
        ApiEndpoints.me,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data as Map<String, dynamic>;

      // Ajusta estas keys a como tu backend devuelve el usuario
      final String nombre = (data['nombre'] ?? data['first_name'] ?? '') as String;
      final String apellido =
          (data['apellido'] ?? data['last_name'] ?? '') as String;
      final String email = (data['email'] ?? '') as String;

      final String fullName = ('$nombre $apellido').trim();

      setState(() {
        _userName = fullName.isEmpty ? null : fullName;
        _email = email.isEmpty ? null : email;
      });
    } catch (e) {
      debugPrint('ERROR al cargar perfil (/me): $e');
      // No mostramos error fuerte, solo dejamos los textos por defecto
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  // ======== DIRECCIONES (mismo flujo que en Home) ========

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
      debugPrint('ERROR al cargar direcciones (Profile): $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudieron cargar tus direcciones. Intenta de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddresses = false;
        });
      }
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
                  'Mis direcciones',
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
                                  onTap: () {
                                    Navigator.of(context).pop();
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

                        if (!mounted) return;

                        if (created == true) {
                          await _loadAddresses();
                          Navigator.of(context).pop();
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

  // ======== TÉRMINOS Y POLÍTICAS ========

  void _openTermsAndPolicies() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: scrollController,
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
                      'Términos y condiciones',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      kTermsOfServiceText,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Política de tratamiento de datos',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      kPrivacyPolicyText,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ======== BUILD ========

  @override
  Widget build(BuildContext context) {
    final displayName = _userName ?? 'Usuario';
    final displayEmail = _email ?? 'correo@example.com';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const SizedBox(height: 15),

          // Avatar
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 45),
                ),
                if (_isLoadingProfile)
                  const SizedBox(
                    height: 90,
                    width: 90,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Nombre
          Center(
            child: Text(
              displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          const SizedBox(height: 5),

          // Email
          Center(
            child: Text(
              displayEmail,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          const SizedBox(height: 30),

          // Mis direcciones
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text("Mis direcciones"),
            onTap: _openAddressSelector,
          ),

          // Términos y políticas
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Términos y políticas"),
            onTap: _openTermsAndPolicies,
          ),
        ],
      ),
    );
  }
}
