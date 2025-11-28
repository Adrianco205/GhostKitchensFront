// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:ghost_kitchens_app/core/storage/secure_storage.dart';
import 'package:ghost_kitchens_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/auth_requests_dto.dart';
import 'package:ghost_kitchens_app/features/auth/domain/entities/auth_session.dart';
import 'package:ghost_kitchens_app/features/auth/domain/entities/usuario.dart';
import 'package:ghost_kitchens_app/features/auth/domain/repositories/auth_repository.dart';
//Pa la prueba
import '../models/auth_token_response_dto.dart';
import '../models/usuario_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
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

  /*@override
  Future<AuthSession> login({
    required String email,
    required String password,
    String? otp,
  }) async {
    final dto = await _remote.login(
      email: email,
      password: password,
      otp: otp,
    );

    final session = dto.toEntity();
    await _persistSession(session);
    return session;
  }*/
//De aqui
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    String? otp,
  }) async {
    // Solo acepta este usuario demo
    if (email != 'demo@demo.demo' || password != 'Demo1234*') {
      throw Exception('Credenciales demo incorrectas');
    }

    final fakeDto = AuthTokenResponseDto(
      access: 'fake_access_token',
      refresh: 'fake_refresh_token',
      usuario: UsuarioDto(
        id: 1,
        nombre: 'Usuario',
        apellido: 'Demo',
        email: email,
        celular: '3000000000',
        numeroIdentificacion: '1234567890',
        roles: const ['cliente'],
        activo: true,
        fechaRegistro: DateTime.now(),
      ),
    );

    final session = fakeDto.toEntity();
    await _persistSession(session);
    return session;
  }
//hasta aqui
  @override
  Future<AuthSession> refreshToken() async {
    final currentRefresh = await _getRefreshToken();
    if (currentRefresh == null) {
      throw Exception('No hay refresh token guardado');
    }

    final dto = await _remote.refreshToken(currentRefresh);
    final session = dto.toEntity();
    await _persistSession(session);
    return session;
  }

  @override
  Future<void> logout() async {
    final currentRefresh = await _getRefreshToken();
    if (currentRefresh != null) {
      await _remote.logout(currentRefresh);
    }
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kRefreshTokenKey);
  }

  @override
  Future<Usuario> getCurrentUser() async {
    final access = await _getAccessToken();
    if (access == null) {
      throw Exception('No hay sesión activa');
    }

    final dto = await _remote.getMe(access);
    return dto.toEntity();
  }

  @override
  Future<void> registerUser({
    required String nombre,
    required String apellido,
    required String email,
    required String celular,
    required String password,
    required String numeroIdentificacion,
  }) {
    final dto = UsuarioRegisterDto(
      nombre: nombre,
      apellido: apellido,
      email: email,
      celular: celular,
      password: password,
      numeroIdentificacion: numeroIdentificacion,
    );

    return _remote.register(dto);
  }

  @override
  Future<void> requestOtp({
    required String email,
    required String purpose,
  }) {
    final dto = OtpRequestDto(email: email, purpose: purpose);
    return _remote.requestOtp(dto);
  }

  @override
  Future<void> verifyOtp({
    required String email,
    required String otp,
    required String purpose,
  }) {
    final dto = OtpVerifyDto(email: email, otp: otp, purpose: purpose);
    return _remote.verifyOtp(dto);
  }

  @override
  Future<void> forgotPassword(String email) {
    return _remote.forgotPassword(ForgotPasswordRequestDto(email));
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _remote.resetPassword(
      ResetPasswordRequestDto(token: token, newPassword: newPassword),
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _remote.changePassword(
      ChangePasswordRequestDto(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }
}
