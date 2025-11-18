// lib/features/auth/domain/usecases/refresh_token_usecase.dart
import 'package:ghost_kitchens_app/features/auth/domain/entities/auth_session.dart';
import 'package:ghost_kitchens_app/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  Future<AuthSession> call() => _repository.refreshToken();
}
