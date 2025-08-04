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
        throw Exception('Supabase environment variables not configured. Use --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
      }

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
      developer.log('Failed to initialize Supabase: $e', name: 'SupabaseService');
      rethrow;
    }
  }

  Future<bool> testConnection() async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized');
      }

      print('🔄 Testing Supabase connection...');
      developer.log('Testing Supabase connection', name: 'SupabaseService');

      final response = await client
          .from('test')
          .select('*')
          .limit(1);

      print('✅ Connection test successful');
      print('📊 Query result: $response');
      developer.log('Connection test successful. Result: $response', name: 'SupabaseService');
      
      return true;
    } catch (e) {
      print('❌ Connection test failed: $e');
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
      
      final response = await client.rpc('version');
      
      final status = {
        'status': 'connected',
        'initialized': true,
        'url': supabaseUrl,
        'version': response,
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