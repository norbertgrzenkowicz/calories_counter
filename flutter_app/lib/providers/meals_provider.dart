import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/supabase_service.dart';
import '../core/app_logger.dart';
import 'service_providers.dart';
import 'auth_provider.dart';

part 'meals_provider.g.dart';

/// Meals state for a specific date
@riverpod
class MealsNotifier extends _$MealsNotifier {
  @override
  Future<List<Map<String, dynamic>>> build(DateTime date) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) {
      return [];
    }
    
    try {
      AppLogger.debug('Loading meals for date: ${date.toIso8601String()}');
      return await supabaseService.getMealsByDate(date);
    } catch (e) {
      AppLogger.error('Failed to load meals', e);
      throw Exception('Failed to load meals: $e');
    }
  }

  /// Add a new meal
  Future<void> addMeal(Map<String, dynamic> mealData) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      AppLogger.info('Adding new meal');
      state = const AsyncValue.loading();
      
      await supabaseService.addMeal(mealData);
      
      // Refresh the meals list
      ref.invalidateSelf();
      
      AppLogger.info('Meal added successfully');
    } catch (e) {
      AppLogger.error('Failed to add meal', e);
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update an existing meal
  Future<void> updateMeal(int mealId, Map<String, dynamic> mealData) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      AppLogger.info('Updating meal: $mealId');
      state = const AsyncValue.loading();
      
      await supabaseService.updateMeal(mealId, mealData);
      
      // Refresh the meals list
      ref.invalidateSelf();
      
      AppLogger.info('Meal updated successfully');
    } catch (e) {
      AppLogger.error('Failed to update meal', e);
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Delete a meal
  Future<void> deleteMeal(int mealId) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      AppLogger.info('Deleting meal: $mealId');
      state = const AsyncValue.loading();
      
      await supabaseService.deleteMeal(mealId);
      
      // Refresh the meals list
      ref.invalidateSelf();
      
      AppLogger.info('Meal deleted successfully');
    } catch (e) {
      AppLogger.error('Failed to delete meal', e);
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Provider for getting all user meals
@riverpod
Future<List<Map<String, dynamic>>> allUserMeals(AllUserMealsRef ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  final userId = ref.read(currentUserIdProvider);
  
  if (userId == null) {
    return [];
  }
  
  try {
    AppLogger.debug('Loading all user meals');
    return await supabaseService.getAllUserMeals();
  } catch (e) {
    AppLogger.error('Failed to load all user meals', e);
    throw Exception('Failed to load meals: $e');
  }
}

/// Provider for calculating daily nutrition totals
@riverpod
Map<String, num> dailyNutritionTotals(DailyNutritionTotalsRef ref, DateTime date) {
  final mealsAsync = ref.watch(mealsNotifierProvider(date));
  
  return mealsAsync.when(
    data: (meals) {
      num totalCalories = 0;
      num totalProteins = 0;
      num totalFats = 0;
      num totalCarbs = 0;
      
      for (final meal in meals) {
        totalCalories += (meal['calories'] as num?) ?? 0;
        totalProteins += (meal['proteins'] as num?) ?? 0;
        totalFats += (meal['fats'] as num?) ?? 0;
        totalCarbs += (meal['carbs'] as num?) ?? 0;
      }
      
      return {
        'calories': totalCalories,
        'proteins': totalProteins,
        'fats': totalFats,
        'carbs': totalCarbs,
      };
    },
    loading: () => {
      'calories': 0,
      'proteins': 0,
      'fats': 0,
      'carbs': 0,
    },
    error: (error, stack) => {
      'calories': 0,
      'proteins': 0,
      'fats': 0,
      'carbs': 0,
    },
  );
}

/// Provider for meal count for a specific date
@riverpod
int dailyMealCount(DailyMealCountRef ref, DateTime date) {
  final mealsAsync = ref.watch(mealsNotifierProvider(date));
  
  return mealsAsync.when(
    data: (meals) => meals.length,
    loading: () => 0,
    error: (error, stack) => 0,
  );
}