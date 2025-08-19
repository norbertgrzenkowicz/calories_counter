import '../entities/result.dart';
import '../../models/meal.dart';

/// Abstract interface for meal data operations
/// 
/// This interface defines all meal-related CRUD operations and queries.
/// Implementations should handle caching, synchronization, and data consistency.
abstract class MealRepository {
  /// Get meals for a specific date
  /// 
  /// Returns [Result.success] with list of meals for the date,
  /// or [Result.failure] with appropriate error.
  Future<Result<List<Meal>>> getMealsByDate(DateTime date);
  
  /// Get meals for a date range
  /// 
  /// Returns [Result.success] with list of meals in the date range,
  /// or [Result.failure] with appropriate error.
  Future<Result<List<Meal>>> getMealsByDateRange(DateTime startDate, DateTime endDate);
  
  /// Get all user meals
  /// 
  /// Returns [Result.success] with all user meals,
  /// or [Result.failure] with appropriate error.
  /// Note: Should implement pagination for large datasets.
  Future<Result<List<Meal>>> getAllUserMeals();
  
  /// Get a specific meal by ID
  /// 
  /// Returns [Result.success] with the meal if found,
  /// or [Result.failure] with appropriate error.
  Future<Result<Meal>> getMealById(int mealId);
  
  /// Add a new meal
  /// 
  /// Returns [Result.success] with the created meal (including server-assigned ID),
  /// or [Result.failure] with appropriate error.
  Future<Result<Meal>> addMeal(Meal meal);
  
  /// Update an existing meal
  /// 
  /// Returns [Result.success] with the updated meal,
  /// or [Result.failure] with appropriate error.
  Future<Result<Meal>> updateMeal(Meal meal);
  
  /// Delete a meal by ID
  /// 
  /// Returns [Result.success] on successful deletion,
  /// or [Result.failure] with appropriate error.
  Future<Result<void>> deleteMeal(int mealId);
  
  /// Upload meal photo and get URL
  /// 
  /// Returns [Result.success] with the photo URL,
  /// or [Result.failure] with appropriate error.
  Future<Result<String>> uploadMealPhoto(String filePath, String fileName);
  
  /// Delete meal photo by URL
  /// 
  /// Returns [Result.success] on successful deletion,
  /// or [Result.failure] with appropriate error.
  Future<Result<void>> deleteMealPhoto(String photoUrl);
  
  /// Get nutrition totals for a specific date
  /// 
  /// Returns [Result.success] with nutrition totals,
  /// or [Result.failure] with appropriate error.
  Future<Result<Map<String, num>>> getNutritionTotalsByDate(DateTime date);
  
  /// Get nutrition totals for a date range
  /// 
  /// Returns [Result.success] with daily nutrition totals,
  /// or [Result.failure] with appropriate error.
  Future<Result<Map<DateTime, Map<String, num>>>> getNutritionTotalsByDateRange(
    DateTime startDate, 
    DateTime endDate,
  );
  
  /// Search meals by name or ingredients
  /// 
  /// Returns [Result.success] with matching meals,
  /// or [Result.failure] with appropriate error.
  Future<Result<List<Meal>>> searchMeals(String query);
  
  /// Get recently added meals for quick add functionality
  /// 
  /// Returns [Result.success] with recent meals,
  /// or [Result.failure] with appropriate error.
  Future<Result<List<Meal>>> getRecentMeals(int limit);
}