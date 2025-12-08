import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/addresses/data/datasource/address_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/addresses/data/models/address_dto.dart';
import 'package:ghost_kitchens_app/features/addresses/presentation/pages/address_form_page.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  late AddressRemoteDataSource _dataSource;
  late Future<List<AddressDto>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _dataSource = AddressRemoteDataSource(ApiClient());
    _loadData();
  }

  void _loadData() {
    setState(() {
      _addressesFuture = _dataSource.getAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Direcciones")),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text("Nueva Dirección", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () async {
          // Si retorna true, recargamos la lista
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const AddressFormPage())
          );
          if (result == true) {
            _loadData();
          }
        },
      ),
      body: FutureBuilder<List<AddressDto>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          final list = snapshot.data!;
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No tienes direcciones guardadas", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              final addr = list[index];
              
              return ListTile(
                leading: const Icon(Icons.place, color: Colors.orange),
                title: Text(
                  addr.direccionExacta,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${addr.barrio}, ${addr.municipio}",
                      style: const TextStyle(color: Colors.grey)
                    ),
                    if (addr.apartamentoCasa != null && addr.apartamentoCasa!.isNotEmpty)
                      Text(
                        "Interior/Apto: ${addr.apartamentoCasa}",
                        style: TextStyle(color: Colors.orange[300], fontSize: 12)
                      ),
                  ],
                ),
                // Botones de acción (Editar / Borrar)
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BOTÓN EDITAR
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                      onPressed: () async {
                        // Navegamos al formulario PASANDO la dirección actual
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddressFormPage(addressToEdit: addr), // Pasamos datos
                          ),
                        );
                        if (result == true) {
                          _loadData(); // Recargamos la lista si se editó
                        }
                      },
                    ),
                    // BOTÓN BORRAR
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () async {
                        // Diálogo de confirmación
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1E2029),
                            title: const Text("¿Eliminar?", style: TextStyle(color: Colors.white)),
                            content: const Text("Esta acción no se puede deshacer.", style: TextStyle(color: Colors.grey)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Eliminar", style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );

                        if (confirm == true && addr.id != null) {
                          await _dataSource.deleteAddress(addr.id!);
                          _loadData(); // Recargar lista
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}