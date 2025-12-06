// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi cuenta'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Aquí verás la información de tu perfil 👤',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
