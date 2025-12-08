import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/kitchens/data/datasource/kitchen_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/kitchens/data/models/kitchen_dto.dart';
import 'package:ghost_kitchens_app/features/kitchens/presentation/pages/kitchen_detail_page.dart'; // Importa el paso 4

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late KitchenRemoteDataSource _kitchenDataSource;
  late Future<List<KitchenDto>> _cocinasFuture;

  @override
  void initState() {
    super.initState();
    // Inyección manual
    _kitchenDataSource = KitchenRemoteDataSource(ApiClient());
    _cocinasFuture = _kitchenDataSource.getCocinas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cocinas Disponibles"),
        automaticallyImplyLeading: false, // Quita la flecha de volver si es el home
      ),
      body: FutureBuilder<List<KitchenDto>>(
        future: _cocinasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay cocinas disponibles."));
          }

          final cocinas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cocinas.length,
            itemBuilder: (context, index) {
              final cocina = cocinas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    // Navegar al detalle pasando el ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KitchenDetailPage(kitchenId: cocina.id),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen
                      Image.network(
                        cocina.imagenUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => Container(
                          height: 150, color: Colors.grey[800], 
                          child: const Icon(Icons.restaurant, color: Colors.white)
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cocina.nombre,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(cocina.descripcion, style: TextStyle(color: Colors.grey[400])),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(cocina.ubicacion, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}