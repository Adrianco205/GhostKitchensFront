 import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// 👉 PRODUCCIÓN (cuando tengas tu servidor real)
  static const String _prodBaseUrl = 'https://api.ghostkitchen.com/v1';

  /// 👉 DESARROLLO LOCAL EN PC (FastAPI)
  static const String _localBaseUrl = 'http://127.0.0.1:8000';

  /// 👉 DESARROLLO EN EMULADOR ANDROID
  static const String _androidBaseUrl = 'http://10.0.2.2:8000';

  static String get baseUrl {
    // Web (Chrome, Edge, Safari)
    if (kIsWeb) return _localBaseUrl;

    // Android (Emulador o dispositivo)
    if (Platform.isAndroid) return _androidBaseUrl;

    // iOS simulador / Windows / Mac / Linux
    return _localBaseUrl;
  }
}