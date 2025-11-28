// lib/features/addresses/presentation/pages/address_form_page.dart
import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/core/network/api_endpoints.dart';
import 'package:ghost_kitchens_app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _aliasCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();

  final ApiClient _apiClient = ApiClient();
  final SecureStorage _secureStorage = SecureStorage();

  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _direccionCtrl.dispose();
    _ciudadCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final token = await _secureStorage.accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de acceso');
      }

      final body = {
        'alias': _aliasCtrl.text.trim().isEmpty ? null : _aliasCtrl.text.trim(),
        'direccion_texto': _direccionCtrl.text.trim(),
        'ciudad': _ciudadCtrl.text.trim().isEmpty ? null : _ciudadCtrl.text.trim(),
      };

      await _apiClient.post(
        ApiEndpoints.userAddresses, // 👈 usa el mismo que en el home/lista
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true); // true => se creó una dirección
    } on DioException catch (e) {
      setState(() {
        _error = 'Error ${e.response?.statusCode ?? ''} al guardar la dirección';
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo guardar la dirección';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva dirección'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _aliasCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Alias (Casa, Trabajo...)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _direccionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'La dirección es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ciudadCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.redAccent),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar dirección'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
