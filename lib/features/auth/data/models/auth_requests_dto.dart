import 'package:equatable/equatable.dart';

/// ===== REGISTRO Y LOGIN =====

// lib/features/auth/data/models/auth_requests_dto.dart

// lib/features/auth/data/models/auth_requests_dto.dart

class UsuarioRegisterDto extends Equatable {
  final String nombre;
  final String apellido;
  final String email;
  final String celular;
  final String password;
  final bool aceptaTerminos;
  final List<String> rolesIniciales;

  const UsuarioRegisterDto({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.celular,
    required this.password,
    required this.aceptaTerminos,
    this.rolesIniciales = const ['CLIENTE'], // o 'cliente' según tu backend
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'celular': celular,
      'password': password,
      'acepta_terminos': aceptaTerminos,   // 👈 CLAVE QUE PIDE EL BACKEND
      'roles_iniciales': rolesIniciales,   // opcional, pero lo dejamos listo
    };
  }

  @override
  List<Object?> get props => [
        nombre,
        apellido,
        email,
        celular,
        password,
        aceptaTerminos,
        rolesIniciales,
      ];
}

class LoginRequestDto extends Equatable {
  final String email;
  final String password;

  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  @override
  List<Object?> get props => [email, password];
}

/// ===== DTOs PARA OTP / PASSWORD (aunque el backend nuevo no los use aún) =====

class OtpRequestDto extends Equatable {
  final String email;
  final String purpose;

  const OtpRequestDto({required this.email, required this.purpose});

  Map<String, dynamic> toJson() => {
        'email': email,
        'purpose': purpose,
      };

  @override
  List<Object?> get props => [email, purpose];
}

class OtpVerifyDto extends Equatable {
  final String email;
  final String otp;
  final String purpose;

  const OtpVerifyDto({
    required this.email,
    required this.otp,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
        'purpose': purpose,
      };

  @override
  List<Object?> get props => [email, otp, purpose];
}

class ForgotPasswordRequestDto extends Equatable {
  final String email;

  const ForgotPasswordRequestDto(this.email);

  Map<String, dynamic> toJson() => {'email': email};

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequestDto extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordRequestDto({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'new_password': newPassword,
      };

  @override
  List<Object?> get props => [token, newPassword];
}

class ChangePasswordRequestDto extends Equatable {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequestDto({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'current_password': currentPassword,
        'new_password': newPassword,
      };

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
