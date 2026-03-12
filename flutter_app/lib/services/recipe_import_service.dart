import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_logger.dart';

class RecipeNutrition {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String sourceUrl;

  const RecipeNutrition({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sourceUrl,
  });
}

class RecipeImportService {
  static const _timeout = Duration(seconds: 12);

  Future<RecipeNutrition> importFromUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
      throw Exception('Invalid URL — must start with http:// or https://');
    }

    final response = await http.get(uri, headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; YapperApp/1.0; nutrition-import)',
      'Accept': 'text/html,application/xhtml+xml',
    }).timeout(_timeout, onTimeout: () {
      throw Exception('Request timed out — try again');
    });

    if (response.statusCode != 200) {
      throw Exception('Could not fetch page (HTTP ${response.statusCode})');
    }

    final result = _parseJsonLd(response.body, url);
    if (result == null) {
      throw Exception(
          'No recipe nutrition data found.\n'
          'This page may not use structured recipe markup.');
    }
    return result;
  }

  RecipeNutrition? _parseJsonLd(String html, String url) {
    // Match any <script> tag referencing application/ld+json
    final scriptRe = RegExp(
      r'<script[^>]+application/ld\+json[^>]*>([\s\S]*?)</script>',
      caseSensitive: false,
    );

    for (final m in scriptRe.allMatches(html)) {
      try {
        final data = json.decode(m.group(1)!.trim());
        final recipe = _findRecipe(data);
        if (recipe != null) {
          final result = _extract(recipe, url);
          if (result != null) return result;
        }
      } catch (e) {
        AppLogger.debug('JSON-LD parse skip: $e');
      }
    }
    return null;
  }

  Map<String, dynamic>? _findRecipe(dynamic node) {
    if (node is Map<String, dynamic>) {
      final type = node['@type'];
      final isRecipe = type == 'Recipe' ||
          (type is List && type.any((t) => t.toString() == 'Recipe'));
      if (isRecipe) return node;
      // Check @graph array (common on WordPress/Yoast sites)
      final graph = node['@graph'];
      if (graph is List) {
        for (final item in graph) {
          final found = _findRecipe(item);
          if (found != null) return found;
        }
      }
    } else if (node is List) {
      for (final item in node) {
        final found = _findRecipe(item);
        if (found != null) return found;
      }
    }
    return null;
  }

  RecipeNutrition? _extract(Map<String, dynamic> recipe, String url) {
    final nutrition = recipe['nutrition'];
    if (nutrition is! Map<String, dynamic>) return null;

    final calories = _parseNumber(nutrition['calories']);
    if (calories == null) return null;

    final name = (recipe['name'] as String?)?.trim() ?? 'Imported Recipe';

    return RecipeNutrition(
      name: name,
      calories: calories.round(),
      protein: _parseNumber(nutrition['proteinContent']) ?? 0.0,
      carbs: _parseNumber(nutrition['carbohydrateContent']) ?? 0.0,
      fat: _parseNumber(nutrition['fatContent']) ?? 0.0,
      sourceUrl: url,
    );
  }

  double? _parseNumber(dynamic value) {
    if (value == null) return null;
    final match = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(value.toString());
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }
}
