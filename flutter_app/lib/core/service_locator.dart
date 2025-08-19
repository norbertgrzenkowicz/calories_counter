import 'package:get_it/get_it.dart';

import 'package:food_scanner/services/nutrition_calculator_service.dart';
import 'package:food_scanner/services/openfoodfacts_service.dart';
import 'package:food_scanner/services/profile_service.dart';
import 'package:food_scanner/services/supabase_service.dart';
import 'package:food_scanner/services/user_service.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Configures and registers all dependencies in the dependency injection container
/// 
/// This should be called once at app startup to ensure all services are properly
/// configured and ready for injection throughout the application.
Future<void> configureDependencies() async {
  // Core services - register first as other services depend on them
  getIt
    ..registerLazySingleton<SupabaseService>(SupabaseService.new)
    // Domain services - register after core services
    ..registerLazySingleton<ProfileService>(ProfileService.new)
    ..registerLazySingleton<OpenFoodFactsService>(OpenFoodFactsService.new)
    ..registerLazySingleton<UserService>(UserService.new)
    // Singleton services - register existing instance
    ..registerLazySingleton<NutritionCalculatorService>(NutritionCalculatorService.new);
  
  // Initialize Supabase after registration
  final supabaseService = getIt<SupabaseService>();
  await supabaseService.initialize();
}

/// Resets all registered dependencies
/// 
/// This is primarily used for testing to ensure clean state between tests
Future<void> resetDependencies() async {
  await getIt.reset();
}