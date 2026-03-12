import 'dart:convert';

import 'package:food_scanner/core/app_logger.dart';
import 'package:food_scanner/services/openfoodfacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local device cache for recently scanned barcodes.
/// Works offline — data is stored in shared_preferences as JSON.
/// TTL: 30 days. Max entries: 50 (oldest evicted first).
class BarcodeCacheService {
  factory BarcodeCacheService() => _instance;
  BarcodeCacheService._internal();

  static final BarcodeCacheService _instance = BarcodeCacheService._internal();
  static const String _prefKey = 'barcode_offline_cache';
  static const int _maxEntries = 50;
  static const Duration _ttl = Duration(days: 30);

  /// Returns cached product for [barcode], or null if not found / expired.
  Future<ProductNutrition?> get(String barcode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return null;

      final map = jsonDecode(raw) as Map<String, dynamic>;
      final entry = map[barcode] as Map<String, dynamic>?;
      if (entry == null) return null;

      final cachedAt = DateTime.parse(entry['cached_at'] as String);
      if (DateTime.now().difference(cachedAt) > _ttl) {
        map.remove(barcode);
        await prefs.setString(_prefKey, jsonEncode(map));
        return null;
      }

      return ProductNutrition.fromSupabase(
        entry['product'] as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('BarcodeCacheService.get', e);
      return null;
    }
  }

  /// Stores [product] in local cache. Evicts oldest entries when over [_maxEntries].
  Future<void> put(ProductNutrition product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      final map = raw != null
          ? (jsonDecode(raw) as Map<String, dynamic>)
          : <String, dynamic>{};

      map[product.barcode] = {
        'product': product.toSupabase(),
        'cached_at': DateTime.now().toIso8601String(),
      };

      if (map.length > _maxEntries) {
        final entries = map.entries.toList()
          ..sort((a, b) {
            final aTime = DateTime.parse(
              (a.value as Map<String, dynamic>)['cached_at'] as String,
            );
            final bTime = DateTime.parse(
              (b.value as Map<String, dynamic>)['cached_at'] as String,
            );
            return aTime.compareTo(bTime); // oldest first
          });
        for (var i = 0; i < map.length - _maxEntries; i++) {
          map.remove(entries[i].key);
        }
      }

      await prefs.setString(_prefKey, jsonEncode(map));
    } catch (e) {
      AppLogger.error('BarcodeCacheService.put', e);
    }
  }

  /// Removes all locally cached barcodes.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// Returns the number of entries currently in the local cache.
  Future<int> count() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return 0;
      return (jsonDecode(raw) as Map<String, dynamic>).length;
    } catch (e) {
      return 0;
    }
  }
}
