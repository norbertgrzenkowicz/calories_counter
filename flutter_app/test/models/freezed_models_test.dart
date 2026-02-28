import 'package:flutter_test/flutter_test.dart';
import 'package:food_scanner/models/meal_freezed.dart';
import 'package:food_scanner/models/user_profile_freezed.dart';
import 'package:food_scanner/models/weight_history_freezed.dart';

void main() {
  group('Freezed Models', () {
    group('MealFreezed', () {
      test('should create instance with required fields', () {
        final meal = MealFreezed(
          name: 'Test Meal',
          calories: 500,
          proteins: 25.0,
          fats: 10.0,
          carbs: 60.0,
          date: DateTime.now(),
        );

        expect(meal.name, 'Test Meal');
        expect(meal.calories, 500);
        expect(meal.proteins, 25.0);
        expect(meal.hasCompleteNutrition, true);
      });

      test('should handle copyWith correctly', () {
        final originalMeal = MealFreezed(
          name: 'Original Meal',
          calories: 300,
          proteins: 15.0,
          fats: 5.0,
          carbs: 40.0,
          date: DateTime.now(),
        );

        final updatedMeal = originalMeal.copyWith(name: 'Updated Meal');

        expect(updatedMeal.name, 'Updated Meal');
        expect(updatedMeal.calories, 300); // Should remain unchanged
        expect(
            originalMeal.name, 'Original Meal'); // Original should be immutable
      });

      test('should serialize to/from JSON correctly', () {
        final meal = MealFreezed(
          name: 'JSON Meal',
          calories: 400,
          proteins: 20.0,
          fats: 8.0,
          carbs: 50.0,
          date: DateTime.parse('2024-01-01T12:00:00Z'),
        );

        final json = meal.toJson();
        final restored = MealFreezed.fromJson(json);

        expect(restored.name, meal.name);
        expect(restored.calories, meal.calories);
        expect(restored.date, meal.date);
      });
    });

    group('UserProfileFreezed', () {
      test('should calculate BMI correctly', () {
        const profile = UserProfileFreezed(
          heightCm: 175.0,
          currentWeightKg: 70.0,
          dateOfBirth: null,
        );

        const expectedBMI = 70.0 / (1.75 * 1.75);
        expect(profile.bmi, closeTo(expectedBMI, 0.01));
      });

      test('should calculate age correctly', () {
        final birthDate =
            DateTime.now().subtract(const Duration(days: 365 * 25));
        final profile = UserProfileFreezed(
          heightCm: 175.0,
          currentWeightKg: 70.0,
          dateOfBirth: birthDate,
        );

        expect(profile.age, 24);
      });

      test('should handle equality correctly', () {
        const profile1 = UserProfileFreezed(
          heightCm: 175.0,
          currentWeightKg: 70.0,
          fullName: 'John Doe',
        );

        const profile2 = UserProfileFreezed(
          heightCm: 175.0,
          currentWeightKg: 70.0,
          fullName: 'John Doe',
        );

        expect(profile1, equals(profile2));
        expect(profile1.hashCode, equals(profile2.hashCode));
      });
    });

    group('WeightHistoryFreezed', () {
      test('should create instance with defaults', () {
        final entry = WeightHistoryFreezed(
          weightKg: 75.5,
          recordedDate: DateTime.now(),
        );

        expect(entry.weightKg, 75.5);
        expect(entry.measurementTime, 'morning');
        expect(entry.isInitialPhase, false);
        expect(entry.phase, 'steady_state');
      });

      test('should format weight change description correctly', () {
        final entryPositive = WeightHistoryFreezed(
          weightKg: 75.0,
          recordedDate: DateTime.now(),
          weightChangeKg: 1.5,
        );

        final entryNegative = WeightHistoryFreezed(
          weightKg: 73.0,
          recordedDate: DateTime.now(),
          weightChangeKg: -2.0,
        );

        final entryNoChange = WeightHistoryFreezed(
          weightKg: 74.0,
          recordedDate: DateTime.now(),
          weightChangeKg: 0.0,
        );

        expect(entryPositive.weightChangeDescription, '↑ +1.5kg');
        expect(entryNegative.weightChangeDescription, '↓ -2.0kg');
        expect(entryNoChange.weightChangeDescription, 'No change');
      });

      test('should determine color category correctly', () {
        final entryPositive = WeightHistoryFreezed(
          weightKg: 75.0,
          recordedDate: DateTime.now(),
          weightChangeKg: 1.0,
        );

        final entryNegative = WeightHistoryFreezed(
          weightKg: 73.0,
          recordedDate: DateTime.now(),
          weightChangeKg: -1.0,
        );

        expect(entryPositive.weightChangeColor, 'neutral');
        expect(entryNegative.weightChangeColor, 'neutral');
      });
    });
  });
}
