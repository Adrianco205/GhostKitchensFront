import 'package:meta/meta.dart';

@immutable
class DireccionDto {
  final int id;
  final String? alias;
  final String direccionTexto;
  final String? ciudad;
  final double? lat;
  final double? lon;

  const DireccionDto({
    required this.id,
    this.alias,
    required this.direccionTexto,
    this.ciudad,
    this.lat,
    this.lon,
  });

  factory DireccionDto.fromJson(Map<String, dynamic> json) {
    return DireccionDto(
      id: json['id'] as int,
      alias: json['alias'] as String?,
      direccionTexto: json['direccion_texto'] as String,
      ciudad: json['ciudad'] as String?,
      lat: json['coordenadas_lat'] != null
          ? (json['coordenadas_lat'] as num).toDouble()
          : null,
      lon: json['coordenadas_lon'] != null
          ? (json['coordenadas_lon'] as num).toDouble()
          : null,
    );
  }
}

@immutable
class CocinaHomeDto {
  final int id;
  final String name;
  final String? description;
  final List<String> tags;
  final double? distanceKm;
  final int? deliveryTimeMin;
  final double? minPrice;
  final double? rating;
  final String? discount;
  final String? imageUrl;

  const CocinaHomeDto({
    required this.id,
    required this.name,
    this.description,
    required this.tags,
    this.distanceKm,
    this.deliveryTimeMin,
    this.minPrice,
    this.rating,
    this.discount,
    this.imageUrl,
  });

  factory CocinaHomeDto.fromJson(Map<String, dynamic> json) {
    return CocinaHomeDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
      deliveryTimeMin: json['delivery_time_min'] as int?,
      minPrice: json['min_price'] != null
          ? (json['min_price'] as num).toDouble()
          : null,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      discount: json['discount'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

@immutable
class HomeResponseDto {
  final DireccionDto? address;
  final List<ProductHomeDto> featuredProducts;
  final List<ProductHomeDto> recommendedProducts;
  final List<CocinaHomeDto> allKitchens;

  HomeResponseDto({
    this.address,
    required this.featuredProducts,
    required this.recommendedProducts,
    required this.allKitchens,
  });

  factory HomeResponseDto.fromJson(Map<String, dynamic> json) {
    return HomeResponseDto(
      address: json['address'] != null
          ? DireccionDto.fromJson(json['address'])
          : null,
      featuredProducts: (json['featured_products'] as List<dynamic>? ?? [])
          .map((e) => ProductHomeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedProducts: (json['recommended_products'] as List<dynamic>? ?? [])
          .map((e) => ProductHomeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      allKitchens: (json['all_kitchens'] as List<dynamic>? ?? [])
          .map((e) => CocinaHomeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}


class ProductHomeDto {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final int kitchenId;
  final String kitchenName;
  final String? kitchenImageUrl;
  final List<String> tags;
  final double? distanceKm;
  final int? deliveryTimeMin;
  final String? discount;

  ProductHomeDto({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.kitchenId,
    required this.kitchenName,
    this.kitchenImageUrl,
    this.tags = const [],
    this.distanceKm,
    this.deliveryTimeMin,
    this.discount,
  });

  factory ProductHomeDto.fromJson(Map<String, dynamic> json) {
    return ProductHomeDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      kitchenId: json['kitchen_id'] as int,
      kitchenName: json['kitchen_name'] as String,
      kitchenImageUrl: json['kitchen_image_url'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      distanceKm:
          json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
      deliveryTimeMin: json['delivery_time_min'] as int?,
      discount: json['discount'] as String?,
    );
  }
}
