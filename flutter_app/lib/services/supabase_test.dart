import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class SupabaseTest {
  static Future<void> runConnectionTest() async {
    try {
      print('🚀 Starting Supabase connection test...');
      
      final supabaseService = SupabaseService();
      
      print('📝 Step 1: Initializing Supabase...');
      await supabaseService.initialize();
      
      print('📝 Step 2: Testing connection...');
      final connectionResult = await supabaseService.testConnection();
      
      print('📝 Step 3: Getting status...');
      final status = await supabaseService.getStatus();
      
      print('📝 Step 4: Running simple query test...');
      await supabaseService.executeSimpleQuery('users', limit: 5);
      
      print('🎉 Connection test completed!');
      print('📊 Final Results:');
      print('   - Connection: ${connectionResult ? "✅ Success" : "❌ Failed"}');
      print('   - Status: ${status?['status'] ?? 'unknown'}');
      
    } catch (e) {
      print('💥 Test failed with error: $e');
      if (kDebugMode) {
        print('Stack trace: ${StackTrace.current}');
      }
    }
  }
}