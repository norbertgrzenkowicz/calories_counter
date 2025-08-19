import '../entities/result.dart';

/// Abstract interface for authentication operations
/// 
/// This interface defines all authentication-related operations that the app
/// needs. Implementations should handle the specific details of authentication
/// providers (Supabase, Firebase Auth, etc.).
abstract class AuthRepository {
  /// Sign in user with email and password
  /// 
  /// Returns [Result.success] with user ID on successful login,
  /// or [Result.failure] with appropriate error.
  Future<Result<String>> signIn(String email, String password);
  
  /// Register new user with email and password
  /// 
  /// Returns [Result.success] with user ID on successful registration,
  /// or [Result.failure] with appropriate error.
  Future<Result<String>> signUp(String email, String password);
  
  /// Sign out current user
  /// 
  /// Returns [Result.success] with void on successful sign out,
  /// or [Result.failure] with appropriate error.
  Future<Result<void>> signOut();
  
  /// Get current authenticated user ID
  /// 
  /// Returns user ID if authenticated, null otherwise.
  String? getCurrentUserId();
  
  /// Check if user is currently authenticated
  /// 
  /// Returns true if user has valid authentication session.
  bool get isAuthenticated;
  
  /// Stream of authentication state changes
  /// 
  /// Emits user ID when authenticated, null when not authenticated.
  Stream<String?> get authStateStream;
  
  /// Refresh current authentication token
  /// 
  /// Returns [Result.success] if token refresh succeeds,
  /// or [Result.failure] if refresh fails.
  Future<Result<void>> refreshToken();
  
  /// Delete user account and all associated data
  /// 
  /// Returns [Result.success] on successful account deletion,
  /// or [Result.failure] with appropriate error.
  Future<Result<void>> deleteAccount();
}