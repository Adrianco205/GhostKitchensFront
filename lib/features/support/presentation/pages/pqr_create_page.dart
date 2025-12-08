import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/support/data/datasource/support_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/support/data/models/pqr_dto.dart';

class PqrCreatePage extends StatefulWidget {
  const PqrCreatePage({super.key});

  @override
  State<PqrCreatePage> createState() => _PqrCreatePageState();
}

class _PqrCreatePageState extends State<PqrCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _pedidoIdController = TextEditingController();
  final _motivoController = TextEditingController();
  final _descController = TextEditingController();

  bool _isLoading = false;
  late SupportRemoteDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = SupportRemoteDataSource(ApiClient());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dto = PqrCreateDto(
        pedidoId: int.parse(_pedidoIdController.text),
        motivo: _motivoController.text,
        descripcion: _descController.text,
      );

      await _dataSource.createPqr(dto);

      if (!mounted) return;

      // Éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Reclamo radicado con éxito!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Volver a la lista

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Reclamo"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Cuéntanos qué ocurrió con tu pedido", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 24),

              // ID del Pedido
              TextFormField(
                controller: _pedidoIdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration("ID del Pedido (Ej: 1)", Icons.receipt),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),

              // Motivo (Título corto)
              TextFormField(
                controller: _motivoController,
                decoration: _inputDecoration("Motivo del reclamo (Ej: Pedido incompleto)", Icons.warning_amber),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),

              // Descripción larga
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: _inputDecoration("Descripción detallada...", Icons.description).copyWith(
                  alignLabelWithHint: true, // Para que el ícono quede arriba
                ),
                validator: (v) => v!.isEmpty ? "Danos más detalles por favor" : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Enviar PQR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Estilo común para los inputs oscuros
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1E2029),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }
}