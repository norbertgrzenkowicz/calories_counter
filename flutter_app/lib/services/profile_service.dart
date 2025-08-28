import 'dart:developer' as developer;
import '../models/user_profile.dart';
import '../models/weight_history.dart';
import 'supabase_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final SupabaseService _supabaseService = SupabaseService();

  // Get current user's profile
  Future<UserProfile?> getUserProfile() async {
    try {
      if (!_supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Fetching profile for user: $userId',
          name: 'ProfileService');

      final response = await _supabaseService.client
          .from('user_profiles')
          .select('*')
          .eq('uid', userId)
          .maybeSingle();

      if (response == null) {
        developer.log('No profile found for user', name: 'ProfileService');
        return null;
      }

      developer.log('Profile fetched successfully', name: 'ProfileService');
      return UserProfile.fromSupabase(response);
    } catch (e) {
      developer.log('Failed to fetch user profile: $e', name: 'ProfileService');
      rethrow;
    }
  }

  // Create or update user profile
  Future<UserProfile> saveUserProfile(UserProfile profile) async {
    try {
      if (!_supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add user ID to profile
      final profileWithUser = profile.copyWith(uid: userId);
      final profileData = profileWithUser.toSupabase();

      developer.log('Saving profile for user: $userId', name: 'ProfileService');

      // Use upsert (insert or update) to handle both cases
      final response = await _supabaseService.client
          .from('user_profiles')
          .upsert(profileData, onConflict: 'uid')
          .select()
          .single();

      developer.log('Profile saved successfully', name: 'ProfileService');
      return UserProfile.fromSupabase(response);
    } catch (e) {
      developer.log('Failed to save user profile: $e', name: 'ProfileService');

      // If upsert fails, try manual update/insert approach
      try {
        final userId = _supabaseService.getCurrentUserId()!;
        final profileData = profile.copyWith(uid: userId).toSupabase();

        // Try update first
        final updateResponse = await _supabaseService.client
            .from('user_profiles')
            .update(profileData)
            .eq('uid', userId)
            .select()
            .maybeSingle();

        if (updateResponse != null) {
          developer.log('Profile updated via fallback method',
              name: 'ProfileService');
          return UserProfile.fromSupabase(updateResponse);
        }

        // If update didn't affect any rows, try insert
        final insertResponse = await _supabaseService.client
            .from('user_profiles')
            .insert(profileData)
            .select()
            .single();

        developer.log('Profile created via fallback method',
            name: 'ProfileService');
        return UserProfile.fromSupabase(insertResponse);
      } catch (fallbackError) {
        developer.log('Fallback method also failed: $fallbackError',
            name: 'ProfileService');
        throw Exception('Unable to save profile: $fallbackError');
      }
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile() async {
    try {
      if (!_supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Deleting profile for user: $userId',
          name: 'ProfileService');

      await _supabaseService.client
          .from('user_profiles')
          .delete()
          .eq('uid', userId);

      developer.log('Profile deleted successfully', name: 'ProfileService');
    } catch (e) {
      developer.log('Failed to delete user profile: $e',
          name: 'ProfileService');
      rethrow;
    }
  }

  // Add weight entry
  Future<WeightHistory> addWeightEntry(WeightHistory weightEntry) async {
    try {
      if (!_supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add user ID to weight entry
      final weightWithUser = weightEntry.copyWith(uid: userId);
      final weightData = weightWithUser.toSupabase();

      developer.log('Adding weight entry for user: $userId',
          name: 'ProfileService');

      final response = await _supabaseService.client
          .from('weight_history')
          .insert(weightData)
          .select()
          .single();

      developer.log('Weight entry added successfully', name: 'ProfileService');
      return WeightHistory.fromSupabase(response);
    } catch (e) {
      developer.log('Failed to add weight entry: $e', name: 'ProfileService');
      rethrow;
    }
  }

  // Get weight history for date range
  Future<List<WeightHistory>> getWeightHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      if (!_supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Fetching weight history for user: $userId',
          name: 'ProfileService');

      var queryBuilder = _supabaseService.client
          .from('weight_history')
          .select('*')
          .eq('uid', userId);

      if (startDate != null) {
        queryBuilder = queryBuilder.gte(
            'recorded_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        queryBuilder = queryBuilder.lte(
            'recorded_date', endDate.toIso8601String().split('T')[0]);
      }

      final query = queryBuilder.order('recorded_date', ascending: false);

      final response = await (limit != null ? query.limit(limit) : query);

      developer.log('Fetched ${response.length} weight entries',
          name: 'ProfileService');
      return response
          .map<WeightHistory>((data) => WeightHistory.fromSupabase(data))
          .toList();
    } catch (e) {
      developer.log('Failed to fetch weight history: $e',
          name: 'ProfileService');
      rethrow;
    }
  }

  // Get latest weight entry
  Future<WeightHistory?> getLatestWeight() async {
    try {
      final weightHistory = await getWeightHistory(limit: 1);
      return weightHistory.isNotEmpty ? weightHistory.first : null;
    } catch (e) {
      developer.log('Failed to fetch latest weight: $e',
          name: 'ProfileService');
      return null;
    }
  }

  // Update weight entry
  Future<WeightHistory> updateWeightEntry(WeightHistory weightEntry) async {
    try {
      if (!_supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      if (weightEntry.id == null) {
        throw Exception('Weight entry ID is required for update');
      }

      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Updating weight entry: ${weightEntry.id}',
          name: 'ProfileService');

      final response = await _supabaseService.client
          .from('weight_history')
          .update(weightEntry.toSupabase())
          .eq('id', weightEntry.id!)
          .eq('uid', userId)
          .select()
          .single();

      developer.log('Weight entry updated successfully',
          name: 'ProfileService');
      return WeightHistory.fromSupabase(response);
    } catch (e) {
      developer.log('Failed to update weight entry: $e',
          name: 'ProfileService');
      rethrow;
    }
  }

  // Delete weight entry
  Future<void> deleteWeightEntry(int weightEntryId) async {
    try {
      if (!_supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Deleting weight entry: $weightEntryId',
          name: 'ProfileService');

      await _supabaseService.client
          .from('weight_history')
          .delete()
          .eq('id', weightEntryId)
          .eq('uid', userId);

      developer.log('Weight entry deleted successfully',
          name: 'ProfileService');
    } catch (e) {
      developer.log('Failed to delete weight entry: $e',
          name: 'ProfileService');
      rethrow;
    }
  }

  // Get weight statistics
  Future<Map<String, dynamic>> getWeightStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final weightHistory = await getWeightHistory(
        startDate: startDate,
        endDate: endDate,
      );

      if (weightHistory.isEmpty) {
        return {
          'totalEntries': 0,
          'weightChange': 0.0,
          'averageWeight': 0.0,
          'minWeight': 0.0,
          'maxWeight': 0.0,
          'trend': 'stable',
        };
      }

      // Sort by date (oldest first for calculations)
      final sortedHistory = weightHistory.reversed.toList();

      final weights = sortedHistory.map((e) => e.weightKg).toList();
      final totalEntries = weights.length;

      // Additional safety check to prevent division by zero
      if (totalEntries == 0) {
        return {
          'totalEntries': 0,
          'weightChange': 0.0,
          'averageWeight': 0.0,
          'minWeight': 0.0,
          'maxWeight': 0.0,
          'trend': 'stable',
        };
      }

      final averageWeight = weights.reduce((a, b) => a + b) / totalEntries;
      final minWeight = weights.reduce((a, b) => a < b ? a : b);
      final maxWeight = weights.reduce((a, b) => a > b ? a : b);

      double weightChange = 0.0;
      String trend = 'stable';

      if (totalEntries > 1) {
        weightChange = weights.last - weights.first;

        // Calculate trend
        if (weightChange > 0.5) {
          trend = 'increasing';
        } else if (weightChange < -0.5) {
          trend = 'decreasing';
        } else {
          trend = 'stable';
        }
      }

      return {
        'totalEntries': totalEntries,
        'weightChange': weightChange,
        'averageWeight': averageWeight,
        'minWeight': minWeight,
        'maxWeight': maxWeight,
        'trend': trend,
        'firstWeight': weights.isNotEmpty ? weights.first : 0.0,
        'lastWeight': weights.isNotEmpty ? weights.last : 0.0,
        'dateRange': {
          'start':
              sortedHistory.first.recordedDate.toIso8601String().split('T')[0],
          'end':
              sortedHistory.last.recordedDate.toIso8601String().split('T')[0],
        },
      };
    } catch (e) {
      developer.log('Failed to calculate weight statistics: $e',
          name: 'ProfileService');
      return {
        'totalEntries': 0,
        'weightChange': 0.0,
        'averageWeight': 0.0,
        'minWeight': 0.0,
        'maxWeight': 0.0,
        'trend': 'stable',
        'error': e.toString(),
      };
    }
  }

  // Check if user profile exists and is complete
  Future<bool> isProfileComplete() async {
    try {
      final profile = await getUserProfile();
      return profile?.hasRequiredDataForCalculations ?? false;
    } catch (e) {
      developer.log('Failed to check profile completeness: $e',
          name: 'ProfileService');
      return false;
    }
  }

  // Initialize basic profile structure from auth user (without hardcoded defaults)
  Future<UserProfile?> initializeProfileFromAuth() async {
    try {
      if (!_supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('No current user');
      }

      developer.log('User authenticated but no profile exists',
          name: 'ProfileService');

      // Don't create a profile with dummy data - return null to prompt user
      // to complete their profile with real information through the UI
      return null;
    } catch (e) {
      developer.log('Failed to check profile from auth: $e',
          name: 'ProfileService');
      return null;
    }
  }
}
