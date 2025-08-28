import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../lib/domain/repositories/auth_repository.dart';
import '../../lib/domain/repositories/meal_repository.dart';
import '../../lib/domain/repositories/profile_repository.dart';
import '../../lib/services/supabase_service.dart';
import '../../lib/services/profile_service.dart';

/// Mock classes for testing
class MockAuthRepository extends Mock implements AuthRepository {}

class MockMealRepository extends Mock implements MealRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockSupabaseService extends Mock implements SupabaseService {}

class MockProfileService extends Mock implements ProfileService {}

/// Test helpers for common test setup
class TestHelpers {
  static void setUpMocks() {
    registerFallbackValue(DateTime.now());
  }
}
