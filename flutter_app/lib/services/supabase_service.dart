import 'dart:developer' as developer;
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_logger.dart';
import '../core/environment.dart';
import 'openfoodfacts_service.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase client not initialized. Call initialize() first.');
    }
    return _client!;
  }

  bool get isInitialized => _client != null;

  Future<void> initialize() async {
    try {
      Environment.validate();

      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      AppLogger.info('Supabase client initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Supabase', e);
      rethrow;
    }
  }

  Future<bool> testConnection() async {
    try {
      if (!isInitialized) {
        AppLogger.error('Cannot test connection: Supabase not initialized');
        throw Exception('Supabase not initialized');
      }

      AppLogger.debug('Testing Supabase connection...');

      // Test basic connection with a simple query
      AppLogger.debug('Checking database schema...');
      try {
        final response = await client.from('users').select('*').limit(1);

        AppLogger.info('Connection test successful');
        AppLogger.debug('Users table exists and is accessible');

        return true;
      } catch (tableError) {
        AppLogger.warning('Users table query failed: ${tableError.toString()}');

        // Try to check if we can access any table
        try {
          await client.rpc('version');
          AppLogger.info('Basic Supabase connection works');
          AppLogger.warning('But users table is not accessible');
          return false;
        } catch (basicError) {
          AppLogger.error('Basic connection also failed', basicError);
          throw basicError;
        }
      }
    } catch (e) {
      AppLogger.error('Connection test failed', e);
      if (e.toString().contains('404')) {
        AppLogger.info(
            'Table not found - you may need to create a public.users table');
        AppLogger.info('Or configure RLS policies for the users table');
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        AppLogger.info(
            'Authentication/authorization error - check API keys and RLS policies');
      } else if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        AppLogger.info('Network connectivity issue detected');
      }
      developer.log('Connection test failed: $e', name: 'SupabaseService');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> executeSimpleQuery(String table,
      {int limit = 10}) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      AppLogger.debug('Executing query on table: $table');
      developer.log('Executing query on table: $table',
          name: 'SupabaseService');

      final response = await client.from(table).select('*').limit(limit);

      AppLogger.info('Query executed successfully');
      AppLogger.debug('Result count: ${response.length}');
      developer.log(
          'Query successful. Count: ${response.length}, Data: $response',
          name: 'SupabaseService');

      return response;
    } catch (e) {
      AppLogger.error('Query failed', e);
      developer.log('Query failed: $e', name: 'SupabaseService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStatus() async {
    try {
      if (!isInitialized) {
        return {
          'status': 'not_initialized',
          'message': 'Supabase not initialized'
        };
      }

      AppLogger.debug('Getting Supabase status...');

      // Simple status check by querying users table instead of version function
      await client.from('users').select('count').limit(1);

      final status = {
        'status': 'connected',
        'initialized': true,
        'url': Environment.supabaseUrl,
        'message': 'Successfully connected to Supabase',
      };

      AppLogger.info('Status check successful');
      developer.log('Status check successful: $status',
          name: 'SupabaseService');

      return status;
    } catch (e) {
      final errorStatus = {
        'status': 'error',
        'initialized': isInitialized,
        'error': e.toString(),
      };

      AppLogger.error('Status check failed', e);
      developer.log('Status check failed: $e', name: 'SupabaseService');

      return errorStatus;
    }
  }

  Future<void> signOut() async {
    try {
      if (!isInitialized) {
        developer.log('Cannot sign out: Supabase not initialized',
            name: 'SupabaseService');
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

      developer.log(
          'Fetching meals for user: $userId from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
          name: 'SupabaseService');

      final response = await client
          .from('meals')
          .select('*, photo_url')
          .eq('uid', userId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: true);

      developer.log('Fetched ${response.length} meals',
          name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to fetch meals by date range: $e',
          name: 'SupabaseService');
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

      developer.log(
          'Fetching meals for user: $userId on ${date.toIso8601String()}',
          name: 'SupabaseService');

      final response = await client
          .from('meals')
          .select('*, photo_url')
          .eq('uid', userId)
          .gte('date', startOfDay.toIso8601String())
          .lte('date', endOfDay.toIso8601String())
          .order('created_at', ascending: true);

      developer.log('Fetched ${response.length} meals for date',
          name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to fetch meals by date: $e',
          name: 'SupabaseService');
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

      developer.log('Fetching all meals for user: $userId',
          name: 'SupabaseService');

      final response = await client
          .from('meals')
          .select('*, photo_url')
          .eq('uid', userId)
          .order('date', ascending: false);

      developer.log('Fetched ${response.length} total meals',
          name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to fetch all user meals: $e',
          name: 'SupabaseService');
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

      final response =
          await client.from('meals').insert(mealWithUser).select().single();

      developer.log('Meal added successfully with ID: ${response['id']}',
          name: 'SupabaseService');
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

      developer.log('Uploading photo to: $storagePath',
          name: 'SupabaseService');
      AppLogger.debug('About to upload photo');
      AppLogger.debug('File exists: ${File(filePath).existsSync()}');

      // Upload file to storage
      await client.storage
          .from('meal-photos')
          .upload(storagePath, File(filePath));

      // Try to get public URL first, fall back to signed URL if needed
      try {
        final publicUrl =
            client.storage.from('meal-photos').getPublicUrl(storagePath);

        developer.log('Photo uploaded successfully: $publicUrl',
            name: 'SupabaseService');

        return publicUrl;
      } catch (publicUrlError) {
        // Fall back to signed URL with shorter expiry
        developer.log('Public URL failed, trying signed URL: $publicUrlError',
            name: 'SupabaseService');

        final signedUrl = await client.storage
            .from('meal-photos')
            .createSignedUrl(storagePath, 1800); // 30 minutes

        developer.log('Photo uploaded with signed URL: $signedUrl',
            name: 'SupabaseService');

        return signedUrl;
      }
    } catch (e) {
      developer.log('Failed to upload photo: $e', name: 'SupabaseService');
      AppLogger.error('Photo upload failed', e);
      AppLogger.debug('File exists: ${File(filePath).existsSync()}');
      // Note: User ID and file paths not logged for security
      // Don't rethrow - photo upload failure should not prevent meal creation
      return null;
    }
  }

  // Update a meal for current user
  Future<Map<String, dynamic>> updateMeal(
      int mealId, Map<String, dynamic> mealData) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Updating meal $mealId for user: $userId',
          name: 'SupabaseService');

      final response = await client
          .from('meals')
          .update(mealData)
          .eq('id', mealId)
          .eq('uid', userId)
          .select()
          .single();

      developer.log('Meal updated successfully: ${response['id']}',
          name: 'SupabaseService');
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

      developer.log('Deleting meal $mealId for user: $userId',
          name: 'SupabaseService');

      // First get the meal to check if it has a photo
      final meal = await client
          .from('meals')
          .select('photo_url')
          .eq('id', mealId)
          .eq('uid', userId)
          .single();

      // Delete the meal from database
      await client.from('meals').delete().eq('id', mealId).eq('uid', userId);

      // Delete the photo if it exists
      if (meal['photo_url'] != null) {
        await deleteMealPhoto(meal['photo_url']);
      }

      developer.log('Meal deleted successfully: $mealId',
          name: 'SupabaseService');
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

        await client.storage.from('meal-photos').remove([storagePath]);

        developer.log('Photo deleted from storage: $storagePath',
            name: 'SupabaseService');
      }
    } catch (e) {
      developer.log('Failed to delete photo: $e', name: 'SupabaseService');
      // Don't rethrow - photo deletion failure should not prevent other operations
    }
  }

  // ========== CACHED PRODUCTS METHODS ==========

  /// Cache a product from OpenFoodFacts for faster future access
  Future<void> cacheProduct(ProductNutrition product) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      // Products can be cached globally (user_id = null) or per user

      developer.log('Caching product: ${product.barcode}',
          name: 'SupabaseService');

      // Use upsert to handle conflicts if product already exists
      await client.from('cached_products').upsert({
        ...product.toSupabase(),
        'user_id': userId, // Cache per user for now
      });

      developer.log('Product cached successfully: ${product.barcode}',
          name: 'SupabaseService');
    } catch (e) {
      developer.log('Failed to cache product: $e', name: 'SupabaseService');
      // Don't rethrow - caching failure should not break the main flow
    }
  }

  /// Get a cached product by barcode
  Future<ProductNutrition?> getCachedProduct(String barcode) async {
    try {
      if (!isInitialized) {
        return null;
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        return null;
      }

      developer.log('Looking up cached product: $barcode',
          name: 'SupabaseService');

      // Look for user-specific or global cached products that are not expired
      final response = await client
          .from('cached_products')
          .select('*')
          .eq('barcode', barcode)
          .or('user_id.eq.$userId,user_id.is.null')
          .gte(
              'cached_at',
              DateTime.now()
                  .subtract(const Duration(days: 7))
                  .toIso8601String())
          .order('user_id', ascending: false) // Prefer user-specific cache
          .limit(1);

      if (response.isNotEmpty) {
        developer.log('Found cached product: $barcode',
            name: 'SupabaseService');
        return ProductNutrition.fromSupabase(response.first);
      }

      developer.log('No cached product found for: $barcode',
          name: 'SupabaseService');
      return null;
    } catch (e) {
      developer.log('Failed to get cached product: $e',
          name: 'SupabaseService');
      return null; // Return null on error - will fallback to API
    }
  }

  /// Clean up old cached products (older than 7 days)
  Future<void> cleanupOldCachedProducts() async {
    try {
      if (!isInitialized) {
        return;
      }

      developer.log('Cleaning up old cached products', name: 'SupabaseService');

      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

      await client
          .from('cached_products')
          .delete()
          .lt('cached_at', cutoffDate.toIso8601String());

      developer.log('Old cached products cleaned up', name: 'SupabaseService');
    } catch (e) {
      developer.log('Failed to cleanup cached products: $e',
          name: 'SupabaseService');
      // Don't rethrow - cleanup failure should not break the app
    }
  }

  /// Get statistics about cached products
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      if (!isInitialized) {
        return {'error': 'Supabase not initialized'};
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        return {'error': 'User not authenticated'};
      }

      // Count total cached products for current user
      final totalResponse = await client
          .from('cached_products')
          .select()
          .eq('user_id', userId)
          .count(CountOption.exact);

      // Count fresh cached products (less than 7 days old)
      final freshResponse = await client
          .from('cached_products')
          .select()
          .eq('user_id', userId)
          .gte(
              'cached_at',
              DateTime.now()
                  .subtract(const Duration(days: 7))
                  .toIso8601String())
          .count(CountOption.exact);

      return {
        'total_cached': totalResponse.count ?? 0,
        'fresh_cached': freshResponse.count ?? 0,
        'cache_hit_potential':
            '${((freshResponse.count ?? 0) * 100 / (totalResponse.count ?? 1)).toStringAsFixed(1)}%',
      };
    } catch (e) {
      developer.log('Failed to get cache stats: $e', name: 'SupabaseService');
      return {'error': e.toString()};
    }
  }

  /// Combined method to get product with caching logic
  Future<ProductNutrition?> getProductWithCache(String barcode) async {
    try {
      // First try to get from cache
      final cachedProduct = await getCachedProduct(barcode);
      if (cachedProduct != null) {
        developer.log('Using cached product: $barcode',
            name: 'SupabaseService');
        return cachedProduct;
      }

      // If not in cache, fetch from OpenFoodFacts
      developer.log('Cache miss, fetching from OpenFoodFacts: $barcode',
          name: 'SupabaseService');
      final product = await OpenFoodFactsService.getProductByBarcode(barcode);

      // If found, cache it for future use
      if (product != null) {
        await cacheProduct(product);
        return product;
      }

      return null;
    } catch (e) {
      developer.log('Failed to get product with cache: $e',
          name: 'SupabaseService');
      return null;
    }
  }

  // ========== CHAT MESSAGES METHODS ==========

  /// Get chat messages for a specific date and current user
  Future<List<Map<String, dynamic>>> getChatMessagesByDate(
      DateTime date) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Format date as YYYY-MM-DD for DATE comparison
      final dateStr = date.toIso8601String().split('T')[0];

      developer.log('Fetching chat messages for user: $userId on date: $dateStr',
          name: 'SupabaseService');

      final response = await client
          .from('chat_messages')
          .select('*')
          .eq('uid', userId)
          .eq('date', dateStr)
          .order('timestamp', ascending: true);

      developer.log('Fetched ${response.length} chat messages for date',
          name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to fetch chat messages by date: $e',
          name: 'SupabaseService');
      rethrow;
    }
  }

  /// Save a new chat message to database
  Future<Map<String, dynamic>> saveChatMessage(
      Map<String, dynamic> messageData) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Saving chat message: ${messageData['message_id']}',
          name: 'SupabaseService');

      final response = await client
          .from('chat_messages')
          .insert(messageData)
          .select()
          .single();

      developer.log('Chat message saved successfully', name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to save chat message: $e',
          name: 'SupabaseService');
      rethrow;
    }
  }

  /// Update an existing chat message
  Future<Map<String, dynamic>> updateChatMessage(
      String messageId, Map<String, dynamic> updates) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Updating chat message: $messageId',
          name: 'SupabaseService');

      final response = await client
          .from('chat_messages')
          .update(updates)
          .eq('message_id', messageId)
          .eq('uid', userId)
          .select()
          .single();

      developer.log('Chat message updated successfully',
          name: 'SupabaseService');
      return response;
    } catch (e) {
      developer.log('Failed to update chat message: $e',
          name: 'SupabaseService');
      rethrow;
    }
  }

  /// Delete a chat message
  Future<void> deleteChatMessage(String messageId) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      developer.log('Deleting chat message: $messageId',
          name: 'SupabaseService');

      await client
          .from('chat_messages')
          .delete()
          .eq('message_id', messageId)
          .eq('uid', userId);

      developer.log('Chat message deleted successfully',
          name: 'SupabaseService');
    } catch (e) {
      developer.log('Failed to delete chat message: $e',
          name: 'SupabaseService');
      rethrow;
    }
  }

  /// Upload chat media (image or audio) to Supabase Storage
  /// Returns the public/signed URL of the uploaded file
  Future<String?> uploadChatMedia(
      File file, String messageId, String mediaType) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get file extension
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last;

      // Create storage path: chat/{uid}/{date}/{messageId}.{ext}
      final now = DateTime.now();
      final dateStr = now.toIso8601String().split('T')[0]; // YYYY-MM-DD
      final storagePath =
          'chat/$userId/$dateStr/$messageId.$extension';

      developer.log('Uploading chat $mediaType to: $storagePath',
          name: 'SupabaseService');
      AppLogger.debug('Uploading chat media: $storagePath');
      AppLogger.debug('File exists: ${file.existsSync()}');

      // Upload file to storage (reusing meal-photos bucket)
      await client.storage.from('meal-photos').upload(storagePath, file);

      // Try to get public URL first, fall back to signed URL if needed
      try {
        final publicUrl =
            client.storage.from('meal-photos').getPublicUrl(storagePath);

        developer.log('Chat media uploaded successfully: $publicUrl',
            name: 'SupabaseService');

        return publicUrl;
      } catch (publicUrlError) {
        // Fall back to signed URL (24 hours validity)
        developer.log('Public URL failed, trying signed URL: $publicUrlError',
            name: 'SupabaseService');

        final signedUrl = await client.storage
            .from('meal-photos')
            .createSignedUrl(storagePath, 86400); // 24 hours

        developer.log('Chat media uploaded with signed URL: $signedUrl',
            name: 'SupabaseService');

        return signedUrl;
      }
    } catch (e) {
      developer.log('Failed to upload chat media: $e',
          name: 'SupabaseService');
      AppLogger.error('Chat media upload failed', e);
      // Don't rethrow - media upload failure should not prevent message creation
      return null;
    }
  }

  /// Delete chat media from storage
  Future<void> deleteChatMedia(String mediaUrl) async {
    try {
      if (!isInitialized) return;

      // Extract path from URL
      final uri = Uri.parse(mediaUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3) {
        final storagePath = pathSegments.sublist(2).join('/');

        await client.storage.from('meal-photos').remove([storagePath]);

        developer.log('Chat media deleted from storage: $storagePath',
            name: 'SupabaseService');
      }
    } catch (e) {
      developer.log('Failed to delete chat media: $e',
          name: 'SupabaseService');
      // Don't rethrow - media deletion failure should not prevent other operations
    }
  }
}
