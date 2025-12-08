import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/support/data/datasource/support_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/support/data/models/pqr_dto.dart';
import 'package:ghost_kitchens_app/features/support/presentation/pages/pqr_create_page.dart';
import 'package:ghost_kitchens_app/features/support/presentation/pages/pqr_detail_page.dart';

class PqrListPage extends StatefulWidget {
  const PqrListPage({super.key});

  @override
  State<PqrListPage> createState() => _PqrListPageState();
}

class _PqrListPageState extends State<PqrListPage> {
  late SupportRemoteDataSource _dataSource;
  late Future<List<PqrDto>> _pqrFuture;

  @override
  void initState() {
    super.initState();
    _dataSource = SupportRemoteDataSource(ApiClient());
    _loadData();
  }

  void _loadData() {
    setState(() {
      _pqrFuture = _dataSource.getHistory();
    });
  }

  // Función para dar color según el estado
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ABIERTO': return Colors.orange;
      case 'CERRADO': return Colors.green;
      case 'EN PROCESO': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Reclamos / PQR"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Botón flotante para crear nueva PQR
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Esperamos a que vuelva de la pantalla de crear para recargar la lista
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PqrCreatePage()),
          );
          _loadData(); // Recargar lista al volver
        },
      ),
      body: FutureBuilder<List<PqrDto>>(
        future: _pqrFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final list = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final pqr = list[index];
              return Card(
                color: const Color(0xFF1E2029), // Tu color de tarjeta oscuro
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Ir al detalle
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PqrDetailPage(pqrId: pqr.id)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ticket #${pqr.id}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                            // Badge de Estado
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(pqr.estado).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getStatusColor(pqr.estado).withOpacity(0.5)),
                              ),
                              child: Text(
                                pqr.estado,
                                style: TextStyle(
                                  color: _getStatusColor(pqr.estado),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Pedido Asociado: #${pqr.pedidoId}",
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pqr.motivo,
                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text("No tienes reclamos activos", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}