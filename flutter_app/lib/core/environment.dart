/// Environment configuration management
/// 
/// Provides secure access to environment variables and validates
/// that all required configuration is present at runtime.
abstract class Environment {
  /// Supabase project URL
  static String get supabaseUrl => 
    const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  
  /// Supabase anonymous key
  static String get supabaseAnonKey => 
    const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  
  /// Validates that all required environment variables are configured
  static void validate() {
    final missingVars = <String>[];
    
    if (supabaseUrl.isEmpty) {
      missingVars.add('SUPABASE_URL');
    }
    
    if (supabaseAnonKey.isEmpty) {
      missingVars.add('SUPABASE_ANON_KEY');
    }
    
    if (missingVars.isNotEmpty) {
      throw Exception(
        'Missing required environment variables: ${missingVars.join(', ')}\n'
        'Please configure these in dart_defines.json or as build arguments.',
      );
    }
  }
  
  /// Checks if we're running in development mode
  static bool get isDevelopment => 
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development') == 'development';
  
  /// Checks if we're running in production mode  
  static bool get isProduction =>
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development') == 'production';
}