import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_freezed.freezed.dart';
part 'meal_freezed.g.dart';

/// Immutable data model for meal information using Freezed
/// 
/// Provides type safety, immutability, and code generation for equals,
/// hashCode, toString, copyWith, and JSON serialization.
@freezed
class MealFreezed with _$MealFreezed {
  /// Creates a new meal instance
  const factory MealFreezed({
    /// Unique identifier for the meal (from database)
    int? id,
    
    /// Name of the meal
    required String name,
    
    /// User ID who created this meal
    String? uid,
    
    /// Total calories in the meal
    required int calories,
    
    /// Protein content in grams
    required double proteins,
    
    /// Fat content in grams
    required double fats,
    
    /// Carbohydrate content in grams
    required double carbs,
    
    /// URL to the meal photo (if any)
    String? photoUrl,
    
    /// Date when the meal was consumed
    required DateTime date,
    
    /// Timestamp when the meal record was created
    DateTime? createdAt,
  }) = _MealFreezed;

  /// Creates a MealFreezed instance from JSON data
  factory MealFreezed.fromJson(Map<String, dynamic> json) =>
      _$MealFreezedFromJson(json);

  /// Creates a MealFreezed instance from Supabase response data
  factory MealFreezed.fromSupabase(Map<String, dynamic> data) {
    return MealFreezed(
      id: data['id'] as int?,
      name: data['name'] as String? ?? '',
      uid: data['uid'] as String?,
      calories: _safeParseInt(data['calories']),
      proteins: _safeParseDouble(data['proteins']),
      fats: _safeParseDouble(data['fats']),
      carbs: _safeParseDouble(data['carbs']),
      photoUrl: data['photo_url'] as String?,
      date: _parseDate(data['date']),
      createdAt: data['created_at'] != null ? _parseDate(data['created_at']) : null,
    );
  }
}

/// Extension methods for MealFreezed
extension MealFreezedExtension on MealFreezed {
  /// Converts to Supabase-compatible map for database operations
  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'uid': uid,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'photo_url': photoUrl,
      'date': date.toIso8601String(),
    };
  }

  /// Calculates total macronutrients in grams
  double get totalMacros => proteins + fats + carbs;

  /// Calculates calories per gram ratio
  double get caloriesDensity => totalMacros > 0 ? calories / totalMacros : 0;
  
  /// Checks if the meal has complete nutrition information
  bool get hasCompleteNutrition => 
      calories > 0 && proteins >= 0 && fats >= 0 && carbs >= 0;
}

// Helper functions for safe parsing
int _safeParseInt(dynamic value) {
  if (value == null) return 0;
  
  if (value is int) return value;
  
  if (value is double) {
    return value.isFinite ? value.round() : 0;
  }
  
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  
  if (value is num) {
    return value.round();
  }
  
  return 0;
}

double _safeParseDouble(dynamic value) {
  if (value == null) return 0.0;
  
  if (value is double) {
    return value.isFinite ? value : 0.0;
  }
  
  if (value is int) {
    return value.toDouble();
  }
  
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed?.isFinite == true ? parsed! : 0.0;
  }
  
  if (value is num) {
    final asDouble = value.toDouble();
    return asDouble.isFinite ? asDouble : 0.0;
  }
  
  return 0.0;
}

DateTime _parseDate(dynamic dateValue) {
  if (dateValue == null) return DateTime.now();
  
  if (dateValue is DateTime) return dateValue;
  
  if (dateValue is String) {
    try {
      return DateTime.parse(dateValue);
    } catch (e) {
      return DateTime.now();
    }
  }
  
  return DateTime.now();
}