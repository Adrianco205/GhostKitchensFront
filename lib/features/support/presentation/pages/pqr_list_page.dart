// lib/features/support/presentation/pages/pqr_list_page.dart

import 'package:flutter/material.dart';

/// Pantalla sencilla para listar las PQR del cliente.
///
/// Por ahora está hecha con datos mock (solo front),
/// pero la estructura ya queda lista para conectar a backend.
class PqrListPage extends StatelessWidget {
  const PqrListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🔹 Datos de ejemplo (luego se reemplazan por datos reales)
    final List<_PqrItem> mockPqrs = [
      _PqrItem(
        id: 1,
        orderId: 3,
        reason: 'Pedido incompleto',
        status: 'Abierto',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _PqrItem(
        id: 2,
        orderId: 1,
        reason: 'Comida en mal estado',
        status: 'En proceso',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      _PqrItem(
        id: 3,
        orderId: 2,
        reason: 'Cobro incorrecto',
        status: 'Cerrado',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis PQR / Reclamos'),
      ),
      body: mockPqrs.isEmpty
          ? Center(
              child: Text(
                'Aún no has registrado reclamos.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockPqrs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final pqr = mockPqrs[index];
                return _PqrCard(pqr: pqr);
              },
            ),
    );
  }
}

/// Modelo UI interno para la lista de PQR.
class _PqrItem {
  final int id;
  final int orderId;
  final String reason;
  final String status; // Abierto / En proceso / Cerrado
  final DateTime createdAt;

  _PqrItem({
    required this.id,
    required this.orderId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });
}

/// Tarjeta para cada reclamo.
class _PqrCard extends StatelessWidget {
  final _PqrItem pqr;

  const _PqrCard({required this.pqr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dateStr =
        '${pqr.createdAt.day.toString().padLeft(2, '0')}/'
        '${pqr.createdAt.month.toString().padLeft(2, '0')}/'
        '${pqr.createdAt.year}';

    final Color statusColor;
    switch (pqr.status.toLowerCase()) {
      case 'abierto':
        statusColor = Colors.orange;
        break;
      case 'en proceso':
      case 'en trámite':
        statusColor = Colors.blue;
        break;
      case 'cerrado':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: id + estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PQR #${pqr.id}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pqr.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              'Pedido asociado: #${pqr.orderId}',
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 4),

            Text(
              pqr.reason,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 4),

            Text(
              'Registrado el $dateStr',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
