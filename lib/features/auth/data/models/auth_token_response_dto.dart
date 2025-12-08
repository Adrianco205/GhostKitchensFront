// Si tu entidad AuthSession requiere usuario, tendrás que ajustarla
// o hacer una segunda llamada para traer el usuario.
// Por ahora, adaptamos este DTO a lo que REALMENTE devuelve el servidor.

import 'package:ghost_kitchens_app/features/auth/domain/entities/auth_session.dart';

// ... imports

class AuthTokenResponseDto {
  final String accessToken;
  final String tokenType;

  const AuthTokenResponseDto({
    required this.accessToken,
    required this.tokenType,
  });

  factory AuthTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponseDto(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: '', // Backend Python no usa refresh token aún
      usuario: null,    // <--- Ahora podemos enviar null y Flutter no se queja
    );
  }
}