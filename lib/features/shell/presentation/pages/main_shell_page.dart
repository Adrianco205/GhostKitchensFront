// lib/features/shell/presentation/pages/main_shell_page.dart
import 'package:flutter/material.dart';

// Home dentro de shell
import 'package:ghost_kitchens_app/features/shell/presentation/home_page.dart';

// Cart
import 'package:ghost_kitchens_app/features/cart/presentation/pages/cart_page.dart';

// ✅ Profile correcto (dentro de shell, NO el de features/profile)
import 'package:ghost_kitchens_app/features/profile/presentation/pages/profile_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      HomePage(),     // Inicio
      CartPage(),     // Carrito
      ProfilePage(),  // Cuenta
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orange = theme.colorScheme.primary;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: theme.scaffoldBackgroundColor,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}
