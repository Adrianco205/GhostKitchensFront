// lib/features/auth/domain/usecases/get_me_usecase.dart
import 'package:ghost_kitchens_app/features/auth/domain/entities/usuario.dart';
import 'package:ghost_kitchens_app/features/auth/domain/repositories/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository _repository;

  GetMeUseCase(this._repository);

  Future<Usuario> call() => _repository.getCurrentUser();
}
