import 'usuario.dart'; // Asegúrate de importar tu entidad Usuario

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final Usuario? usuario; // <--- Cambia a nullable (?)

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    this.usuario, // <--- Quita el 'required'
  });
}