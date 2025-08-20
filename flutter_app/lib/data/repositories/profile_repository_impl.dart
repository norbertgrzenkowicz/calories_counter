import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../models/user_profile.dart';
import '../../services/profile_service.dart';
import '../../core/app_logger.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl(this._profileService);

  @override
  Future<Result<UserProfile?>> getUserProfile() async {
    try {
      final profile = await _profileService.getUserProfile();
      AppLogger.debug('Retrieved user profile from service');
      return Result.success(profile);
    } catch (e) {
      AppLogger.error('Failed to get user profile', e);
      return Result.failure(
        AppError.unknown('Failed to retrieve profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> createUserProfile(UserProfile profile) async {
    try {
      final createdProfile = await _profileService.saveUserProfile(profile);
      AppLogger.info('Created new user profile');
      return Result.success(createdProfile);
    } catch (e) {
      AppLogger.error('Failed to create user profile', e);
      
      if (e.toString().contains('duplicate key') || e.toString().contains('already exists')) {
        return const Result.failure(
          AppError.conflict('Profile already exists for this user'),
        );
      }
      
      if (e.toString().contains('validation') || e.toString().contains('constraint')) {
        return Result.failure(
          AppError.validation('Invalid profile data: ${e.toString()}'),
        );
      }
      
      return Result.failure(
        AppError.unknown('Failed to create profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> updateUserProfile(UserProfile profile) async {
    try {
      final updatedProfile = await _profileService.saveUserProfile(profile);
      AppLogger.info('Updated user profile');
      return Result.success(updatedProfile);
    } catch (e) {
      AppLogger.error('Failed to update user profile', e);
      
      if (e.toString().contains('not found') || e.toString().contains('no rows')) {
        return const Result.failure(
          AppError.notFound('Profile not found'),
        );
      }
      
      if (e.toString().contains('validation') || e.toString().contains('constraint')) {
        return Result.failure(
          AppError.validation('Invalid profile data: ${e.toString()}'),
        );
      }
      
      return Result.failure(
        AppError.unknown('Failed to update profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteUserProfile() async {
    try {
      await _profileService.deleteUserProfile();
      AppLogger.info('Deleted user profile');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Failed to delete user profile', e);
      
      if (e.toString().contains('not found') || e.toString().contains('no rows')) {
        return const Result.failure(
          AppError.notFound('Profile not found'),
        );
      }
      
      return Result.failure(
        AppError.unknown('Failed to delete profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<bool>> hasCompleteProfile() async {
    try {
      final isComplete = await _profileService.isProfileComplete();
      AppLogger.debug('Checked profile completeness: $isComplete');
      return Result.success(isComplete);
    } catch (e) {
      AppLogger.error('Failed to check profile completeness', e);
      return Result.failure(
        AppError.unknown('Failed to check profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<int>> calculateDailyCalorieTarget() async {
    try {
      final profile = await _profileService.getUserProfile();
      
      if (profile == null) {
        return const Result.failure(
          AppError.notFound('Profile not found'),
        );
      }
      
      if (!profile.hasRequiredDataForCalculations) {
        return const Result.failure(
          AppError.validation('Insufficient profile data for calorie calculation'),
        );
      }
      
      final calorieTarget = profile.calculateTargetCalories();
      AppLogger.debug('Calculated daily calorie target: $calorieTarget');
      return Result.success(calorieTarget);
    } catch (e) {
      AppLogger.error('Failed to calculate daily calorie target', e);
      return Result.failure(
        AppError.unknown('Failed to calculate calorie target: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<double>> calculateBMI() async {
    try {
      final profile = await _profileService.getUserProfile();
      
      if (profile == null) {
        return const Result.failure(
          AppError.notFound('Profile not found'),
        );
      }
      
      if (profile.heightCm <= 0 || profile.currentWeightKg <= 0) {
        return const Result.failure(
          AppError.validation('Height and weight are required for BMI calculation'),
        );
      }
      
      // BMI = weight(kg) / height(m)^2
      final heightInMeters = profile.heightCm / 100;
      final bmi = profile.currentWeightKg / (heightInMeters * heightInMeters);
      
      AppLogger.debug('Calculated BMI: ${bmi.toStringAsFixed(1)}');
      return Result.success(bmi);
    } catch (e) {
      AppLogger.error('Failed to calculate BMI', e);
      return Result.failure(
        AppError.unknown('Failed to calculate BMI: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<String, double>>> getRecommendedMacros() async {
    try {
      final profile = await _profileService.getUserProfile();
      
      if (profile == null) {
        return const Result.failure(
          AppError.notFound('Profile not found'),
        );
      }
      
      if (!profile.hasRequiredDataForCalculations) {
        return const Result.failure(
          AppError.validation('Insufficient profile data for macro calculation'),
        );
      }
      
      final macros = profile.calculateTargetMacros();
      AppLogger.debug('Calculated recommended macros: P:${macros['protein']?.toStringAsFixed(1)}g C:${macros['carbs']?.toStringAsFixed(1)}g F:${macros['fat']?.toStringAsFixed(1)}g');
      return Result.success(macros);
    } catch (e) {
      AppLogger.error('Failed to calculate recommended macros', e);
      return Result.failure(
        AppError.unknown('Failed to calculate macros: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> updateNutritionTargets({
    int? dailyCalorieTarget,
    double? proteinTarget,
    double? carbTarget,
    double? fatTarget,
  }) async {
    try {
      final profile = await _profileService.getUserProfile();
      
      if (profile == null) {
        return const Result.failure(
          AppError.notFound('Profile not found'),
        );
      }
      
      // Update the profile with new nutrition targets
      final updatedProfile = profile.copyWith(
        targetCalories: dailyCalorieTarget,
        targetProteinG: proteinTarget,
        targetCarbsG: carbTarget,
        targetFatsG: fatTarget,
        updatedAt: DateTime.now(),
      );
      
      final savedProfile = await _profileService.saveUserProfile(updatedProfile);
      AppLogger.info('Updated nutrition targets');
      return Result.success(savedProfile);
    } catch (e) {
      AppLogger.error('Failed to update nutrition targets', e);
      return Result.failure(
        AppError.unknown('Failed to update nutrition targets: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> updateActivityLevel(String activityLevel) async {
    try {
      final profile = await _profileService.getUserProfile();
      
      if (profile == null) {
        return const Result.failure(
          AppError.notFound('Profile not found'),
        );
      }
      
      // Parse activity level to numeric value
      double activityFactor;
      switch (activityLevel.toLowerCase()) {
        case 'sedentary':
          activityFactor = 1.2;
          break;
        case 'light':
          activityFactor = 1.375;
          break;
        case 'moderate':
          activityFactor = 1.55;
          break;
        case 'active':
          activityFactor = 1.725;
          break;
        case 'very_active':
          activityFactor = 1.9;
          break;
        case 'extremely_active':
          activityFactor = 2.4;
          break;
        default:
          return Result.failure(
            AppError.validation('Invalid activity level: $activityLevel'),
          );
      }
      
      // Update profile with new activity level and recalculate targets
      final updatedProfile = profile.copyWith(
        activityLevel: activityFactor,
        updatedAt: DateTime.now(),
      );
      
      // Recalculate nutrition targets based on new activity level
      int newCalorieTarget = 0;
      Map<String, double> newMacros = {'protein': 0.0, 'carbs': 0.0, 'fat': 0.0};
      
      if (updatedProfile.hasRequiredDataForCalculations) {
        try {
          newCalorieTarget = updatedProfile.calculateTargetCalories();
          newMacros = updatedProfile.calculateTargetMacros();
        } catch (calculationError) {
          AppLogger.warning('Failed to recalculate targets, using existing values: $calculationError');
        }
      }
      
      final finalProfile = updatedProfile.copyWith(
        targetCalories: newCalorieTarget > 0 ? newCalorieTarget : updatedProfile.targetCalories,
        targetProteinG: newMacros['protein']! > 0 ? newMacros['protein'] : updatedProfile.targetProteinG,
        targetCarbsG: newMacros['carbs']! > 0 ? newMacros['carbs'] : updatedProfile.targetCarbsG,
        targetFatsG: newMacros['fat']! > 0 ? newMacros['fat'] : updatedProfile.targetFatsG,
      );
      
      final savedProfile = await _profileService.saveUserProfile(finalProfile);
      AppLogger.info('Updated activity level to $activityLevel and recalculated targets');
      return Result.success(savedProfile);
    } catch (e) {
      AppLogger.error('Failed to update activity level', e);
      return Result.failure(
        AppError.unknown('Failed to update activity level: ${e.toString()}'),
      );
    }
  }
}