// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:ghost_kitchens_app/features/auth/domain/entities/auth_session.dart';
import 'package:ghost_kitchens_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthSession> call({
    required String email,
    required String password,
    String? otp,
  }) {
    return _repository.login(email: email, password: password, otp: otp);
  }
}
