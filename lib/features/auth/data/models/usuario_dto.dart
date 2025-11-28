// lib/features/auth/data/models/usuario_dto.dart
import 'package:equatable/equatable.dart';
import 'package:ghost_kitchens_app/features/auth/domain/entities/usuario.dart';

/// DTO que representa al usuario según lo que devuelve el backend
class UsuarioDto extends Equatable {
  final int id;
  final String nombre;
  final String? apellido;
  final String email;
  final String? celular;
  final List<String> roles; // lista de roles del backend
  final bool activo;
  final DateTime fechaRegistro;

  const UsuarioDto({
    required this.id,
    required this.nombre,
    this.apellido,
    required this.email,
    this.celular,
    required this.roles,
    required this.activo,
    required this.fechaRegistro,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) {
    return UsuarioDto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String?,
      email: json['email'] as String,
      celular: json['celular'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      activo: json['activo'] as bool? ?? true,
      fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'celular': celular,
      'roles': roles,
      'activo': activo,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        apellido,
        email,
        celular,
        roles,
        activo,
        fechaRegistro,
      ];
}

/// Mapper de DTO → Entidad de dominio
extension UsuarioDtoMapper on UsuarioDto {
  Usuario toEntity() {
    return Usuario(
      id: id,
      nombre: nombre,
      apellido: apellido ?? '',
      email: email,
      celular: celular ?? '',
      // la entidad tiene un solo rol (String)
      rol: roles.isNotEmpty ? roles.first : 'cliente',
      activo: activo,
      fechaRegistro: fechaRegistro,
    );
  }
}
