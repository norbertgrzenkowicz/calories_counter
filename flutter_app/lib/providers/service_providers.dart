import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/user_service.dart';
import '../services/profile_service.dart';
import '../services/openfoodfacts_service.dart';
import '../services/nutrition_calculator_service.dart';

/// Provider for SupabaseService singleton
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// Provider for OpenFoodFactsService
final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>((ref) {
  return OpenFoodFactsService();
});

/// Provider for NutritionCalculatorService
final nutritionCalculatorServiceProvider = Provider<NutritionCalculatorService>((ref) {
  return NutritionCalculatorService();
});