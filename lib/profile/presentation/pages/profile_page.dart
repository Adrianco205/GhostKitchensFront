import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Más adelante puedes reemplazar esto con tus datos reales del usuario
    final String userName = "Usuario";
    final String email = "correo@example.com";

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const SizedBox(height: 15),

          // Avatar
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 45),
            ),
          ),

          const SizedBox(height: 20),

          // Nombre
          Center(
            child: Text(
              userName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          const SizedBox(height: 5),

          // Email
          Center(
            child: Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          const SizedBox(height: 30),

          // Botón editar perfil
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Editar perfil"),
            onTap: () {
              // TODO: Navegar a la pantalla de edición
              // Navigator.pushNamed(context, '/profile/edit');
            },
          ),

          // Dirección
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text("Mis direcciones"),
            onTap: () {
              // TODO: Navegar a direcciones
              // Navigator.pushNamed(context, '/addresses');
            },
          ),

          // Historial de pedidos
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text("Historial de pedidos"),
            onTap: () {
              // TODO: Navigator push a orders_history_page
            },
          ),

          // Política / Términos
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Términos y políticas"),
            onTap: () {
              // TODO: Navigate to terms page
            },
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: () {
              // TODO: Implementar logout
            },
          ),
        ],
      ),
    );
  }
}
