// lib/features/auth/domain/entities/auth_session.dart
import 'usuario.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final Usuario usuario;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.usuario,
  });
}
