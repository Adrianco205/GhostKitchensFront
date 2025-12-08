import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
// 👇 IMPORTANTE: Importamos el NUEVO archivo (user_dto.dart), no el viejo
import 'package:ghost_kitchens_app/features/auth/data/models/user_dto.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  // 1. LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data; // Devuelve el token
  }

  // 2. REGISTER (Actualizado a UserRegisterDto)
  Future<void> register(UserRegisterDto dto) async {
    await _apiClient.post(
      '/auth/registro',
      data: dto.toJson(),
    );
  }

  // 3. GET PROFILE (Para la pantalla de cuenta)
  Future<UserDto> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await _apiClient.get(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return UserDto.fromJson(response.data);
  }
}