import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/addresses/data/datasource/address_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/addresses/data/models/address_dto.dart';

class AddressFormPage extends StatefulWidget {
  final AddressDto? addressToEdit; // Si viene null, es crear. Si trae datos, es editar.

  const AddressFormPage({super.key, this.addressToEdit});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _direccionController;
  late TextEditingController _deptoController;
  late TextEditingController _municipioController;
  late TextEditingController _barrioController;
  late TextEditingController _aptoController;
  late TextEditingController _indicacionesController;

  bool _isLoading = false;
  late AddressRemoteDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = AddressRemoteDataSource(ApiClient());

    // Inicializar controladores con datos si estamos editando
    final addr = widget.addressToEdit;
    _direccionController = TextEditingController(text: addr?.direccionExacta ?? '');
    _deptoController = TextEditingController(text: addr?.departamento ?? 'Bolívar');
    _municipioController = TextEditingController(text: addr?.municipio ?? 'Cartagena');
    _barrioController = TextEditingController(text: addr?.barrio ?? '');
    _aptoController = TextEditingController(text: addr?.apartamentoCasa ?? '');
    _indicacionesController = TextEditingController(text: addr?.indicaciones ?? '');
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _deptoController.dispose();
    _municipioController.dispose();
    _barrioController.dispose();
    _aptoController.dispose();
    _indicacionesController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dto = AddressDto(
        direccionExacta: _direccionController.text,
        departamento: _deptoController.text,
        municipio: _municipioController.text,
        barrio: _barrioController.text,
        apartamentoCasa: _aptoController.text.isEmpty ? null : _aptoController.text,
        indicaciones: _indicacionesController.text.isEmpty ? null : _indicacionesController.text,
      );

      if (widget.addressToEdit == null) {
        // CREAR
        await _dataSource.createAddress(dto);
      } else {
        // EDITAR (Usamos el ID que vino en el objeto original)
        await _dataSource.updateAddress(widget.addressToEdit!.id!, dto);
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Volver y recargar

      final action = widget.addressToEdit == null ? "creada" : "actualizada";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dirección $action con éxito"), backgroundColor: Colors.green),
      );

    } catch (e) {
      String msg = "Error al guardar";
      if (e is DioException) {
        msg = e.response?.data['detail']?.toString() ?? e.message ?? "Error desconocido";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.addressToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Editar Dirección" : "Nueva Dirección")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ... (Mismos campos de texto que tenías antes: Depto, Muni, Barrio, Dirección, Apto, Indicaciones) ...
              // COPIA LOS TEXTFORMFIELDS DE TU VERSIÓN ANTERIOR AQUÍ PARA NO REPETIRLOS,
              // SOLO ASEGURATE DE USAR LOS CONTROLADORES QUE INICIALICÉ ARRIBA.

              // Ejemplo rápido de uno:
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: "Dirección", prefixIcon: Icon(Icons.pin_drop)),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barrioController,
                decoration: const InputDecoration(labelText: "Barrio", prefixIcon: Icon(Icons.holiday_village)),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              // ... Pon el resto de tus campos aquí ...

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? "Actualizar" : "Guardar", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}