import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
  final int id;
  final String nombre;
  final String? apellido;
  final String email;
  final String? celular;
  final String rol;        // "CLIENTE", "DUENO", etc.
  final bool activo;
  final DateTime fechaRegistro;

  const Usuario({
    required this.id,
    required this.nombre,
    this.apellido,
    required this.email,
    this.celular,
    required this.rol,
    required this.activo,
    required this.fechaRegistro,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        apellido,
        email,
        celular,
        rol,
        activo,
        fechaRegistro,
      ];
}
