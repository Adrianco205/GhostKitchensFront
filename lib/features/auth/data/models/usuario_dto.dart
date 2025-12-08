class UsuarioDto {
  final int id;
  final String email;
  final String nombre;
  final String apellido;

  UsuarioDto({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) {
    return UsuarioDto(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
    );
  }

  // Si necesitas convertir a entidad de dominio
  // Usuario toEntity() => Usuario(...);
}

// --- DTO PARA EL REGISTRO ---
class UsuarioRegisterDto {
  final String nombre;
  final String apellido;
  final String email;
  final String celular;
  final String password;

  UsuarioRegisterDto({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.celular,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'celular': celular,
      'password': password,
    };
  }
}