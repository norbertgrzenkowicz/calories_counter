import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_freezed.freezed.dart';
part 'user_profile_freezed.g.dart';

/// Immutable data model for user profile information using Freezed
/// 
/// Provides type safety, immutability, and comprehensive nutrition calculations
/// for personalized calorie and macronutrient targeting.
@freezed
class UserProfileFreezed with _$UserProfileFreezed {
  /// Creates a new user profile instance
  const factory UserProfileFreezed({
    /// Database ID for the profile
    int? id,
    
    /// User authentication ID
    String? uid,
    
    // Basic Profile Information
    /// User's full name
    String? fullName,
    
    /// User's email address
    String? email,
    
    /// User's date of birth
    DateTime? dateOfBirth,
    
    // Physical Characteristics (required for BMR calculations)
    /// Biological sex ('male' or 'female')
    @Default('male') String gender,
    
    /// Height in centimeters
    required double heightCm,
    
    /// Current weight in kilograms
    required double currentWeightKg,
    
    /// Target weight in kilograms (optional)
    double? targetWeightKg,
    
    // Goals and Activity
    /// Primary fitness goal
    @Default('maintaining') String goal, // 'weight_loss', 'weight_gain', 'maintaining', 'hypertrophy'
    
    /// Physical Activity Level (PAL) value
    @Default(1.2) double activityLevel, // PAL value (1.2-2.4)
    
    // Calculated Values
    /// Basal Metabolic Rate in calories
    int? bmrCalories,
    
    /// Total Daily Energy Expenditure in calories
    int? tdeeCalories,
    
    /// Target daily calories for goal achievement
    int? targetCalories,
    
    /// Target protein intake in grams
    double? targetProteinG,
    
    /// Target carbohydrate intake in grams
    double? targetCarbsG,
    
    /// Target fat intake in grams
    double? targetFatsG,
    
    // Weight Loss Tracking
    /// Date when weight loss journey started
    DateTime? weightLossStartDate,
    
    /// Initial weight when starting weight loss
    double? initialWeightKg,
    
    /// Weekly weight loss target in kg/week
    @Default(0.5) double weeklyWeightLossTarget,
    
    // Timestamps
    /// Profile creation timestamp
    DateTime? createdAt,
    
    /// Profile last update timestamp
    DateTime? updatedAt,
  }) = _UserProfileFreezed;

  /// Creates a UserProfileFreezed instance from JSON data
  factory UserProfileFreezed.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFreezedFromJson(json);

  /// Creates a UserProfileFreezed instance from Supabase response data
  factory UserProfileFreezed.fromSupabase(Map<String, dynamic> data) {
    return UserProfileFreezed(
      id: data['id'] as int?,
      uid: data['uid'] as String?,
      fullName: data['full_name'] as String?,
      email: data['email'] as String?,
      dateOfBirth: _parseDate(data['date_of_birth']),
      gender: data['gender'] as String? ?? 'male',
      heightCm: _safeParseDouble(data['height_cm']),
      currentWeightKg: _safeParseDouble(data['current_weight_kg']),
      targetWeightKg: data['target_weight_kg'] != null 
          ? _safeParseDouble(data['target_weight_kg']) 
          : null,
      goal: data['goal'] as String? ?? 'maintaining',
      activityLevel: _safeParseDouble(data['activity_level']) == 0.0 
          ? 1.2 
          : _safeParseDouble(data['activity_level']),
      bmrCalories: data['bmr_calories'] as int?,
      tdeeCalories: data['tdee_calories'] as int?,
      targetCalories: data['target_calories'] as int?,
      targetProteinG: data['target_protein_g'] != null 
          ? _safeParseDouble(data['target_protein_g']) 
          : null,
      targetCarbsG: data['target_carbs_g'] != null 
          ? _safeParseDouble(data['target_carbs_g']) 
          : null,
      targetFatsG: data['target_fats_g'] != null 
          ? _safeParseDouble(data['target_fats_g']) 
          : null,
      weightLossStartDate: _parseDate(data['weight_loss_start_date']),
      initialWeightKg: data['initial_weight_kg'] != null 
          ? _safeParseDouble(data['initial_weight_kg']) 
          : null,
      weeklyWeightLossTarget: _safeParseDouble(data['weekly_weight_loss_target']) == 0.0 
          ? 0.5 
          : _safeParseDouble(data['weekly_weight_loss_target']),
      createdAt: _parseDate(data['created_at']),
      updatedAt: _parseDate(data['updated_at']),
    );
  }
}

/// Extension methods for UserProfileFreezed
extension UserProfileFreezedExtension on UserProfileFreezed {
  /// Converts to Supabase-compatible map for database operations
  Map<String, dynamic> toSupabase() {
    return {
      'uid': uid,
      'full_name': fullName,
      'email': email,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height_cm': heightCm,
      'current_weight_kg': currentWeightKg,
      'target_weight_kg': targetWeightKg,
      'goal': goal,
      'activity_level': activityLevel,
      'bmr_calories': bmrCalories,
      'tdee_calories': tdeeCalories,
      'target_calories': targetCalories,
      'target_protein_g': targetProteinG,
      'target_carbs_g': targetCarbsG,
      'target_fats_g': targetFatsG,
      'weight_loss_start_date': weightLossStartDate?.toIso8601String(),
      'initial_weight_kg': initialWeightKg,
      'weekly_weight_loss_target': weeklyWeightLossTarget,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Calculates age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Calculates BMI (Body Mass Index)
  double get bmi => currentWeightKg / ((heightCm / 100) * (heightCm / 100));

  /// Calculates BMR using Mifflin-St Jeor equation
  double calculateBMR() {
    if (age == null) return 0;
    
    // Mifflin-St Jeor Equation:
    // Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age + 5
    // Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age - 161
    final baseBMR = 10 * currentWeightKg + 6.25 * heightCm - 5 * age!;
    return gender == 'male' ? baseBMR + 5 : baseBMR - 161;
  }

  /// Calculates TDEE (Total Daily Energy Expenditure)
  double calculateTDEE() => calculateBMR() * activityLevel;

  /// Calculates target calories based on goal
  int calculateTargetCalories() {
    final tdee = calculateTDEE();
    
    switch (goal) {
      case 'weight_loss':
        // Create caloric deficit based on weekly target
        final dailyDeficit = weeklyWeightLossTarget * 7700 / 7; // 7700 cal/kg fat
        return (tdee - dailyDeficit).round();
      case 'weight_gain':
        // Create caloric surplus
        final dailySurplus = weeklyWeightLossTarget * 7700 / 7;
        return (tdee + dailySurplus).round();
      case 'hypertrophy':
        // Slight surplus for muscle building
        return (tdee + 200).round();
      case 'maintaining':
      default:
        return tdee.round();
    }
  }

  /// Checks if profile has required data for calculations
  bool get hasRequiredDataForCalculations =>
      heightCm > 0 && currentWeightKg > 0 && age != null && age! > 0;

  /// Gets display name for goal
  String get goalDisplayName {
    switch (goal) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'weight_gain':
        return 'Weight Gain';
      case 'maintaining':
        return 'Maintaining';
      case 'hypertrophy':
        return 'Muscle Building';
      default:
        return goal;
    }
  }

  /// Gets BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }
}

// Helper functions for safe parsing
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

DateTime? _parseDate(dynamic dateValue) {
  if (dateValue == null) return null;
  
  if (dateValue is DateTime) return dateValue;
  
  if (dateValue is String) {
    try {
      return DateTime.parse(dateValue);
    } catch (e) {
      return null;
    }
  }
  
  return null;
}