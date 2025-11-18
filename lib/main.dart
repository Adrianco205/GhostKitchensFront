import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() {
  runApp(const GhostKitchensApp());
}

class GhostKitchensApp extends StatelessWidget {
  const GhostKitchensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghost Kitchens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashPage(),
    );
  }
}
