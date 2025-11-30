import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  final AuthRepositoryImpl authRepository;

  const SplashPage({super.key, required this.authRepository});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Simulamos carga inicial (2 segundos) y luego vamos al login
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginPage(
            authRepository: widget.authRepository,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 👇 AQUÍ VA TU LOGO
            Image.asset(
              'lib/assets/images/logo.png',
              width: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'Ghost Kitchens',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
