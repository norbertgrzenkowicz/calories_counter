import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/meal_repository.dart';
import '../../models/meal.dart';
import '../../services/supabase_service.dart';
import '../../core/app_logger.dart';

class MealRepositoryImpl implements MealRepository {
  final SupabaseService _supabaseService;

  MealRepositoryImpl(this._supabaseService);

  @override
  Future<Result<List<Meal>>> getMealsByDate(DateTime date) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      final dateString = date.toIso8601String().split('T')[0];

      final response = await _supabaseService.client
          .from('meals')
          .select('*')
          .eq('uid', userId)
          .eq('date', dateString)
          .order('created_at', ascending: false);

      final meals =
          response.map<Meal>((data) => Meal.fromSupabase(data)).toList();

      AppLogger.debug('Fetched ${meals.length} meals for date $dateString');
      return Result.success(meals);
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error fetching meals by date: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching meals by date', e);
      return Result.failure(
        AppError.unknown('Failed to fetch meals: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Meal>>> getMealsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      final startDateString = startDate.toIso8601String().split('T')[0];
      final endDateString = endDate.toIso8601String().split('T')[0];

      final response = await _supabaseService.client
          .from('meals')
          .select('*')
          .eq('uid', userId)
          .gte('date', startDateString)
          .lte('date', endDateString)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      final meals =
          response.map<Meal>((data) => Meal.fromSupabase(data)).toList();

      AppLogger.debug(
          'Fetched ${meals.length} meals for date range $startDateString to $endDateString');
      return Result.success(meals);
    } on PostgrestException catch (e) {
      AppLogger.error(
          'Supabase error fetching meals by date range: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching meals by date range', e);
      return Result.failure(
        AppError.unknown('Failed to fetch meals: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Meal>>> getAllUserMeals() async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      final response = await _supabaseService.client
          .from('meals')
          .select('*')
          .eq('uid', userId)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      final meals =
          response.map<Meal>((data) => Meal.fromSupabase(data)).toList();

      AppLogger.debug('Fetched ${meals.length} total meals for user');
      return Result.success(meals);
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error fetching all user meals: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching all user meals', e);
      return Result.failure(
        AppError.unknown('Failed to fetch meals: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Meal>> getMealById(int mealId) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      final response = await _supabaseService.client
          .from('meals')
          .select('*')
          .eq('id', mealId)
          .eq('uid', userId)
          .maybeSingle();

      if (response == null) {
        return const Result.failure(
          AppError.notFound('Meal not found'),
        );
      }

      final meal = Meal.fromSupabase(response);
      AppLogger.debug('Fetched meal with ID $mealId');
      return Result.success(meal);
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error fetching meal by ID: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching meal by ID', e);
      return Result.failure(
        AppError.unknown('Failed to fetch meal: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Meal>> addMeal(Meal meal) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      // Add user ID to meal
      final mealWithUser = meal.copyWith(uid: userId);
      final mealData = mealWithUser.toSupabase();

      final response = await _supabaseService.client
          .from('meals')
          .insert(mealData)
          .select()
          .single();

      final createdMeal = Meal.fromSupabase(response);
      AppLogger.info('Added new meal: ${createdMeal.name}');
      return Result.success(createdMeal);
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error adding meal: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error adding meal', e);
      return Result.failure(
        AppError.unknown('Failed to add meal: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Meal>> updateMeal(Meal meal) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      if (meal.id == null) {
        return const Result.failure(
          AppError.validation('Meal ID is required for update'),
        );
      }

      final mealData = meal.toSupabase();

      final response = await _supabaseService.client
          .from('meals')
          .update(mealData)
          .eq('id', meal.id!)
          .eq('uid', userId)
          .select()
          .single();

      final updatedMeal = Meal.fromSupabase(response);
      AppLogger.info('Updated meal: ${updatedMeal.name}');
      return Result.success(updatedMeal);
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error updating meal: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error updating meal', e);
      return Result.failure(
        AppError.unknown('Failed to update meal: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteMeal(int mealId) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      await _supabaseService.client
          .from('meals')
          .delete()
          .eq('id', mealId)
          .eq('uid', userId);

      AppLogger.info('Deleted meal with ID $mealId');
      return const Result.success(null);
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error deleting meal: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error deleting meal', e);
      return Result.failure(
        AppError.unknown('Failed to delete meal: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<String>> uploadMealPhoto(
      String filePath, String fileName) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      // Create unique file name to prevent conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${userId}_${timestamp}_$fileName';
      final storagePath = 'meal_photos/$uniqueFileName';

      final response = await _supabaseService.client.storage
          .from('meal-photos')
          .upload(storagePath, File(filePath));

      if (response.isEmpty) {
        return const Result.failure(
          AppError.server('Failed to upload photo'),
        );
      }

      final publicUrl = _supabaseService.client.storage
          .from('meal-photos')
          .getPublicUrl(storagePath);

      AppLogger.info('Uploaded meal photo: $storagePath');
      return Result.success(publicUrl);
    } on StorageException catch (e) {
      AppLogger.error('Storage error uploading meal photo: ${e.message}');
      return Result.failure(
        AppError.server('Storage error: ${e.message}'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error uploading meal photo', e);
      return Result.failure(
        AppError.unknown('Failed to upload photo: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteMealPhoto(String photoUrl) async {
    try {
      // Extract storage path from public URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;

      // Find the index of 'meal-photos' bucket in path
      final bucketIndex = pathSegments.indexOf('meal-photos');
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        return const Result.failure(
          AppError.validation('Invalid photo URL format'),
        );
      }

      // Get the file path after the bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabaseService.client.storage
          .from('meal-photos')
          .remove([filePath]);

      AppLogger.info('Deleted meal photo: $filePath');
      return const Result.success(null);
    } on StorageException catch (e) {
      AppLogger.error('Storage error deleting meal photo: ${e.message}');
      return Result.failure(
        AppError.server('Storage error: ${e.message}'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error deleting meal photo', e);
      return Result.failure(
        AppError.unknown('Failed to delete photo: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<String, num>>> getNutritionTotalsByDate(
      DateTime date) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      final dateString = date.toIso8601String().split('T')[0];

      final response = await _supabaseService.client
          .from('meals')
          .select('calories, proteins, carbs, fats, sugars, fiber, sodium')
          .eq('uid', userId)
          .eq('date', dateString);

      // Calculate totals
      num totalCalories = 0;
      num totalProteins = 0;
      num totalCarbs = 0;
      num totalFats = 0;
      num totalSugars = 0;
      num totalFiber = 0;
      num totalSodium = 0;

      for (final meal in response) {
        totalCalories += (meal['calories'] as num?) ?? 0;
        totalProteins += (meal['proteins'] as num?) ?? 0;
        totalCarbs += (meal['carbs'] as num?) ?? 0;
        totalFats += (meal['fats'] as num?) ?? 0;
        totalSugars += (meal['sugars'] as num?) ?? 0;
        totalFiber += (meal['fiber'] as num?) ?? 0;
        totalSodium += (meal['sodium'] as num?) ?? 0;
      }

      final totals = {
        'calories': totalCalories,
        'proteins': totalProteins,
        'carbs': totalCarbs,
        'fats': totalFats,
        'sugars': totalSugars,
        'fiber': totalFiber,
        'sodium': totalSodium,
      };

      AppLogger.debug(
          'Calculated nutrition totals for $dateString: $totalCalories calories');
      return Result.success(totals);
    } on PostgrestException catch (e) {
      AppLogger.error(
          'Supabase error calculating nutrition totals: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error calculating nutrition totals', e);
      return Result.failure(
        AppError.unknown(
            'Failed to calculate nutrition totals: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<DateTime, Map<String, num>>>> getNutritionTotalsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      final startDateString = startDate.toIso8601String().split('T')[0];
      final endDateString = endDate.toIso8601String().split('T')[0];

      final response = await _supabaseService.client
          .from('meals')
          .select(
              'date, calories, proteins, carbs, fats, sugars, fiber, sodium')
          .eq('uid', userId)
          .gte('date', startDateString)
          .lte('date', endDateString)
          .order('date');

      // Group by date and calculate totals
      final Map<DateTime, Map<String, num>> dailyTotals = {};

      for (final meal in response) {
        final dateString = meal['date'] as String;
        final date = DateTime.parse(dateString);

        if (!dailyTotals.containsKey(date)) {
          dailyTotals[date] = {
            'calories': 0,
            'proteins': 0,
            'carbs': 0,
            'fats': 0,
            'sugars': 0,
            'fiber': 0,
            'sodium': 0,
          };
        }

        final dayTotals = dailyTotals[date]!;
        dayTotals['calories'] =
            (dayTotals['calories']! as num) + ((meal['calories'] as num?) ?? 0);
        dayTotals['proteins'] =
            (dayTotals['proteins']! as num) + ((meal['proteins'] as num?) ?? 0);
        dayTotals['carbs'] =
            (dayTotals['carbs']! as num) + ((meal['carbs'] as num?) ?? 0);
        dayTotals['fats'] =
            (dayTotals['fats']! as num) + ((meal['fats'] as num?) ?? 0);
        dayTotals['sugars'] =
            (dayTotals['sugars']! as num) + ((meal['sugars'] as num?) ?? 0);
        dayTotals['fiber'] =
            (dayTotals['fiber']! as num) + ((meal['fiber'] as num?) ?? 0);
        dayTotals['sodium'] =
            (dayTotals['sodium']! as num) + ((meal['sodium'] as num?) ?? 0);
      }

      AppLogger.debug(
          'Calculated nutrition totals for ${dailyTotals.length} days');
      return Result.success(dailyTotals);
    } on PostgrestException catch (e) {
      AppLogger.error(
          'Supabase error calculating nutrition totals by date range: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error(
          'Unexpected error calculating nutrition totals by date range', e);
      return Result.failure(
        AppError.unknown(
            'Failed to calculate nutrition totals: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Meal>>> searchMeals(String query) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      if (query.trim().isEmpty) {
        return const Result.success([]);
      }

      final response = await _supabaseService.client
          .from('meals')
          .select('*')
          .eq('uid', userId)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50); // Limit results to prevent excessive data

      final meals =
          response.map<Meal>((data) => Meal.fromSupabase(data)).toList();

      AppLogger.debug('Found ${meals.length} meals matching query: $query');
      return Result.success(meals);
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error searching meals: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error searching meals', e);
      return Result.failure(
        AppError.unknown('Failed to search meals: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Meal>>> getRecentMeals(int limit) async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        return const Result.failure(
          AppError.authentication('User not authenticated'),
        );
      }

      final response = await _supabaseService.client
          .from('meals')
          .select('*')
          .eq('uid', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final meals =
          response.map<Meal>((data) => Meal.fromSupabase(data)).toList();

      AppLogger.debug('Fetched ${meals.length} recent meals');
      return Result.success(meals);
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error fetching recent meals: ${e.message}');
      return Result.failure(
        AppError.server('Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) : null),
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching recent meals', e);
      return Result.failure(
        AppError.unknown('Failed to fetch recent meals: ${e.toString()}'),
      );
    }
  }
}
