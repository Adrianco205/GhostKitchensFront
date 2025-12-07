// lib/features/support/presentation/pages/ticket_create_page.dart

import 'package:flutter/material.dart';

/// Pantalla para crear una nueva PQR / Reclamo.
/// 
/// Por ahora solo hace validaciones básicas y muestra un SnackBar
/// simulando el envío al backend.
class TicketCreatePage extends StatefulWidget {
  const TicketCreatePage({super.key});

  @override
  State<TicketCreatePage> createState() => _TicketCreatePageState();
}

class _TicketCreatePageState extends State<TicketCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _orderIdController = TextEditingController();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _orderIdController.dispose();
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Aquí luego conectas al backend con tu servicio / repository.
    // Por ahora solo mostramos un mensaje y volvemos atrás.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PQR registrada (mock).'),
      ),
    );

    Navigator.of(context).pop(); // Cerrar y volver a la lista.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar PQR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cuéntanos qué ocurrió con tu pedido',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // ID del pedido
              TextFormField(
                controller: _orderIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del pedido',
                  hintText: 'Ej: 123',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el ID del pedido';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'El ID del pedido debe ser numérico';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Motivo corto
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo del reclamo',
                  hintText: 'Ej: Pedido incompleto',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Describe brevemente el motivo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción detallada
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada',
                  hintText: 'Cuéntanos con más detalle qué ocurrió...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor describe la situación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón de enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Enviar PQR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
