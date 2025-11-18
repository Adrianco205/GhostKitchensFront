// lib/core/config/api_config.dart
class ApiConfig {
  // Prod y dev de tu Swagger
  static const String _prodBaseUrl = 'https://api.ghostkitchen.com/v1';
  static const String _devBaseUrl = 'http://localhost:8000/api';

  /// Si corres en modo release usa prod, si no, dev.
  static const String baseUrl =
  bool.fromEnvironment('dart.vm.product') ? _prodBaseUrl : _devBaseUrl;
}
