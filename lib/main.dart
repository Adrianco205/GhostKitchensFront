import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/provider/cart_provider.dart';
import 'package:ghost_kitchens_app/features/auth/presentation/pages/login_page.dart'; // O SplashPage

void main() {
  runApp(
    // 👇 ESTO ES LO QUE SOLUCIONA LA PANTALLA ROJA
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghost Kitchens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
        ),
      ),
      home: const LoginPage(),
    );
  }
}