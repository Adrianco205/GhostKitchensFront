// lib/features/auth/data/models/auth_token_response_dto.dart
import 'package:ghost_kitchens_app/features/auth/domain/entities/auth_session.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/usuario_dto.dart';

class AuthTokenResponseDto {
  final String access;
  final String refresh;
  final UsuarioDto usuario;

  const AuthTokenResponseDto({
    required this.access,
    required this.refresh,
    required this.usuario,
  });

  factory AuthTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponseDto(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      usuario: UsuarioDto.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      usuario: usuario.toEntity(),
    );
  }
}
