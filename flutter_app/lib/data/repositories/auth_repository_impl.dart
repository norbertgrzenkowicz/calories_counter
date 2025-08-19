import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/result.dart';
import '../../services/supabase_service.dart';
import '../../core/app_logger.dart';

/// Implementation of AuthRepository using Supabase
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepositoryImpl(this._supabaseService);

  @override
  Future<Result<String>> signIn(String email, String password) async {
    try {
      AppLogger.info('Attempting user sign in');
      
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        AppLogger.info('User signed in successfully');
        return Result.success(userId);
      } else {
        AppLogger.warning('Sign in failed - no user returned');
        return const Result.failure(
          AppError.authentication('Invalid credentials'),
        );
      }
    } on AuthException catch (e) {
      AppLogger.error('Authentication failed', e);
      
      // Map Supabase auth errors to our error types
      if (e.statusCode == '400') {
        return Result.failure(
          AppError.validation('Invalid email or password format'),
        );
      } else if (e.statusCode == '422') {
        return Result.failure(
          AppError.authentication('Invalid credentials'),
        );
      } else {
        return Result.failure(
          AppError.authentication(e.message),
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error during sign in', e);
      return Result.failure(
        AppError.unknown('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<String>> signUp(String email, String password) async {
    try {
      AppLogger.info('Attempting user registration');
      
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        AppLogger.info('User registered successfully');
        return Result.success(userId);
      } else {
        AppLogger.warning('Registration failed - no user returned');
        return const Result.failure(
          AppError.unknown('Registration failed - please try again'),
        );
      }
    } on AuthException catch (e) {
      AppLogger.error('Registration failed', e);
      
      // Map Supabase auth errors to our error types
      if (e.statusCode == '400') {
        return Result.failure(
          AppError.validation('Invalid email or password format'),
        );
      } else if (e.statusCode == '422') {
        if (e.message.contains('already')) {
          return Result.failure(
            AppError.conflict('An account with this email already exists'),
          );
        }
        return Result.failure(
          AppError.validation(e.message),
        );
      } else {
        return Result.failure(
          AppError.authentication(e.message),
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error during registration', e);
      return Result.failure(
        AppError.unknown('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      AppLogger.info('Attempting user sign out');
      await _supabaseService.signOut();
      AppLogger.info('User signed out successfully');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      return Result.failure(
        AppError.unknown('Sign out failed: ${e.toString()}'),
      );
    }
  }

  @override
  String? getCurrentUserId() {
    return _supabaseService.getCurrentUserId();
  }

  @override
  bool get isAuthenticated {
    return _supabaseService.getCurrentUserId() != null;
  }

  @override
  Stream<String?> get authStateStream {
    return _supabaseService.client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user?.id;
    });
  }

  @override
  Future<Result<void>> refreshToken() async {
    try {
      AppLogger.debug('Refreshing authentication token');
      
      await _supabaseService.client.auth.refreshSession();
      
      if (_supabaseService.getCurrentUserId() != null) {
        AppLogger.info('Token refreshed successfully');
        return const Result.success(null);
      } else {
        AppLogger.warning('Token refresh failed - no user after refresh');
        return const Result.failure(
          AppError.authentication('Token refresh failed'),
        );
      }
    } on AuthException catch (e) {
      AppLogger.error('Token refresh failed', e);
      return Result.failure(
        AppError.authentication('Token refresh failed: ${e.message}'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error during token refresh', e);
      return Result.failure(
        AppError.unknown('Token refresh failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      AppLogger.info('Attempting account deletion');
      
      // Note: Supabase doesn't have a built-in deleteUser method in the client
      // This would typically require an admin API call or edge function
      // For now, we'll sign out the user and let them contact support
      await signOut();
      
      AppLogger.warning('Account deletion requires manual process');
      return const Result.failure(
        AppError.server('Account deletion requires contacting support'),
      );
    } catch (e) {
      AppLogger.error('Account deletion failed', e);
      return Result.failure(
        AppError.unknown('Account deletion failed: ${e.toString()}'),
      );
    }
  }
}