import '../entities/result.dart';
import '../../models/user_profile.dart';

/// Abstract interface for user profile operations
///
/// This interface defines all profile-related operations including
/// personal information, nutrition targets, and preferences.
abstract class ProfileRepository {
  /// Get current user's profile
  ///
  /// Returns [Result.success] with the user profile if it exists,
  /// or [Result.failure] with appropriate error.
  Future<Result<UserProfile?>> getUserProfile();

  /// Create new user profile
  ///
  /// Returns [Result.success] with the created profile,
  /// or [Result.failure] with appropriate error.
  Future<Result<UserProfile>> createUserProfile(UserProfile profile);

  /// Update existing user profile
  ///
  /// Returns [Result.success] with the updated profile,
  /// or [Result.failure] with appropriate error.
  Future<Result<UserProfile>> updateUserProfile(UserProfile profile);

  /// Delete user profile
  ///
  /// Returns [Result.success] on successful deletion,
  /// or [Result.failure] with appropriate error.
  Future<Result<void>> deleteUserProfile();

  /// Check if user has completed profile setup
  ///
  /// Returns true if profile exists and has minimum required information.
  Future<Result<bool>> hasCompleteProfile();

  /// Calculate daily calorie target based on profile
  ///
  /// Uses BMR calculation and activity level to determine daily calorie needs.
  /// Returns [Result.success] with calorie target,
  /// or [Result.failure] with appropriate error.
  Future<Result<int>> calculateDailyCalorieTarget();

  /// Calculate BMI (Body Mass Index) from profile data
  ///
  /// Returns [Result.success] with BMI value,
  /// or [Result.failure] if insufficient data or calculation error.
  Future<Result<double>> calculateBMI();

  /// Get recommended macronutrient ratios based on goals
  ///
  /// Returns [Result.success] with macronutrient percentages,
  /// or [Result.failure] with appropriate error.
  Future<Result<Map<String, double>>> getRecommendedMacros();

  /// Update nutrition targets
  ///
  /// Returns [Result.success] with updated profile,
  /// or [Result.failure] with appropriate error.
  Future<Result<UserProfile>> updateNutritionTargets({
    int? dailyCalorieTarget,
    double? proteinTarget,
    double? carbTarget,
    double? fatTarget,
  });

  /// Update activity level and recalculate targets
  ///
  /// Returns [Result.success] with updated profile,
  /// or [Result.failure] with appropriate error.
  Future<Result<UserProfile>> updateActivityLevel(String activityLevel);
}
