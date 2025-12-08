import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/kitchens/data/models/kitchen_dto.dart';

class KitchenRemoteDataSource {
  final ApiClient _apiClient;

  KitchenRemoteDataSource(this._apiClient);

  // 1. Obtener todas las cocinas para el Home
  Future<List<KitchenDto>> getCocinas() async {
    final response = await _apiClient.get('/cocinas/');

    // Convertimos la lista JSON en lista de objetos
    final List<dynamic> data = response.data;
    return data.map((json) => KitchenDto.fromJson(json)).toList();
  }

  // 2. Obtener detalle de UNA cocina (Menú)
  Future<KitchenDto> getKitchenDetail(int id) async {
    final response = await _apiClient.get('/cocinas/$id');
    return KitchenDto.fromJson(response.data);
  }
}