import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/meal.dart';
import '../core/app_logger.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

part 'meals_provider.g.dart';

/// Meals state for a specific date
@riverpod
class MealsNotifier extends _$MealsNotifier {
  @override
  Future<List<Map<String, dynamic>>> build(DateTime date) async {
    final mealRepository = ref.read(mealRepositoryProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      return [];
    }

    try {
      AppLogger.debug('Loading meals for date: ${date.toIso8601String()}');
      final result = await mealRepository.getMealsByDate(date);

      return result.when(
        success: (meals) => meals.map((meal) => meal.toSupabase()).toList(),
        failure: (error) {
          AppLogger.error('Failed to load meals: ${error.toString()}');
          throw Exception('Failed to load meals: ${error.toString()}');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to load meals', e);
      throw Exception('Failed to load meals: $e');
    }
  }

  /// Add a new meal
  Future<void> addMeal(Meal meal) async {
    final mealRepository = ref.read(mealRepositoryProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      AppLogger.info('Adding new meal');
      state = const AsyncValue.loading();

      final result = await mealRepository.addMeal(meal);

      result.when(
        success: (createdMeal) {
          // Refresh the meals list
          ref.invalidateSelf();
          AppLogger.info('Meal added successfully');
        },
        failure: (error) {
          AppLogger.error('Failed to add meal: ${error.toString()}');
          state = AsyncValue.error(error, StackTrace.current);
          throw Exception('Failed to add meal: ${error.toString()}');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to add meal', e);
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update an existing meal
  Future<void> updateMeal(Meal meal) async {
    final mealRepository = ref.read(mealRepositoryProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      AppLogger.info('Updating meal: ${meal.id}');
      state = const AsyncValue.loading();

      final result = await mealRepository.updateMeal(meal);

      result.when(
        success: (updatedMeal) {
          // Refresh the meals list
          ref.invalidateSelf();
          AppLogger.info('Meal updated successfully');
        },
        failure: (error) {
          AppLogger.error('Failed to update meal: ${error.toString()}');
          state = AsyncValue.error(error, StackTrace.current);
          throw Exception('Failed to update meal: ${error.toString()}');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to update meal', e);
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Delete a meal
  Future<void> deleteMeal(int mealId) async {
    final mealRepository = ref.read(mealRepositoryProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      AppLogger.info('Deleting meal: $mealId');
      state = const AsyncValue.loading();

      final result = await mealRepository.deleteMeal(mealId);

      result.when(
        success: (_) {
          // Refresh the meals list
          ref.invalidateSelf();
          AppLogger.info('Meal deleted successfully');
        },
        failure: (error) {
          AppLogger.error('Failed to delete meal: ${error.toString()}');
          state = AsyncValue.error(error, StackTrace.current);
          throw Exception('Failed to delete meal: ${error.toString()}');
        },
      );
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
  final mealRepository = ref.read(mealRepositoryProvider);
  final userId = ref.read(currentUserIdProvider);

  if (userId == null) {
    return [];
  }

  try {
    AppLogger.debug('Loading all user meals');
    final result = await mealRepository.getAllUserMeals();

    return result.when(
      success: (meals) => meals.map((meal) => meal.toSupabase()).toList(),
      failure: (error) {
        AppLogger.error('Failed to load all user meals: ${error.toString()}');
        throw Exception('Failed to load meals: ${error.toString()}');
      },
    );
  } catch (e) {
    AppLogger.error('Failed to load all user meals', e);
    throw Exception('Failed to load meals: $e');
  }
}

/// Provider for calculating daily nutrition totals
@riverpod
Map<String, num> dailyNutritionTotals(
    DailyNutritionTotalsRef ref, DateTime date) {
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
