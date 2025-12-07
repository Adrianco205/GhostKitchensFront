import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';

// Providers
import 'package:ghost_kitchens_app/features/cart/presentation/pages/cart_provider.dart';
import 'package:ghost_kitchens_app/features/orders/presentation/pages/order_history_provider.dart';

void main() {
  runApp(const GhostKitchensApp());
}

class GhostKitchensApp extends StatelessWidget {
  const GhostKitchensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderHistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Ghost Kitchens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SplashPage(),
      ),
    );
  }
}
