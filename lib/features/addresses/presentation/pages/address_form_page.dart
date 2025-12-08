import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/addresses/data/datasource/address_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/addresses/data/models/address_dto.dart';

class AddressFormPage extends StatefulWidget {
  final AddressDto? addressToEdit; // Si viene null es crear, si no es editar

  const AddressFormPage({super.key, this.addressToEdit});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para todos los campos detallados
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

    // Si estamos editando, llenamos los campos. Si no, valores por defecto.
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
      // Creamos el objeto con la estructura detallada
      final dto = AddressDto(
        direccionExacta: _direccionController.text.trim(),
        departamento: _deptoController.text.trim(),
        municipio: _municipioController.text.trim(),
        barrio: _barrioController.text.trim(),
        apartamentoCasa: _aptoController.text.isEmpty ? null : _aptoController.text.trim(),
        indicaciones: _indicacionesController.text.isEmpty ? null : _indicacionesController.text.trim(),
      );

      if (widget.addressToEdit == null) {
        // CREAR
        await _dataSource.createAddress(dto);
      } else {
        // EDITAR
        await _dataSource.updateAddress(widget.addressToEdit!.id!, dto);
      }

      if (!mounted) return;

      // Volver a la lista indicando éxito
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dirección guardada correctamente"), backgroundColor: Colors.green),
      );

    } catch (e) {
      String msg = "Error al guardar";

      // --- CORRECCIÓN DE SEGURIDAD PARA ERRORES ---
      if (e is DioException) {
        if (e.response != null && e.response?.data != null) {
          final data = e.response!.data;
          // Verificamos si la respuesta es un JSON (Map) y tiene 'detail'
          if (data is Map && data.containsKey('detail')) {
            msg = data['detail'].toString();
          } else {
            // Si es un string directo (ej: error 500 texto plano), lo mostramos tal cual
            msg = data.toString();
          }
        } else {
          msg = e.message ?? "Error de conexión";
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.addressToEdit == null ? "Nueva Dirección" : "Editar Dirección")
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Detalles de ubicación", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 24),

              // 1. Departamento y Municipio
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _deptoController,
                      decoration: const InputDecoration(labelText: "Departamento", prefixIcon: Icon(Icons.map)),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _municipioController,
                      decoration: const InputDecoration(labelText: "Municipio", prefixIcon: Icon(Icons.location_city)),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Barrio
              TextFormField(
                controller: _barrioController,
                decoration: const InputDecoration(labelText: "Barrio", prefixIcon: Icon(Icons.holiday_village)),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),

              // 3. Dirección Exacta
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: "Dirección (Calle, Cra #)", prefixIcon: Icon(Icons.pin_drop)),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),

              // 4. Apto / Casa
              TextFormField(
                controller: _aptoController,
                decoration: const InputDecoration(labelText: "Apto / Casa / Bloque (Opcional)", prefixIcon: Icon(Icons.home)),
              ),
              const SizedBox(height: 16),

              // 5. Indicaciones
              TextFormField(
                controller: _indicacionesController,
                maxLines: 2,
                maxLength: 128,
                decoration: const InputDecoration(labelText: "Indicaciones extra (Opcional)", prefixIcon: Icon(Icons.info_outline)),
              ),

              const SizedBox(height: 32),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.addressToEdit == null ? "Guardar Dirección" : "Actualizar",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}