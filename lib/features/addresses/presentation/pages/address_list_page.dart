import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/features/addresses/presentation/pages/address_form_page.dart';

/// Modelo interno para manejar la lista en esta pantalla.
/// Más adelante puedes reemplazarlo por tu AddressDto real.
class AddressItem {
  int id;
  String alias;
  String direccionTexto;
  String? ciudad;

  AddressItem({
    required this.id,
    required this.alias,
    required this.direccionTexto,
    this.ciudad,
  });
}

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  /// Datos mock iniciales. Luego esto vendrá del backend.
  final List<AddressItem> _addresses = [
    AddressItem(
      id: 1,
      alias: 'casa',
      direccionTexto: 'San jose',
      ciudad: 'cartagena',
    ),
    AddressItem(
      id: 2,
      alias: 'trabajo',
      direccionTexto: 'pepe',
      ciudad: 'monteria',
    ),
    AddressItem(
      id: 3,
      alias: 'jaja',
      direccionTexto: 'jaja',
      ciudad: 'jaja',
    ),
  ];

  int _nextId = 4;

  Future<void> _onAddAddress() async {
    final result = await Navigator.of(context).push<AddressFormResult>(
      MaterialPageRoute(
        builder: (_) => const AddressFormPage(),
      ),
    );

    if (result == null) return;

    setState(() {
      _addresses.add(
        AddressItem(
          id: _nextId++,
          alias: result.alias,
          direccionTexto: result.direccionTexto,
          ciudad: result.ciudad,
        ),
      );
    });

    // Aquí luego puedes llamar al backend para guardar la nueva dirección.
  }

  Future<void> _onEditAddress(AddressItem item) async {
    final initial = AddressFormResult(
      id: item.id,
      alias: item.alias,
      direccionTexto: item.direccionTexto,
      ciudad: item.ciudad,
    );

    final result = await Navigator.of(context).push<AddressFormResult>(
      MaterialPageRoute(
        builder: (_) => AddressFormPage(initialAddress: initial),
      ),
    );

    if (result == null) return;

    setState(() {
      final index = _addresses.indexWhere((a) => a.id == item.id);
      if (index != -1) {
        _addresses[index] = AddressItem(
          id: item.id,
          alias: result.alias,
          direccionTexto: result.direccionTexto,
          ciudad: result.ciudad,
        );
      }
    });

    // Aquí luego actualizas en backend.
  }

  void _onDeleteAddress(AddressItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar dirección'),
          content: const Text(
              '¿Seguro que quieres eliminar esta dirección de tu lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _addresses.removeWhere((a) => a.id == item.id);
                });
                // Aquí luego llamas al backend para eliminarla.
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis direcciones'),
      ),
      body: SafeArea(
        child: _addresses.isEmpty
            ? Center(
                child: Text(
                  'Aún no tienes direcciones guardadas.\nAgrega una nueva para empezar.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _addresses.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final addr = _addresses[index];
                  return ListTile(
                    leading: Icon(
                      Icons.location_on_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      addr.alias.isNotEmpty
                          ? '${addr.alias} · ${addr.direccionTexto}'
                          : addr.direccionTexto,
                    ),
                    subtitle: addr.ciudad != null
                        ? Text(addr.ciudad!)
                        : null,
                    onTap: () => _onEditAddress(addr),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _onEditAddress(addr),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _onDeleteAddress(addr),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddAddress,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Nueva dirección'),
      ),
    );
  }
}
