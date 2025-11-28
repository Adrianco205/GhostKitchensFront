import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/legal/terms_policies.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _aceptaPolitica = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final RegExp _emailRegex =
      RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp _phoneRegex = RegExp(r'^[0-9]+$');
  final RegExp _passwordUppercase = RegExp(r'[A-Z]');
  final RegExp _passwordLowercase = RegExp(r'[a-z]');
  final RegExp _passwordDigit = RegExp(r'[0-9]');

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceptaPolitica) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los Términos y la Política de Tratamiento de Datos para crear tu cuenta.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Aquí luego conectamos con /auth/register/
    // Ejemplo de payload alineado con UsuarioRegister del Swagger:
    /*
    final payload = {
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'email': _emailController.text.trim(),
      'celular': _celularController.text.trim(),
      'password': _passwordController.text,
      'numero_identificacion': 'PENDIENTE', // lo ajustarás cuando agregues el campo
      'acepta_terminos': _aceptaPolitica,
      'roles_iniciales': ['cliente'],
    };
    */

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro simulado. Falta OTP 😊')),
      );

      Navigator.of(context).pop(); // Volver al login
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Ingresa tu nombre'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _apellidoController,
                          decoration: const InputDecoration(
                            labelText: 'Apellido',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Ingresa tu apellido'
                                  : null,
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
                    controller: _celularController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Celular',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) {
                        return 'Ingresa tu número de celular';
                      }
                      if (!_phoneRegex.hasMatch(v)) {
                        return 'Solo se permiten números';
                      }
                      if (v.length < 8) {
                        return 'El número es muy corto';
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
                      final v = value ?? '';
                      if (v.isEmpty) {
                        return 'Crea una contraseña';
                      }
                      if (v.length < 8) {
                        return 'Mínimo 8 caracteres';
                      }
                      if (!_passwordUppercase.hasMatch(v) ||
                          !_passwordLowercase.hasMatch(v) ||
                          !_passwordDigit.hasMatch(v)) {
                        return 'Debe tener mayúsculas, minúsculas y números';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Checkbox + texto clicable
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _aceptaPolitica,
                        onChanged: (value) {
                          setState(() => _aceptaPolitica = value ?? false);
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[200],
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'Al continuar aceptas nuestros ',
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
                                text:
                                    'Política de Tratamiento de Datos',
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

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onRegisterPressed,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Crear cuenta'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
