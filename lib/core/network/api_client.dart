// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:ghost_kitchens_app/core/config/api_config.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl, // 👈 aquí se usa la variable global
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
        ),
      ) {
    // aquí puedes añadir tus interceptors si ya los tienes
  }

  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Options? options,
      }) {
    return _dio.post(
      path,
      data: data,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
      String path, {
        dynamic data,
        Options? options,
      }) {
    return _dio.patch(
      path,
      data: data,
      options: options,
    );
  }
}
