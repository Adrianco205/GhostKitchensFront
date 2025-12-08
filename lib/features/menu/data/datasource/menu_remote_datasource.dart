import 'package:ghost_kitchens_app/core/network/api_client.dart';
import 'package:ghost_kitchens_app/features/kitchens/data/models/product_dto.dart';

class MenuRemoteDataSource {
  final ApiClient _apiClient;

  MenuRemoteDataSource(this._apiClient);

  Future<ProductDto> getProductDetail(int id) async {
    // Llamada al endpoint que definimos en Swagger
    final response = await _apiClient.get('/menu/productos/$id');
    return ProductDto.fromJson(response.data);
  }
}