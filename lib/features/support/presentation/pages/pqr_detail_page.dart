import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/support/data/datasource/support_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/support/data/models/pqr_dto.dart';

class PqrDetailPage extends StatefulWidget {
  final int pqrId;
  const PqrDetailPage({super.key, required this.pqrId});

  @override
  State<PqrDetailPage> createState() => _PqrDetailPageState();
}

class _PqrDetailPageState extends State<PqrDetailPage> {
  late Future<PqrDto> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = SupportRemoteDataSource(ApiClient()).getDetail(widget.pqrId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle PQR #${widget.pqrId}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<PqrDto>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text("Error al cargar detalle"));

          final pqr = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de estado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2029),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: Colors.orange, width: 4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Estado actual", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(pqr.estado, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _infoItem("ID del Pedido Asociado", "#${pqr.pedidoId}"),
                _infoItem("Motivo", pqr.motivo),

                const SizedBox(height: 16),
                const Text("Descripción detallada", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2029),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pqr.descripcion ?? "Sin descripción",
                    style: const TextStyle(color: Colors.white, height: 1.5),
                  ),
                ),

                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    "Pronto un asesor se pondrá en contacto contigo.",
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}