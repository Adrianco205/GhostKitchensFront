// lib/features/auth/presentation/pages/login_page.dart
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'register_page.dart';
import 'package:ghost_kitchens_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ghost_kitchens_app/features/shell/presentation/pages/main_shell_page.dart';
import 'package:ghost_kitchens_app/legal/terms_policies.dart';

class LoginPage extends StatefulWidget {
  final AuthRepository authRepository;

  const LoginPage({
    super.key,
    required this.authRepository,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final RegExp _emailRegex =
      RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.authRepository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // ✅ Login OK → navegar al home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainShellPage(),
        ),
      );
    } on DioException catch (e) {
      debugPrint(
        'Error login (status: ${e.response?.statusCode}) body: ${e.response?.data}',
      );

      if (!mounted) return;

      String message =
          'No se pudo iniciar sesión. Intenta nuevamente.';

      final status = e.response?.statusCode;
      final data = e.response?.data;

      // Aquí asumimos que el backend devuelve algo tipo:
      // { "detail": "USER_NOT_FOUND" }  o  { "detail": "WRONG_PASSWORD" }
      if (status == 401 || status == 404) {
        String? detail;

        if (data is Map<String, dynamic>) {
          final d = data['detail'];
          if (d is String) {
            detail = d;
          } else if (d is Map<String, dynamic> && d['code'] is String) {
            // por si usas { "detail": { "code": "USER_NOT_FOUND", ... } }
            detail = d['code'] as String;
          }
        }

        switch (detail) {
          case 'USER_NOT_FOUND':
          case 'user_not_found':
            message = 'No existe una cuenta registrada con ese correo.';
            break;
          case 'WRONG_PASSWORD':
          case 'wrong_password':
          case 'INCORRECT_PASSWORD':
            message = 'La contraseña es incorrecta.';
            break;
          default:
            // si no podemos distinguir, mostramos uno genérico
            message = 'Correo o contraseña incorrectos.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      debugPrint('Error inesperado en login: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocurrió un error inesperado. Intenta nuevamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: SingleChildScrollView(
          child: Text(kTermsOfServiceText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Política de Tratamiento de Datos'),
        content: SingleChildScrollView(
          child: Text(kPrivacyPolicyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Bienvenido a\nGhost Kitchens',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión para pedir de tus cocinas favoritas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!_emailRegex.hasMatch(value.trim())) {
                            return 'Correo no válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          if (value.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // luego conectar con /auth/password/forgot/
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onLoginPressed,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Iniciar sesión'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegisterPage(
                              authRepository: widget.authRepository,
                            ),
                          ),
                        );
                      },
                      child: const Text('Crear cuenta'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: Colors.grey.shade800),
                const SizedBox(height: 8),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Al continuar aceptas nuestros ',
                        ),
                        TextSpan(
                          text: 'Términos',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _showTermsDialog,
                        ),
                        const TextSpan(text: ' y la '),
                        TextSpan(
                          text: 'Política de Tratamiento de Datos',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _showPrivacyDialog,
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
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
