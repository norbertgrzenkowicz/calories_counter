import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_logger.dart';

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const Map<String, String> _headers = {
    'User-Agent': 'JaperApp/1.0.0 (contact@japer.app)',
    'Accept': 'application/json',
  };

  /// Looks up a product by its barcode from OpenFoodFacts API
  /// Returns nutrition data or null if product not found
  static Future<ProductNutrition?> getProductByBarcode(String barcode) async {
    try {
      final uri = Uri.parse('$_baseUrl/product/$barcode');

      final response = await http
          .get(
            uri.replace(queryParameters: {
              'fields':
                  'product_name,brands,nutriments,serving_size,serving_quantity',
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if product was found
        if (data['status'] == 1 && data['product'] != null) {
          return ProductNutrition.fromOpenFoodFacts(data['product'], barcode);
        } else {
          // Product not found in database
          return null;
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      AppLogger.error('OpenFoodFacts API error for barcode', e);
      return null;
    }
  }

  /// Searches for products by name (for future use)
  static Future<List<ProductNutrition>> searchProducts(String query,
      {int limit = 10}) async {
    try {
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'search_terms': query,
        'search_simple': '1',
        'action': 'process',
        'page_size': limit.toString(),
        'fields':
            'code,product_name,brands,nutriments,serving_size,serving_quantity',
      });

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = <ProductNutrition>[];

        if (data['products'] != null && data['products'] is List) {
          for (final product in data['products']) {
            if (product['code'] != null) {
              final nutrition = ProductNutrition.fromOpenFoodFacts(
                  product, product['code'].toString());
              products.add(nutrition);
            }
          }
        }

        return products;
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      AppLogger.error('OpenFoodFacts search error', e);
      return [];
    }
  }

  /// Helper method to validate barcode format
  static bool isValidBarcode(String barcode) {
    // Check if barcode is numeric and has valid length
    if (!RegExp(r'^\d+$').hasMatch(barcode)) return false;

    // Common food barcode lengths: EAN-13 (13), EAN-8 (8), UPC-A (12), UPC-E (6-8)
    final length = barcode.length;
    return length == 6 ||
        length == 7 ||
        length == 8 ||
        length == 12 ||
        length == 13 ||
        length == 14;
  }
}

/// Represents nutrition data from OpenFoodFacts
class ProductNutrition {
  final String barcode;
  final String name;
  final String? brand;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final double? fiberPer100g;
  final double? sugarPer100g;
  final double? sodiumPer100g;
  final String? servingSize;
  final double? servingQuantity;
  final DateTime fetchedAt;

  ProductNutrition({
    required this.barcode,
    required this.name,
    this.brand,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    this.sodiumPer100g,
    this.servingSize,
    this.servingQuantity,
    required this.fetchedAt,
  });

  /// Creates ProductNutrition from OpenFoodFacts API response
  factory ProductNutrition.fromOpenFoodFacts(
      Map<String, dynamic> product, String barcode) {
    final nutriments = product['nutriments'] ?? <String, dynamic>{};

    // Helper function to safely parse numeric values
    double? parseNutrient(String key) {
      final value = nutriments[key];
      if (value == null) return null;

      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    return ProductNutrition(
      barcode: barcode,
      name: product['product_name']?.toString() ?? 'Unknown Product',
      brand: product['brands']?.toString(),
      caloriesPer100g: parseNutrient('energy-kcal_100g'),
      proteinPer100g: parseNutrient('proteins_100g'),
      carbsPer100g: parseNutrient('carbohydrates_100g'),
      fatPer100g: parseNutrient('fat_100g'),
      fiberPer100g: parseNutrient('fiber_100g'),
      sugarPer100g: parseNutrient('sugars_100g'),
      sodiumPer100g: parseNutrient('sodium_100g'),
      servingSize: product['serving_size']?.toString(),
      servingQuantity: parseNutrient('serving_quantity'),
      fetchedAt: DateTime.now(),
    );
  }

  /// Converts to Map for Supabase storage
  Map<String, dynamic> toSupabase() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'calories_per_100g': caloriesPer100g?.round(),
      'protein_per_100g': proteinPer100g,
      'carbs_per_100g': carbsPer100g,
      'fat_per_100g': fatPer100g,
      'fiber_per_100g': fiberPer100g,
      'sugar_per_100g': sugarPer100g,
      'sodium_per_100g': sodiumPer100g,
      'serving_size': servingSize,
      'serving_quantity': servingQuantity,
      'cached_at': fetchedAt.toIso8601String(),
    };
  }

  /// Creates ProductNutrition from Supabase data
  factory ProductNutrition.fromSupabase(Map<String, dynamic> data) {
    return ProductNutrition(
      barcode: data['barcode'],
      name: data['name'],
      brand: data['brand'],
      caloriesPer100g: data['calories_per_100g']?.toDouble(),
      proteinPer100g: data['protein_per_100g']?.toDouble(),
      carbsPer100g: data['carbs_per_100g']?.toDouble(),
      fatPer100g: data['fat_per_100g']?.toDouble(),
      fiberPer100g: data['fiber_per_100g']?.toDouble(),
      sugarPer100g: data['sugar_per_100g']?.toDouble(),
      sodiumPer100g: data['sodium_per_100g']?.toDouble(),
      servingSize: data['serving_size'],
      servingQuantity: data['serving_quantity']?.toDouble(),
      fetchedAt: DateTime.parse(data['cached_at']),
    );
  }

  /// Calculates nutrition for a specific portion size (in grams)
  Map<String, int> calculateNutritionForPortion(double portionGrams) {
    final factor = portionGrams / 100.0;

    return {
      'calories': ((caloriesPer100g ?? 0) * factor).round(),
      'protein': ((proteinPer100g ?? 0) * factor).round(),
      'carbs': ((carbsPer100g ?? 0) * factor).round(),
      'fats': ((fatPer100g ?? 0) * factor).round(),
    };
  }

  /// Gets a display name combining product name and brand
  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$brand - $name';
    }
    return name;
  }

  /// Checks if this product has sufficient nutrition data
  bool get hasBasicNutrition {
    return caloriesPer100g != null &&
        (proteinPer100g != null || carbsPer100g != null || fatPer100g != null);
  }

  /// Gets data quality score (0-1, higher is better)
  double get dataQuality {
    double score = 0.0;

    // Core nutrition data
    if (caloriesPer100g != null) score += 0.4;
    if (proteinPer100g != null) score += 0.2;
    if (carbsPer100g != null) score += 0.2;
    if (fatPer100g != null) score += 0.2;

    // Bonus for additional data
    if (brand != null && brand!.isNotEmpty) score += 0.05;
    if (servingSize != null) score += 0.05;
    if (fiberPer100g != null) score += 0.05;
    if (sugarPer100g != null) score += 0.05;

    return score.clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'ProductNutrition(barcode: $barcode, name: $name, calories: ${caloriesPer100g}kcal/100g)';
  }
}
