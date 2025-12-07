// lib/features/support/presentation/pages/ticket_detail_page.dart

import 'package:flutter/material.dart';
import 'pqr_list_page.dart'; // Para usar PqrItem

/// Pantalla de detalle de una PQR / ticket de soporte.
class TicketDetailPage extends StatelessWidget {
  final PqrItem pqr;

  const TicketDetailPage({
    super.key,
    required this.pqr,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'abierto':
        return Colors.orange;
      case 'en proceso':
      case 'en trámite':
        return Colors.blue;
      case 'cerrado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(pqr.status);
    final createdAtStr = _formatDate(pqr.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text('PQR #${pqr.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  backgroundColor: statusColor.withOpacity(0.12),
                  label: Text(
                    pqr.status,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  createdAtStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pedido asociado
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12), // ✅ aquí también
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pedido asociado',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#${pqr.orderId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Motivo
            Text(
              'Motivo del reclamo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pqr.reason,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Descripción detallada (por ahora mock / placeholder)
            Text(
              'Descripción detallada',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // 🔹 Aquí luego conectarás la descripción real que venga del backend.
              'Esta sección mostrará la descripción completa del reclamo una vez se integre con el backend. '
              'Por ahora, solo se visualiza el motivo breve registrado en la lista de PQR.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),

            // Historial / acciones futuras
            Text(
              'Historial y seguimiento',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí podrás ver en el futuro las actualizaciones del estado, respuestas del soporte y cualquier otra acción asociada a esta PQR.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
