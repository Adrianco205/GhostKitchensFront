// --- DTO PARA LEER EL USUARIO (PERFIL) ---
class UserDto {
  final int id;
  final String nombre;
  final String email;
  final String rol;

  UserDto({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? 0,
      // Si el backend manda nombre y apellido separados, puedes unirlos aquí si quieres
      nombre: json['nombre'] ?? 'Usuario',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'CLIENTE',
    );
  }
}

// --- DTO PARA EL REGISTRO (ENVIAR) ---
class UserRegisterDto {
  final String nombre;
  final String apellido;
  final String email;
  final String celular;
  final String password;

  UserRegisterDto({
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