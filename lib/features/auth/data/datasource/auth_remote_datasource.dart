// lib/features/auth/data/datasource/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_requests_dto.dart';
import '../models/auth_token_response_dto.dart';
import '../models/usuario_dto.dart';

abstract class IAuthRemoteDataSource {
  // 👇 ahora solo void
  Future<void> register(UsuarioRegisterDto dto);

  Future<AuthTokenResponseDto> login(LoginRequestDto dto);
  Future<UsuarioDto> getMe(String accessToken);

  // si todavía no tienes endpoint de refresh, lo quitamos:
  // Future<AuthTokenResponseDto> refresh(String refreshToken);
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSource(this._client);

  @override
  Future<void> register(UsuarioRegisterDto dto) async {
    await _client.post(
      ApiEndpoints.register,
      data: dto.toJson(),
      // aceptamos 200/201/204 como éxito
      options: Options(
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    // NO parseamos nada, solo consideramos que si no lanzó excepción, fue OK
  }

  @override
  Future<AuthTokenResponseDto> login(LoginRequestDto dto) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: dto.toJson(),
    );

    return AuthTokenResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<UsuarioDto> getMe(String accessToken) async {
    final response = await _client.get(
      ApiEndpoints.me,
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    return UsuarioDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
