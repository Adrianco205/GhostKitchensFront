import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/auth_token_response_dto.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/usuario_dto.dart';
import 'package:ghost_kitchens_app/features/auth/data/models/auth_requests_dto.dart';
import 'package:dio/dio.dart' show Options;

abstract class AuthRemoteDataSource {
  Future<AuthTokenResponseDto> login({
    required String email,
    required String password,
    String? otp,
  });

  Future<AuthTokenResponseDto> refreshToken(String refreshToken);

  Future<void> logout(String refreshToken);

  Future<UsuarioDto> getMe(String accessToken);

  Future<void> register(UsuarioRegisterDto dto);

  Future<void> requestOtp(OtpRequestDto dto);

  Future<void> verifyOtp(OtpVerifyDto dto);

  Future<void> forgotPassword(ForgotPasswordRequestDto dto);

  Future<void> resetPassword(ResetPasswordRequestDto dto);

  Future<void> changePassword(ChangePasswordRequestDto dto);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthTokenResponseDto> login({
    required String email,
    required String password,
    String? otp,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login/',
      data: {
        'email': email,
        'password': password,
        if (otp != null) 'otp': otp,
      },
    );

    return AuthTokenResponseDto.fromJson(response.data!);
  }

  @override
  Future<AuthTokenResponseDto> refreshToken(String refreshToken) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/refresh/',
      data: {'refresh': refreshToken},
    );

    return AuthTokenResponseDto.fromJson(response.data!);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _apiClient.post<void>(
      '/auth/logout/',
      data: {'refresh': refreshToken},
    );
  }

  @override
  Future<UsuarioDto> getMe(String accessToken) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/auth/me/',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    return UsuarioDto.fromJson(response.data!);
  }

  @override
  Future<void> register(UsuarioRegisterDto dto) async {
    await _apiClient.post(
      '/auth/register/',
      data: dto.toJson(),
    );
  }

  @override
  Future<void> requestOtp(OtpRequestDto dto) async {
    await _apiClient.post(
      '/auth/request-otp/',
      data: dto.toJson(),
    );
  }

  @override
  Future<void> verifyOtp(OtpVerifyDto dto) async {
    await _apiClient.post(
      '/auth/verify-otp/',
      data: dto.toJson(),
    );
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequestDto dto) async {
    await _apiClient.post(
      '/auth/password/forgot/',
      data: dto.toJson(),
    );
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestDto dto) async {
    await _apiClient.post(
      '/auth/password/reset/',
      data: dto.toJson(),
    );
  }

  @override
  Future<void> changePassword(ChangePasswordRequestDto dto) async {
    await _apiClient.post(
      '/auth/password/change/',
      data: dto.toJson(),
    );
  }
}
