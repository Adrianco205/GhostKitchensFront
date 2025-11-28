import 'package:meta/meta.dart';

/// ======================
/// SUGERENCIAS ( /search/suggestions )
/// ======================

@immutable
class KitchenLogoDto {
  final int id;
  final String name;
  /// Siempre un String (puede venir vacío) para no romper NetworkImage.
  final String logoUrl;

  const KitchenLogoDto({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  factory KitchenLogoDto.fromJson(Map<String, dynamic> json) {
    return KitchenLogoDto(
      id: json['id'] as int,
      name: json['name'] as String,
      logoUrl: (json['logo_url'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo_url': logoUrl,
      };
}

@immutable
class SearchSuggestionsDto {
  final List<KitchenLogoDto> kitchenLogos;
  final List<String> recentTags;
  final List<String> topTags;

  const SearchSuggestionsDto({
    required this.kitchenLogos,
    required this.recentTags,
    required this.topTags,
  });

  factory SearchSuggestionsDto.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionsDto(
      kitchenLogos: (json['kitchen_logos'] as List<dynamic>? ?? [])
          .map((e) => KitchenLogoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentTags: (json['recent_tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      topTags: (json['top_tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'kitchen_logos': kitchenLogos.map((e) => e.toJson()).toList(),
        'recent_tags': recentTags,
        'top_tags': topTags,
      };
}

/// ======================
/// RESULTADOS ( /search )
/// ======================

class DishPreviewDto {
  final String name;
  final int price;
  final String? imageUrl;

  DishPreviewDto({
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory DishPreviewDto.fromJson(Map<String, dynamic> json) {
    return DishPreviewDto(
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'image_url': imageUrl,
      };
}

class SearchResultItemDto {
  final int id;
  final String name;
  final double? distanceKm;
  final int? deliveryTimeMin;
  final int? minPrice;
  final double? rating;
  final String? discount;
  final String? imageUrl;
  final List<DishPreviewDto> dishes;

  SearchResultItemDto({
    required this.id,
    required this.name,
    this.distanceKm,
    this.deliveryTimeMin,
    this.minPrice,
    this.rating,
    this.discount,
    this.imageUrl,
    required this.dishes,
  });

  factory SearchResultItemDto.fromJson(Map<String, dynamic> json) {
    final dishesJson = (json['dishes'] as List<dynamic>? ?? []);
    return SearchResultItemDto(
      id: json['id'] as int,
      name: json['name'] as String,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      deliveryTimeMin: (json['delivery_time_min'] as num?)?.toInt(),
      minPrice: (json['min_price'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      discount: json['discount'] as String?,
      imageUrl: json['image_url'] as String?,
      dishes: dishesJson
          .map((e) => DishPreviewDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'distance_km': distanceKm,
        'delivery_time_min': deliveryTimeMin,
        'min_price': minPrice,
        'rating': rating,
        'discount': discount,
        'image_url': imageUrl,
        'dishes': dishes.map((e) => e.toJson()).toList(),
      };
}

class SearchResponseDto {
  final String query;
  final List<SearchResultItemDto> results;

  SearchResponseDto({
    required this.query,
    required this.results,
  });

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) {
    final resultsJson = (json['results'] as List<dynamic>? ?? []);
    return SearchResponseDto(
      query: json['query'] as String? ?? '',
      results: resultsJson
          .map((e) => SearchResultItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        'results': results.map((e) => e.toJson()).toList(),
      };
}
