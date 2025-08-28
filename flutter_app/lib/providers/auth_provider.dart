import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/entities/result.dart';
import '../core/app_logger.dart';
import 'repository_providers.dart';

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
    final authRepository = ref.read(authRepositoryProvider);
    final currentUserId = authRepository.getCurrentUserId();

    return AuthState(
      userId: currentUserId,
      isAuthenticated: currentUserId != null,
    );
  }

  /// Sign in user with email and password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signIn(email, password);

    result.when(
      success: (userId) {
        state = state.copyWith(
          userId: userId,
          isAuthenticated: true,
          isLoading: false,
        );
        AppLogger.info('User signed in successfully');
      },
      failure: (error) {
        AppLogger.error('Sign in failed: ${error.toString()}');
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(error),
        );
      },
    );
  }

  /// Sign up new user with email and password
  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signUp(email, password);

    result.when(
      success: (userId) {
        state = state.copyWith(
          userId: userId,
          isAuthenticated: true,
          isLoading: false,
        );
        AppLogger.info('User signed up successfully');
      },
      failure: (error) {
        AppLogger.error('Sign up failed: ${error.toString()}');
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(error),
        );
      },
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signOut();

    result.when(
      success: (_) {
        state = const AuthState(isAuthenticated: false);
        AppLogger.info('User signed out successfully');
      },
      failure: (error) {
        AppLogger.error('Sign out failed: ${error.toString()}');
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(error),
        );
      },
    );
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Check and refresh authentication state
  void refreshAuthState() {
    final authRepository = ref.read(authRepositoryProvider);
    final currentUserId = authRepository.getCurrentUserId();

    state = state.copyWith(
      userId: currentUserId,
      isAuthenticated: currentUserId != null,
    );
  }

  /// Convert AppError to user-friendly error message
  String _getErrorMessage(AppError error) {
    return error.when(
      network: (message, statusCode) => 'Network error: $message',
      authentication: (message) => message,
      validation: (message, fieldErrors) => message,
      notFound: (message) => message,
      conflict: (message) => message,
      server: (message, statusCode) => 'Server error: $message',
      unknown: (message, exception) => message,
      staleData: (message) => message,
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
