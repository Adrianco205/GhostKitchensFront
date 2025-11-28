import 'package:ghost_kitchens_app/features/auth/domain/entities/auth_session.dart';
import 'package:ghost_kitchens_app/features/auth/domain/entities/usuario.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
    String? otp,
  });

  Future<void> registerUser({
    required String nombre,
    required String apellido,
    required String email,
    required String celular,
    required String password,
    required bool aceptaTerminos,
  });

  Future<Usuario> getCurrentUser();

  Future<AuthSession> refreshToken();

  Future<void> logout();

  // Flujos de OTP / password (placeholder por ahora)
  Future<void> requestOtp({
    required String email,
    required String purpose,
  });

  Future<void> verifyOtp({
    required String email,
    required String otp,
    required String purpose,
  });

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
