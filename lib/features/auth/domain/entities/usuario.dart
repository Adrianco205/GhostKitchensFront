// lib/features/auth/domain/entities/usuario.dart
class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String celular;
  final String numeroIdentificacion;
  final List<String> roles;
  final bool activo;
  final DateTime? fechaRegistro;

  const Usuario({
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
}
