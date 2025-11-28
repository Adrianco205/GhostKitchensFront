import 'package:flutter/material.dart';
import 'package:ghost_kitchens_app/features/shell/presentation/pages/home_page.dart';
import 'package:ghost_kitchens_app/kitchens/presentation/pages/kitchens_map_page.dart';
import 'package:ghost_kitchens_app/features/cart/presentation/pages/cart_page.dart';
import 'package:ghost_kitchens_app/profile/presentation/pages/profile_page.dart';

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
      HomePage(),        // Inicio
      KitchensMapPage(), // Mapa
      CartPage(),        // Carrito
      ProfilePage(),     // Cuenta
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
  final orange = theme.colorScheme.primary; // tu naranja Ghost Kitchens

  return Scaffold(
    body: _pages[_currentIndex],

    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: orange,                 // naranja seleccionado
      unselectedItemColor: Colors.grey,          // gris no seleccionado
      backgroundColor: theme.scaffoldBackgroundColor, // 👈 AQUÍ EL CAMBIO
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Mapa',
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
