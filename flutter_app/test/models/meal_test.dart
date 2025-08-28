import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/meal.dart';

void main() {
  group('Meal Model', () {
    test('creates meal with required fields', () {
      // Arrange & Act
      final meal = Meal(
        name: 'Test Meal',
        calories: 300,
        proteins: 20.0,
        fats: 10.0,
        carbs: 30.0,
      );

      // Assert
      expect(meal.name, equals('Test Meal'));
      expect(meal.calories, equals(300));
      expect(meal.proteins, equals(20.0));
      expect(meal.fats, equals(10.0));
      expect(meal.carbs, equals(30.0));
      expect(meal.id, isNull);
      expect(meal.uid, isNull);
      expect(meal.photoUrl, isNull);
      expect(meal.date, isA<DateTime>());
      expect(meal.createdAt, isNull);
    });

    test('copyWith creates new instance with updated fields', () {
      // Arrange
      final originalMeal = Meal(
        id: 1,
        name: 'Original Meal',
        calories: 300,
        proteins: 20.0,
        fats: 10.0,
        carbs: 30.0,
      );

      // Act
      final updatedMeal = originalMeal.copyWith(
        name: 'Updated Meal',
        calories: 400,
      );

      // Assert
      expect(updatedMeal.id, equals(1));
      expect(updatedMeal.name, equals('Updated Meal'));
      expect(updatedMeal.calories, equals(400));
      expect(updatedMeal.proteins, equals(20.0));
      expect(updatedMeal.fats, equals(10.0));
      expect(updatedMeal.carbs, equals(30.0));

      // Original should remain unchanged
      expect(originalMeal.name, equals('Original Meal'));
      expect(originalMeal.calories, equals(300));
    });

    group('fromSupabase', () {
      test('creates meal from Supabase data', () {
        // Arrange
        final supabaseData = {
          'id': 1,
          'name': 'Supabase Meal',
          'uid': 'user-123',
          'calories': 350,
          'proteins': 25.5,
          'fats': 12.3,
          'carbs': 35.7,
          'photo_url': 'https://example.com/photo.jpg',
          'date': '2024-01-15',
          'created_at': '2024-01-15T10:00:00Z',
        };

        // Act
        final meal = Meal.fromSupabase(supabaseData);

        // Assert
        expect(meal.id, equals(1));
        expect(meal.name, equals('Supabase Meal'));
        expect(meal.uid, equals('user-123'));
        expect(meal.calories, equals(350));
        expect(meal.proteins, equals(25.5));
        expect(meal.fats, equals(12.3));
        expect(meal.carbs, equals(35.7));
        expect(meal.photoUrl, equals('https://example.com/photo.jpg'));
        expect(meal.date.year, equals(2024));
        expect(meal.date.month, equals(1));
        expect(meal.date.day, equals(15));
        expect(meal.createdAt, isA<DateTime>());
      });

      test('handles null and invalid values safely', () {
        // Arrange
        final supabaseData = {
          'id': null,
          'name': null,
          'uid': null,
          'calories': null,
          'proteins': 'invalid',
          'fats': double.infinity,
          'carbs': double.nan,
          'photo_url': null,
          'date': 'invalid-date',
          'created_at': null,
        };

        // Act
        final meal = Meal.fromSupabase(supabaseData);

        // Assert
        expect(meal.id, isNull);
        expect(meal.name, equals(''));
        expect(meal.uid, isNull);
        expect(meal.calories, equals(0));
        expect(meal.proteins, equals(0.0));
        expect(meal.fats, equals(0.0));
        expect(meal.carbs, equals(0.0));
        expect(meal.photoUrl, isNull);
        expect(meal.date, isA<DateTime>());
        expect(meal.createdAt, isNull);
      });
    });

    group('toSupabase', () {
      test('converts meal to Supabase format', () {
        // Arrange
        final testDate = DateTime(2024, 1, 15, 10, 30);
        final meal = Meal(
          name: 'Test Meal',
          uid: 'user-123',
          calories: 300,
          proteins: 20.0,
          fats: 10.0,
          carbs: 30.0,
          photoUrl: 'https://example.com/photo.jpg',
          date: testDate,
        );

        // Act
        final supabaseData = meal.toSupabase();

        // Assert
        expect(supabaseData['name'], equals('Test Meal'));
        expect(supabaseData['uid'], equals('user-123'));
        expect(supabaseData['calories'], equals(300));
        expect(supabaseData['proteins'], equals(20.0));
        expect(supabaseData['fats'], equals(10.0));
        expect(supabaseData['carbs'], equals(30.0));
        expect(
            supabaseData['photo_url'], equals('https://example.com/photo.jpg'));
        expect(supabaseData['date'], equals(testDate.toIso8601String()));
        expect(supabaseData.containsKey('id'), isFalse);
        expect(supabaseData.containsKey('created_at'), isFalse);
      });
    });

    group('SafeNumParsing extension', () {
      test('toSafeDouble handles various types', () {
        expect((5.5).toSafeDouble(), equals(5.5));
        expect((10).toSafeDouble(), equals(10.0));
        expect(('3.14').toSafeDouble(), equals(3.14));
        expect((null).toSafeDouble(), equals(0.0));
        expect((double.infinity).toSafeDouble(), equals(0.0));
        expect((double.nan).toSafeDouble(), equals(0.0));
        expect(('invalid').toSafeDouble(), equals(0.0));
      });

      test('toSafeInt handles various types', () {
        expect((42).toSafeInt(), equals(42));
        expect((3.7).toSafeInt(), equals(4));
        expect(('25').toSafeInt(), equals(25));
        expect((null).toSafeInt(), equals(0));
        expect((double.infinity).toSafeInt(), equals(0));
        expect(('invalid').toSafeInt(), equals(0));
      });

      test('toSafeString handles various types', () {
        expect(('hello').toSafeString(), equals('hello'));
        expect((123).toSafeString(), equals('123'));
        expect((3.14).toSafeString(), equals('3.14'));
        expect((null).toSafeString(), equals(''));
      });
    });
  });
}
