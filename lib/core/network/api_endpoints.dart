// lib/core/network/api_endpoints.dart

class ApiEndpoints {
  // AUTH
  static const String login    = '/auth/login/';     // 👈 igual que en FastAPI
  static const String register = '/auth/register/';
  static const String me       = '/auth/me/';

  // USUARIOS
  static const String direcciones = '/usuarios/direcciones/';
}
