import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Importar Dio para capturar DioException
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/user_dto.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Instancia del DataSource (Corregido el nombre)
  late AuthRemoteDataSource _authDataSource;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    // Corregido: Usamos la clase concreta, no Impl
    _authDataSource = AuthRemoteDataSource(apiClient);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // 1. Crear el DTO con los datos del formulario
      // CORREGIDO: Usamos UserRegisterDto en lugar de UsuarioRegisterDto
      final registroDto = UserRegisterDto(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        celular: _celularController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Llamar al backend
      await _authDataSource.register(registroDto);

      if (!mounted) return;

      // 3. Éxito: Mostrar mensaje y volver al Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada con éxito! Inicia sesión.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Vuelve atrás (al Login)

    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Error al registrar usuario';

      if (e is DioException) {
        if (e.response != null && e.response?.data != null) {
          final detail = e.response?.data['detail'];
          errorMessage = detail?.toString() ?? 'Error desconocido en el servidor';
        } else {
          errorMessage = 'Error de conexión con el servidor';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear cuenta")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _apellidoController,
                        decoration: const InputDecoration(labelText: 'Apellido'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => !v!.contains('@') ? 'Correo inválido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _celularController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Celular',
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                  validator: (v) => v!.length < 7 ? 'Número inválido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v!.length < 4 ? 'Mínimo 4 caracteres' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onRegisterPressed,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Crear cuenta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}