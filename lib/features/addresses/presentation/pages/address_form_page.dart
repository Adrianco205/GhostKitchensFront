import 'package:flutter/material.dart';

/// Resultado que devuelve el formulario al guardar.
/// Luego lo puedes reemplazar por tu AddressDto si quieres.
class AddressFormResult {
  final int? id; // para edición, puede venir con ID
  final String alias;
  final String direccionTexto;
  final String? ciudad;

  const AddressFormResult({
    this.id,
    required this.alias,
    required this.direccionTexto,
    this.ciudad,
  });
}

class AddressFormPage extends StatefulWidget {
  /// Si viene con datos → modo edición. Si es null → nueva dirección.
  final AddressFormResult? initialAddress;

  const AddressFormPage({super.key, this.initialAddress});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _aliasController;
  late final TextEditingController _direccionController;
  late final TextEditingController _ciudadController;

  bool get _isEdit => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();

    _aliasController = TextEditingController(
      text: widget.initialAddress?.alias ?? '',
    );
    _direccionController = TextEditingController(
      text: widget.initialAddress?.direccionTexto ?? '',
    );
    _ciudadController = TextEditingController(
      text: widget.initialAddress?.ciudad ?? '',
    );
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    final result = AddressFormResult(
      id: widget.initialAddress?.id,
      alias: _aliasController.text.trim(),
      direccionTexto: _direccionController.text.trim(),
      ciudad: _ciudadController.text.trim().isEmpty
          ? null
          : _ciudadController.text.trim(),
    );

    // 👇 Devolvemos el resultado al caller (AddressListPage o quien sea)
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar dirección' : 'Nueva dirección'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Completa los datos de tu dirección de entrega.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Alias
                TextFormField(
                  controller: _aliasController,
                  decoration: const InputDecoration(
                    labelText: 'Alias (opcional)',
                    hintText: 'Casa, trabajo, apartamento…',
                    prefixIcon: Icon(Icons.tag_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Dirección
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    hintText: 'Cra 50 # 30-20, Barrio El Bosque',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La dirección es obligatoria';
                    }
                    if (value.trim().length < 5) {
                      return 'Ingresa una dirección válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ciudad
                TextFormField(
                  controller: _ciudadController,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad (opcional)',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSavePressed,
                    child: Text(_isEdit ? 'Guardar cambios' : 'Guardar'),
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
