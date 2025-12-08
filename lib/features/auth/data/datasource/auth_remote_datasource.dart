import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/auth_token_response_dto.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/usuario_dto.dart';

// --- BORRA O COMENTA ESTA LÍNEA QUE CAUSA EL CONFLICTO: ---
// import 'package:ghost_kitchens_app/features/auth/data/models/auth_requests_dto.dart';

import 'package:dio/dio.dart' show Options;

abstract class AuthRemoteDataSource {
  Future<AuthTokenResponseDto> login({
    required String email,
    required String password,
  });

  Future<void> register(UsuarioRegisterDto dto);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthTokenResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthTokenResponseDto.fromJson(response.data);
  }

  @override
  Future<void> register(UsuarioRegisterDto dto) async {
    await _apiClient.post(
      '/auth/registro',
      data: dto.toJson(),
    );
  }
}