import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Importar Dio
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/auth/presentation/pages/register_page.dart';
import 'package:ghost_kitchens_app/features/shell/presentation/pages/main_shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // CORREGIDO: Usamos la clase concreta AuthRemoteDataSource
  late AuthRemoteDataSource _authDataSource;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    // CORREGIDO: Instanciamos AuthRemoteDataSource (sin el Impl)
    _authDataSource = AuthRemoteDataSource(apiClient);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 1. Llamar al backend para login
      final response = await _authDataSource.login(email, password);

      // 2. Guardar el token
      final token = response['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      if (!mounted) return;

      // 3. Ir al Home (MainShellPage)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShellPage()),
      );

    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Error al iniciar sesión';

      if (e is DioException) {
        if (e.response != null && e.response?.data != null) {
          final detail = e.response?.data['detail'];
          errorMessage = detail?.toString() ?? 'Credenciales inválidas';
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
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo o Título grande
                const Icon(Icons.restaurant_menu, size: 80, color: Colors.orange),
                const SizedBox(height: 20),
                const Text(
                  "Ghost Kitchens",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Email
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

                // Contraseña
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
                  validator: (v) => v!.isEmpty ? 'Ingresa tu contraseña' : null,
                ),

                const SizedBox(height: 32),

                // Botón Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isLoading ? null : _onLoginPressed,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Ingresar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 16),

                // Ir a Registro
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage())
                    );
                  },
                  child: const Text("¿No tienes cuenta? Regístrate aquí", style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}