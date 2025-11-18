// lib/features/auth/data/models/usuario_dto.dart
import 'package:ghost_kitchens_app/features/auth/domain/entities/usuario.dart';

class UsuarioDto {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String celular;
  final String numeroIdentificacion;
  final List<String> roles;
  final bool activo;
  final DateTime? fechaRegistro;

  const UsuarioDto({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.celular,
    required this.numeroIdentificacion,
    required this.roles,
    required this.activo,
    this.fechaRegistro,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) {
    return UsuarioDto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      celular: json['celular'] as String,
      numeroIdentificacion: json['numero_identificacion'] as String,
      roles: (json['roles'] as List<dynamic>).cast<String>(),
      activo: json['activo'] as bool,
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'] as String)
          : null,
    );
  }

  Usuario toEntity() {
    return Usuario(
      id: id,
      nombre: nombre,
      apellido: apellido,
      email: email,
      celular: celular,
      numeroIdentificacion: numeroIdentificacion,
      roles: roles,
      activo: activo,
      fechaRegistro: fechaRegistro,
    );
  }
}
