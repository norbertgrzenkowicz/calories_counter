import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/meal_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/meal_repository_impl.dart';
import '../data/repositories/profile_repository_impl.dart';
import 'service_providers.dart';

/// Provider for AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return AuthRepositoryImpl(supabaseService);
});

/// Provider for MealRepository implementation
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return MealRepositoryImpl(supabaseService);
});

/// Provider for ProfileRepository implementation
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final profileService = ref.read(profileServiceProvider);
  return ProfileRepositoryImpl(profileService);
});