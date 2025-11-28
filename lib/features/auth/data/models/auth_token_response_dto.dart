import 'package:equatable/equatable.dart';
import 'package:ghost_kitchens_app/features/auth/domain/entities/auth_session.dart';
import 'usuario_dto.dart';

class AuthTokenResponseDto extends Equatable {
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

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
      'usuario': usuario.toJson(),
    };
  }

  /// Mapper a sesión de dominio
  AuthSession toEntity() {
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      usuario: usuario.toEntity(),
    );
  }

  @override
  List<Object?> get props => [access, refresh, usuario];
}
