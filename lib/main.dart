import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/datasource/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() {
  final apiClient = ApiClient();
  final authRemote = AuthRemoteDataSource(apiClient);
  final storage = SecureStorage();
  final authRepository = AuthRepositoryImpl(authRemote, storage);

  runApp(GhostKitchensApp(authRepository));
}

class GhostKitchensApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;

  const GhostKitchensApp(this.authRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghost Kitchens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: SplashPage(authRepository: authRepository),
    );
  }
}
