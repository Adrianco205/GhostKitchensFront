import 'package:dio/dio.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/support/data/models/pqr_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportRemoteDataSource {
  final ApiClient _apiClient;
  SupportRemoteDataSource(this._apiClient);

  Future<void> createPqr(PqrCreateDto pqr) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await _apiClient.post('/pqr/', data: pqr.toJson(), options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<List<PqrDto>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _apiClient.get('/pqr/historial', options: Options(headers: {'Authorization': 'Bearer $token'}));
    return (response.data as List).map((e) => PqrDto.fromJson(e)).toList();
  }

  Future<PqrDto> getDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _apiClient.get('/pqr/$id', options: Options(headers: {'Authorization': 'Bearer $token'}));
    return PqrDto.fromJson(response.data);
  }
}