import 'package:meta/meta.dart';

@immutable
class KitchenProductDto {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool available;

  const KitchenProductDto({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.available,
  });

  factory KitchenProductDto.fromJson(Map<String, dynamic> json) {
    return KitchenProductDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      available: json['available'] as bool? ?? true,
    );
  }
}

@immutable
class KitchenCategoryDto {
  final int id;
  final String name;
  final int order;
  final List<KitchenProductDto> products;

  const KitchenCategoryDto({
    required this.id,
    required this.name,
    required this.order,
    required this.products,
  });

  factory KitchenCategoryDto.fromJson(Map<String, dynamic> json) {
    return KitchenCategoryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      order: json['order'] as int? ?? 0,
      products: (json['products'] as List<dynamic>? ?? [])
          .map((p) => KitchenProductDto.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

@immutable
class KitchenDetailDto {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final double? rating;
  final int? deliveryTimeMin;
  final double? distanceKm;
  final List<String> tags;
  final List<KitchenCategoryDto> categories;

  const KitchenDetailDto({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.rating,
    this.deliveryTimeMin,
    this.distanceKm,
    required this.tags,
    required this.categories,
  });

  factory KitchenDetailDto.fromJson(Map<String, dynamic> json) {
    return KitchenDetailDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      deliveryTimeMin: json['delivery_time_min'] as int?,
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((c) => KitchenCategoryDto.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
