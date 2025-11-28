// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:ghost_kitchens_app/core/storage/secure_storage.dart';
import 'package:ghost_kitchens_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/auth_requests_dto.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/auth_token_response_dto.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/usuario_dto.dart';
import 'package:ghost_kitchens_app/features/auth/domain/entities/auth_session.dart';
import 'package:ghost_kitchens_app/features/auth/domain/entities/usuario.dart';
import 'package:ghost_kitchens_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final IAuthRemoteDataSource _remote;
  final SecureStorage _storage;

  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';

  AuthRepositoryImpl(this._remote, this._storage);

  Future<void> _persistSession(AuthSession session) async {
    await _storage.write(key: _kAccessTokenKey, value: session.accessToken);
    await _storage.write(key: _kRefreshTokenKey, value: session.refreshToken);
  }

  Future<String?> _getAccessToken() => _storage.read(key: _kAccessTokenKey);
  Future<String?> _getRefreshToken() => _storage.read(key: _kRefreshTokenKey);

  // ============ LOGIN REAL contra FastAPI ============
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    String? otp,
  }) async {
    final AuthTokenResponseDto dto = await _remote.login(
      LoginRequestDto(email: email, password: password),
    );

    final session = dto.toEntity();
    await _persistSession(session);
    return session;
  }

  // ============ REFRESH TOKEN ============
  @override
  Future<AuthSession> refreshToken() async {
    final refresh = await _getRefreshToken();
    if (refresh == null) {
      throw Exception('No hay refresh token guardado');
    }

    // Cuando tengas endpoint real:
    // final dto = await _remote.refresh(refresh);
    // final session = dto.toEntity();
    // await _persistSession(session);
    // return session;

    throw UnimplementedError('refreshToken aún no implementado en el backend');
  }

  // ============ LOGOUT ============
  @override
  Future<void> logout() async {
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kRefreshTokenKey);
  }

  // ============ GET CURRENT USER ============
  @override
  Future<Usuario> getCurrentUser() async {
    final access = await _getAccessToken();
    if (access == null) {
      throw Exception('No hay sesión activa');
    }

    final UsuarioDto dto = await _remote.getMe(access);
    return dto.toEntity();
  }

  // ============ REGISTRO ============
  @override
  Future<void> registerUser({
    required String nombre,
    required String apellido,
    required String email,
    required String celular,
    required String password,
    required bool aceptaTerminos,
  }) async {
    final dto = UsuarioRegisterDto(
      nombre: nombre,
      apellido: apellido,
      email: email,
      celular: celular,
      password: password,
      aceptaTerminos: aceptaTerminos, // 👈 se pasa al DTO
    );

    await _remote.register(dto);
  }

  // ============ OTP & PASSWORD FLOWS (placeholders) ============
  @override
  Future<void> requestOtp({
    required String email,
    required String purpose,
  }) async {
    throw UnimplementedError('requestOtp aún no implementado');
  }

  @override
  Future<void> verifyOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    throw UnimplementedError('verifyOtp aún no implementado');
  }

  @override
  Future<void> forgotPassword(String email) async {
    throw UnimplementedError('forgotPassword aún no implementado');
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    throw UnimplementedError('resetPassword aún no implementado');
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    throw UnimplementedError('changePassword aún no implementado');
  }
}
