import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../core/app_logger.dart';
import 'service_providers.dart';
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
      final profileService = ref.read(profileServiceProvider);
      return await profileService.getUserProfile();
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
      
      final profileService = ref.read(profileServiceProvider);
      await profileService.updateUserProfile(profile);
      
      // Refresh the profile data
      ref.invalidateSelf();
      
      AppLogger.info('Profile updated successfully');
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
      
      final profileService = ref.read(profileServiceProvider);
      await profileService.createUserProfile(profile);
      
      // Refresh the profile data
      ref.invalidateSelf();
      
      AppLogger.info('Profile created successfully');
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
      if (profile?.dailyCalorieTarget != null && profile!.dailyCalorieTarget > 0) {
        return profile.dailyCalorieTarget;
      }
      
      // Calculate basic BMR if profile exists but no custom target
      if (profile != null && profile.weight > 0 && profile.height > 0 && profile.age > 0) {
        // Using Mifflin-St Jeor equation
        double bmr;
        if (profile.gender.toLowerCase() == 'male') {
          bmr = 88.362 + (13.397 * profile.weight) + (4.799 * profile.height) - (5.677 * profile.age);
        } else {
          bmr = 447.593 + (9.247 * profile.weight) + (3.098 * profile.height) - (4.330 * profile.age);
        }
        
        // Apply activity factor (assuming lightly active = 1.375)
        return (bmr * 1.375).round();
      }
      
      // Default calorie target
      return 2000;
    },
    loading: () => 2000,
    error: (error, stack) => 2000,
  );
}