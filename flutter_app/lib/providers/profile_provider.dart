import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_profile.dart';
import '../core/app_logger.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

part 'profile_provider.g.dart';

/// User profile state notifier
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      return null;
    }

    try {
      AppLogger.debug('Loading user profile');
      final profileRepository = ref.read(profileRepositoryProvider);
      final result = await profileRepository.getUserProfile();

      return result.when(
        success: (profile) => profile,
        failure: (error) {
          AppLogger.error('Failed to load user profile: ${error.toString()}');
          return null;
        },
      );
    } catch (e) {
      AppLogger.error('Failed to load user profile', e);
      return null;
    }
  }

  /// Update user profile
  Future<void> updateProfile(UserProfile profile) async {
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      AppLogger.info('Updating user profile');
      state = const AsyncValue.loading();

      final profileRepository = ref.read(profileRepositoryProvider);
      final result = await profileRepository.updateUserProfile(profile);

      result.when(
        success: (updatedProfile) {
          // Refresh the profile data
          ref.invalidateSelf();
          AppLogger.info('Profile updated successfully');
        },
        failure: (error) {
          AppLogger.error('Failed to update profile: ${error.toString()}');
          state = AsyncValue.error(error, StackTrace.current);
          throw Exception('Failed to update profile: ${error.toString()}');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to update profile', e);
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Create new user profile
  Future<void> createProfile(UserProfile profile) async {
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      AppLogger.info('Creating user profile');
      state = const AsyncValue.loading();

      final profileRepository = ref.read(profileRepositoryProvider);
      final result = await profileRepository.createUserProfile(profile);

      result.when(
        success: (createdProfile) {
          // Refresh the profile data
          ref.invalidateSelf();
          AppLogger.info('Profile created successfully');
        },
        failure: (error) {
          AppLogger.error('Failed to create profile: ${error.toString()}');
          state = AsyncValue.error(error, StackTrace.current);
          throw Exception('Failed to create profile: ${error.toString()}');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to create profile', e);
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Provider for checking if profile exists
@riverpod
bool hasProfile(HasProfileRef ref) {
  final profileAsync = ref.watch(profileNotifierProvider);

  return profileAsync.when(
    data: (profile) => profile != null,
    loading: () => false,
    error: (error, stack) => false,
  );
}

/// Provider for getting daily calorie target
@riverpod
int dailyCalorieTarget(DailyCalorieTargetRef ref) {
  final profileAsync = ref.watch(profileNotifierProvider);

  return profileAsync.when(
    data: (profile) {
      if (profile?.targetCalories != null && profile!.targetCalories! > 0) {
        return profile.targetCalories!;
      }

      // Use calculated TDEE if available
      if (profile?.tdeeCalories != null && profile!.tdeeCalories! > 0) {
        return profile.tdeeCalories!;
      }

      // Calculate basic BMR if profile exists but no target
      if (profile != null &&
          profile.currentWeightKg > 0 &&
          profile.heightCm > 0) {
        // Using Mifflin-St Jeor equation (simplified with default age)
        double bmr;
        if (profile.gender.toLowerCase() == 'male') {
          bmr = 88.362 +
              (13.397 * profile.currentWeightKg) +
              (4.799 * profile.heightCm) -
              (5.677 * 30);
        } else {
          bmr = 447.593 +
              (9.247 * profile.currentWeightKg) +
              (3.098 * profile.heightCm) -
              (4.330 * 30);
        }

        // Apply activity factor from profile
        return (bmr * profile.activityLevel).round();
      }

      // Default calorie target
      return 2000;
    },
    loading: () => 2000,
    error: (error, stack) => 2000,
  );
}
