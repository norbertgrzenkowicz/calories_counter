import 'dart:developer' as developer;
import '../models/meal.dart';
import '../core/service_locator.dart';
import 'supabase_service.dart';

class UserService {
  SupabaseService get _supabaseService => getIt<SupabaseService>();

  // Get meals for current user on a specific date
  Future<List<Meal>> getMealsForDate(DateTime date) async {
    try {
      final response = await _supabaseService.getMealsByDate(date);
      return response.map<Meal>((data) => Meal.fromSupabase(data)).toList();
    } catch (e) {
      developer.log('Failed to get meals for date: $e', name: 'UserService');
      return [];
    }
  }

  // Get meals for current user in a date range
  Future<List<Meal>> getMealsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabaseService.getMealsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      return response.map<Meal>((data) => Meal.fromSupabase(data)).toList();
    } catch (e) {
      developer.log('Failed to get meals for date range: $e', name: 'UserService');
      return [];
    }
  }

  // Get all meals for current user
  Future<List<Meal>> getAllMeals() async {
    try {
      final response = await _supabaseService.getAllUserMeals();
      return response.map<Meal>((data) => Meal.fromSupabase(data)).toList();
    } catch (e) {
      developer.log('Failed to get all meals: $e', name: 'UserService');
      return [];
    }
  }

  // Add a new meal
  Future<Meal?> addMeal({
    required String name,
    required int calories,
    required double proteins,
    required double fats,
    required double carbs,
    String? photoPath,
    DateTime? date,
  }) async {
    try {
      String? photoUrl;
      
      // Upload photo if provided
      if (photoPath != null) {
        final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
        photoUrl = await _supabaseService.uploadMealPhoto(photoPath, fileName);
      }

      final meal = Meal(
        name: name,
        calories: calories,
        proteins: proteins,
        fats: fats,
        carbs: carbs,
        photoUrl: photoUrl,
        date: date ?? DateTime.now(),
      );

      final response = await _supabaseService.addMeal(meal.toSupabase());
      return Meal.fromSupabase(response);
    } catch (e) {
      developer.log('Failed to add meal: $e', name: 'UserService');
      return null;
    }
  }
}