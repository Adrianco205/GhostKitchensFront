// lib/core/network/api_endpoints.dart

// lib/core/network/api_endpoints.dart

class ApiEndpoints {
  // AUTH
  static const String login    = '/auth/login/';
  static const String register = '/auth/register/';
  static const String me       = '/auth/me/';

  // USUARIOS (puedes borrar esta si ya no se usa)
  // static const String direcciones = '/usuarios/direcciones/';

  static const String home = '/home';
  static const String searchSuggestions = '/search/suggestions';
  static const String search = '/search';

  // ADDRESSES
  static const String userAddresses = '/direcciones';
  static String userAddressDetail(int id) => '/direcciones/$id';
}

