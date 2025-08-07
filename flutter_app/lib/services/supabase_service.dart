import 'dart:developer' as developer;
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  SupabaseClient? _client;
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase client not initialized. Call initialize() first.');
    }
    return _client!;
  }

  bool get isInitialized => _client != null;

  Future<void> initialize() async {
    try {
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception('Supabase environment variables not configured. Use --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      developer.log('Supabase client initialized', name: 'SupabaseService');
    } catch (e) {
      developer.log('Failed to initialize Supabase: $e', name: 'SupabaseService');
      rethrow;
    }
  }

  Future<bool> testConnection() async {
    try {
      if (!isInitialized) {
        print('❌ Cannot test connection: Supabase not initialized');
        throw Exception('Supabase not initialized');
      }

      print('🔄 Testing Supabase connection...');
      developer.log('Testing Supabase connection', name: 'SupabaseService');

      // Test basic connection with a simple query
      print('🔍 Checking database schema...');
      try {
        final response = await client
            .from('users')
            .select('*')
            .limit(1);

        print('✅ Connection test successful');
        print('📊 Query result: $response');
        print('📋 Users table exists and is accessible');
        developer.log('Connection test successful. Result: $response', name: 'SupabaseService');
        
        return true;
      } catch (tableError) {
        print('⚠️ Users table query failed: $tableError');
        
        // Try to check if we can access any table
        try {
          await client.rpc('version');
          print('✅ Basic Supabase connection works');
          print('❌ But users table is not accessible');
          return false;
        } catch (basicError) {
          print('❌ Basic connection also failed: $basicError');
          throw basicError;
        }
      }
    } catch (e) {
      print('❌ Connection test failed: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('404')) {
        print('💡 Table not found - you may need to create a public.users table');
        print('💡 Or configure RLS policies for the users table');
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        print('💡 Authentication/authorization error - check API keys and RLS policies');
      } else if (e.toString().contains('network') || e.toString().contains('timeout')) {
        print('💡 Network connectivity issue detected');
      }
      developer.log('Connection test failed: $e', name: 'SupabaseService');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> executeSimpleQuery(String table, {int limit = 10}) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      print('🔄 Executing query on table: $table');
      developer.log('Executing query on table: $table', name: 'SupabaseService');

      final response = await client
          .from(table)
          .select('*')
          .limit(limit);

      print('✅ Query executed successfully');
      print('📊 Result count: ${response.length}');
      print('📋 Data: $response');
      developer.log('Query successful. Count: ${response.length}, Data: $response', name: 'SupabaseService');

      return response;
    } catch (e) {
      print('❌ Query failed: $e');
      developer.log('Query failed: $e', name: 'SupabaseService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStatus() async {
    try {
      if (!isInitialized) {
        return {'status': 'not_initialized', 'message': 'Supabase not initialized'};
      }

      print('🔄 Getting Supabase status...');
      
      // Simple status check by querying users table instead of version function
      await client.from('users').select('count').limit(1);
      
      final status = {
        'status': 'connected',
        'initialized': true,
        'url': supabaseUrl,
        'message': 'Successfully connected to Supabase',
      };

      print('✅ Status check successful');
      print('📊 Status: $status');
      developer.log('Status check successful: $status', name: 'SupabaseService');

      return status;
    } catch (e) {
      final errorStatus = {
        'status': 'error',
        'initialized': isInitialized,
        'error': e.toString(),
      };

      print('❌ Status check failed: $e');
      developer.log('Status check failed: $e', name: 'SupabaseService');

      return errorStatus;
    }
  }

  Future<void> signOut() async {
    try {
      if (!isInitialized) {
        developer.log('Cannot sign out: Supabase not initialized', name: 'SupabaseService');
        return;
      }
      await client.auth.signOut();
      developer.log('User signed out', name: 'SupabaseService');
    } catch (e) {
      developer.log('Failed to sign out: $e', name: 'SupabaseService');
      rethrow;
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    if (!isInitialized) return null;
    return client.auth.currentUser?.id;
  }

  // Fetch meals for a specific date range and current user
  Future<List<Map<String, dynamic>>> getMealsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Fetching meals for user: $userId from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}', name: 'SupabaseService');

      final response = await client
          .from('meals')
          .select('*, photo_url')
          .eq('uid', userId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: true);

      developer.log('Fetched ${response.length} meals', name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to fetch meals by date range: $e', name: 'SupabaseService');
      rethrow;
    }
  }

  // Fetch meals for a specific date and current user
  Future<List<Map<String, dynamic>>> getMealsByDate(DateTime date) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create start and end of day timestamps
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      developer.log('Fetching meals for user: $userId on ${date.toIso8601String()}', name: 'SupabaseService');

      final response = await client
          .from('meals')
          .select('*, photo_url')
          .eq('uid', userId)
          .gte('date', startOfDay.toIso8601String())
          .lte('date', endOfDay.toIso8601String())
          .order('created_at', ascending: true);

      developer.log('Fetched ${response.length} meals for date', name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to fetch meals by date: $e', name: 'SupabaseService');
      rethrow;
    }
  }

  // Fetch all meals for current user
  Future<List<Map<String, dynamic>>> getAllUserMeals() async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Fetching all meals for user: $userId', name: 'SupabaseService');

      final response = await client
          .from('meals')
          .select('*, photo_url')
          .eq('uid', userId)
          .order('date', ascending: false);

      developer.log('Fetched ${response.length} total meals', name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to fetch all user meals: $e', name: 'SupabaseService');
      rethrow;
    }
  }

  // Add a meal for current user
  Future<Map<String, dynamic>> addMeal(Map<String, dynamic> mealData) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add user ID to meal data
      final mealWithUser = {
        ...mealData,
        'uid': userId,
      };

      developer.log('Adding meal for user: $userId', name: 'SupabaseService');

      final response = await client
          .from('meals')
          .insert(mealWithUser)
          .select()
          .single();

      developer.log('Meal added successfully with ID: ${response['id']}', name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to add meal: $e', name: 'SupabaseService');
      rethrow;
    }
  }

  // Upload photo to Supabase storage
  Future<String?> uploadMealPhoto(String filePath, String fileName) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique file path for the user
      final storagePath = 'meals/$userId/$fileName';

      developer.log('Uploading photo to: $storagePath', name: 'SupabaseService');
      print('DEBUG: About to upload - File path: $filePath, exists: ${File(filePath).existsSync()}');
      print('DEBUG: User ID: $userId, Storage path: $storagePath');

      // Upload file to storage
      await client.storage
          .from('meal-photos')
          .upload(storagePath, File(filePath));

      // Get public URL
      final publicUrl = client.storage
          .from('meal-photos')
          .getPublicUrl(storagePath);

      developer.log('Photo uploaded successfully: $publicUrl', name: 'SupabaseService');
      return publicUrl;
    } catch (e) {
      developer.log('Failed to upload photo: $e', name: 'SupabaseService');
      print('DEBUG: Photo upload error details: $e');
      print('DEBUG: File path: $filePath');
      print('DEBUG: File exists: ${File(filePath).existsSync()}');
      final currentUserId = getCurrentUserId();
      print('DEBUG: User ID: $currentUserId');
      print('DEBUG: Storage path: meals/$currentUserId/$fileName');
      // Don't rethrow - photo upload failure should not prevent meal creation
      return null;
    }
  }

  // Update a meal for current user
  Future<Map<String, dynamic>> updateMeal(int mealId, Map<String, dynamic> mealData) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Updating meal $mealId for user: $userId', name: 'SupabaseService');

      final response = await client
          .from('meals')
          .update(mealData)
          .eq('id', mealId)
          .eq('uid', userId)
          .select()
          .single();

      developer.log('Meal updated successfully: ${response['id']}', name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to update meal: $e', name: 'SupabaseService');
      rethrow;
    }
  }

  // Delete a meal for current user
  Future<void> deleteMeal(int mealId) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Deleting meal $mealId for user: $userId', name: 'SupabaseService');

      // First get the meal to check if it has a photo
      final meal = await client
          .from('meals')
          .select('photo_url')
          .eq('id', mealId)
          .eq('uid', userId)
          .single();

      // Delete the meal from database
      await client
          .from('meals')
          .delete()
          .eq('id', mealId)
          .eq('uid', userId);

      // Delete the photo if it exists
      if (meal['photo_url'] != null) {
        await deleteMealPhoto(meal['photo_url']);
      }

      developer.log('Meal deleted successfully: $mealId', name: 'SupabaseService');
    } catch (e) {
      developer.log('Failed to delete meal: $e', name: 'SupabaseService');
      rethrow;
    }
  }

  // Delete meal photo from storage
  Future<void> deleteMealPhoto(String photoUrl) async {
    try {
      if (!isInitialized) return;

      // Extract path from URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3) {
        final storagePath = pathSegments.sublist(2).join('/');
        
        await client.storage
            .from('meal-photos')
            .remove([storagePath]);

        developer.log('Photo deleted from storage: $storagePath', name: 'SupabaseService');
      }
    } catch (e) {
      developer.log('Failed to delete photo: $e', name: 'SupabaseService');
      // Don't rethrow - photo deletion failure should not prevent other operations
    }
  }
}