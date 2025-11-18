// lib/features/auth/data/models/auth_requests_dto.dart

class UsuarioRegisterDto {
  final String nombre;
  final String apellido;
  final String email;
  final String celular;
  final String password;
  final String numeroIdentificacion;
  final bool aceptaTerminos;
  final List<String> rolesIniciales;

  UsuarioRegisterDto({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.celular,
    required this.password,
    required this.numeroIdentificacion,
    this.aceptaTerminos = true,
    this.rolesIniciales = const ['cliente'],
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    'celular': celular,
    'password': password,
    'numero_identificacion': numeroIdentificacion,
    'acepta_terminos': aceptaTerminos,
    'roles_iniciales': rolesIniciales,
  };
}

class OtpRequestDto {
  final String email;
  final String purpose; // registro | login | reset_password

  OtpRequestDto({
    required this.email,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'purpose': purpose,
  };
}

class OtpVerifyDto {
  final String email;
  final String otp;
  final String purpose;

  OtpVerifyDto({
    required this.email,
    required this.otp,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'purpose': purpose,
  };
}

class ForgotPasswordRequestDto {
  final String email;

  ForgotPasswordRequestDto(this.email);

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class ResetPasswordRequestDto {
  final String token;
  final String newPassword;

  ResetPasswordRequestDto({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'new_password': newPassword,
  };
}

class ChangePasswordRequestDto {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequestDto({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'current_password': currentPassword,
    'new_password': newPassword,
  };
}
