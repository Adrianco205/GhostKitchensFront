import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interfaz base que ya usaba tu proyecto
abstract class ISecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> clear();
}

class SecureStorage implements ISecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // ========== Implementaciones requeridas por ISecureStorage ==========

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  // ========== HELPERS ESPECÍFICOS PARA TOKENS ==========

  Future<void> saveTokens(String access, String refresh) async {
    await write(key: _accessTokenKey, value: access);
    await write(key: _refreshTokenKey, value: refresh);
  }

  /// Getter de instancia
  Future<String?> get accessToken async => read(key: _accessTokenKey);

  Future<String?> get refreshToken async => read(key: _refreshTokenKey);

  Future<void> clearTokens() async {
    await delete(key: _accessTokenKey);
    await delete(key: _refreshTokenKey);
  }
}
