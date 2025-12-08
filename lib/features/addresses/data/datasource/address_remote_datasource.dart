import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/addresses/data/models/address_dto.dart';

class AddressRemoteDataSource {
  final ApiClient _apiClient;

  AddressRemoteDataSource(this._apiClient);

  // 1. Obtener Direcciones (GET)
  Future<List<AddressDto>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await _apiClient.get(
      '/auth/direcciones',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return (response.data as List).map((e) => AddressDto.fromJson(e)).toList();
  }

  // 2. Crear Dirección (POST)
  Future<void> createAddress(AddressDto address) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await _apiClient.post(
      '/auth/direcciones',
      data: address.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // 3. Actualizar Dirección (PUT)
  Future<void> updateAddress(int id, AddressDto address) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await _apiClient.put(
      '/auth/direcciones/$id',
      data: address.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // 4. Eliminar Dirección (DELETE)
  Future<void> deleteAddress(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await _apiClient.delete(
      '/auth/direcciones/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}