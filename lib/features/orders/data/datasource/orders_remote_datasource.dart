import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghost_kitchens_app/core/network/api_client.dart';
// Asegúrate de que este archivo existe y tiene los 3 DTOs (History, Create, FullDetail)
import 'package:ghost_kitchens_app/features/orders/data/models/order_dto.dart';

class OrdersRemoteDataSource {
  final ApiClient _apiClient;

  OrdersRemoteDataSource(this._apiClient);

  // 1. Crear Pedido (POST)
  Future<void> createOrder(OrderCreateDto order) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await _apiClient.post(
      '/pedidos/',
      data: order.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // 2. Obtener Historial (GET)
  Future<List<OrderHistoryDto>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await _apiClient.get(
      '/pedidos/historial',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    // Mapeo seguro de la lista JSON a objetos Dart
    final List<dynamic> data = response.data;
    return data.map((json) => OrderHistoryDto.fromJson(json)).toList();
  }

  // 3. Obtener Detalle de un Pedido (GET ID)
  Future<OrderFullDetailDto> getOrderDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await _apiClient.get(
      '/pedidos/$id',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return OrderFullDetailDto.fromJson(response.data);
  }
}