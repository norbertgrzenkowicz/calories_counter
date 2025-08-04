import 'dart:developer' as developer;
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
        print('❌ Supabase environment variables not configured');
        print('Environment check - URL: ${supabaseUrl.isEmpty ? "MISSING" : "OK"}');
        print('Environment check - ANON_KEY: ${supabaseAnonKey.isEmpty ? "MISSING" : "OK"}');
        throw Exception('Supabase environment variables not configured. Use --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
      }

      print('🔧 Initializing Supabase connection...');
      print('🔗 URL: ${supabaseUrl.substring(0, 30)}...');
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      print('✅ Supabase initialized successfully');
      print('🔗 Connected to: ${supabaseUrl.substring(0, 20)}...');
      developer.log('Supabase client initialized', name: 'SupabaseService');
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('network')) {
        print('Network-related error detected');
      }
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
}