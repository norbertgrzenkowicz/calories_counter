import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/supabase_service.dart';
import '../core/app_logger.dart';
import 'service_providers.dart';

part 'auth_provider.g.dart';

/// Authentication state representation
class AuthState {
  final String? userId;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.userId,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    String? userId,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Authentication state notifier using Riverpod
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Initialize with current user if available
    final supabaseService = ref.read(supabaseServiceProvider);
    final currentUserId = supabaseService.getCurrentUserId();
    
    return AuthState(
      userId: currentUserId,
      isAuthenticated: currentUserId != null,
    );
  }

  /// Sign in user with email and password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      // Perform authentication through Supabase
      await supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      final userId = supabaseService.getCurrentUserId();
      
      if (userId != null) {
        state = state.copyWith(
          userId: userId,
          isAuthenticated: true,
          isLoading: false,
        );
        AppLogger.info('User signed in successfully');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Authentication failed - no user ID returned',
        );
      }
    } catch (e) {
      AppLogger.error('Sign in failed', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign up new user with email and password
  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      await supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      
      final userId = supabaseService.getCurrentUserId();
      
      if (userId != null) {
        state = state.copyWith(
          userId: userId,
          isAuthenticated: true,
          isLoading: false,
        );
        AppLogger.info('User signed up successfully');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration completed - please check your email for verification',
        );
      }
    } catch (e) {
      AppLogger.error('Sign up failed', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.signOut();
      
      state = const AuthState(isAuthenticated: false);
      AppLogger.info('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Check and refresh authentication state
  void refreshAuthState() {
    final supabaseService = ref.read(supabaseServiceProvider);
    final currentUserId = supabaseService.getCurrentUserId();
    
    state = state.copyWith(
      userId: currentUserId,
      isAuthenticated: currentUserId != null,
    );
  }
}

/// Provider for checking if user is authenticated
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
}

/// Provider for current user ID
@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userId;
}