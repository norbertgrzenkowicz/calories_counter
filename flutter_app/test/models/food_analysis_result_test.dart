import 'package:flutter_test/flutter_test.dart';
import 'package:food_scanner/models/food_analysis_result.dart';

void main() {
  group('FoodAnalysisResult.fromJson', () {
    test('parses complete v2 response', () {
      final json = {
        'analysis_version': 'v2',
        'status': 'complete',
        'meal_name': 'Chicken Rice Bowl',
        'calories': 640,
        'protein': 42,
        'carbs': 58,
        'fats': 24,
        'confidence': 0.74,
        'confidence_label': 'medium',
        'estimation_method': 'image_only',
        'clarifying_question': null,
        'assumptions': ['Assumed 1 cup cooked rice'],
        'flags': ['mixed_dish'],
        'items': [
          {
            'name': 'grilled chicken',
            'portion_text': 'about 150 g',
            'calories': 250,
            'protein': 46,
            'carbs': 0,
            'fats': 5,
            'confidence': 0.82,
          }
        ],
      };

      final result = FoodAnalysisResult.fromJson(json);

      expect(result.status, 'complete');
      expect(result.isComplete, isTrue);
      expect(result.needsClarification, isFalse);
      expect(result.mealName, 'Chicken Rice Bowl');
      expect(result.calories, 640);
      expect(result.protein, 42);
      expect(result.carbs, 58);
      expect(result.fats, 24);
      expect(result.confidence, closeTo(0.74, 0.001));
      expect(result.confidenceLabel, 'medium');
      expect(result.estimationMethod, 'image_only');
      expect(result.clarifyingQuestion, isNull);
      expect(result.assumptions, ['Assumed 1 cup cooked rice']);
      expect(result.flags, ['mixed_dish']);
      expect(result.items.length, 1);
      expect(result.items.first.name, 'grilled chicken');
      expect(result.items.first.calories, 250);
      expect(result.analysisVersion, 'v2');
    });

    test('parses needs_clarification v2 response', () {
      final json = {
        'analysis_version': 'v2',
        'status': 'needs_clarification',
        'meal_name': 'Mixed Rice Dish',
        'calories': 500,
        'protein': 30,
        'carbs': 60,
        'fats': 15,
        'confidence': 0.40,
        'confidence_label': 'low',
        'estimation_method': 'image_only',
        'clarifying_question': 'Was the chicken fried or grilled?',
        'assumptions': [],
        'flags': ['hidden_fat_risk'],
        'items': <Map<String, dynamic>>[],
      };

      final result = FoodAnalysisResult.fromJson(json);

      expect(result.status, 'needs_clarification');
      expect(result.needsClarification, isTrue);
      expect(result.isComplete, isFalse);
      expect(result.clarifyingQuestion, 'Was the chicken fried or grilled?');
      expect(result.confidenceLabel, 'low');
    });

    test('parses legacy flat response — backwards compat', () {
      final json = {
        'meal_name': 'Pasta Carbonara',
        'calories': 600,
        'protein': 20,
        'carbs': 80,
        'fats': 15,
      };

      final result = FoodAnalysisResult.fromJson(json);

      expect(result.mealName, 'Pasta Carbonara');
      expect(result.calories, 600);
      expect(result.protein, 20);
      expect(result.carbs, 80);
      expect(result.fats, 15);
      // Legacy rows default to complete
      expect(result.status, 'complete');
      expect(result.isComplete, isTrue);
      expect(result.assumptions, isEmpty);
      expect(result.items, isEmpty);
      expect(result.flags, isEmpty);
      // Legacy rows get v1 tag
      expect(result.analysisVersion, 'v1');
    });

    test('clamps negative values to 0', () {
      final json = {
        'meal_name': 'Test',
        'calories': -100,
        'protein': -5,
        'carbs': -10,
        'fats': -2,
      };

      final result = FoodAnalysisResult.fromJson(json);
      expect(result.calories, 0);
      expect(result.protein, 0);
      expect(result.carbs, 0);
      expect(result.fats, 0);
    });

    test('clamps confidence to 0..1', () {
      final json = {
        'meal_name': 'Test',
        'calories': 100,
        'protein': 10,
        'carbs': 10,
        'fats': 5,
        'confidence': 2.5,
      };
      final result = FoodAnalysisResult.fromJson(json);
      expect(result.confidence, closeTo(1.0, 0.001));
    });

    test('toJson round-trips correctly', () {
      final original = FoodAnalysisResult(
        status: 'complete',
        mealName: 'Grilled Salmon',
        calories: 400,
        protein: 40,
        carbs: 10,
        fats: 20,
        confidence: 0.85,
        confidenceLabel: 'high',
        assumptions: ['Assumed 200g salmon fillet'],
        flags: [],
        items: [],
        estimationMethod: 'image_only',
        analysisVersion: 'v2',
      );

      final json = original.toJson();
      final restored = FoodAnalysisResult.fromJson(json);

      expect(restored.mealName, original.mealName);
      expect(restored.calories, original.calories);
      expect(restored.status, original.status);
      expect(restored.confidenceLabel, original.confidenceLabel);
      expect(restored.assumptions, original.assumptions);
    });

    test('toLegacyMap contains only flat fields', () {
      final result = FoodAnalysisResult(
        status: 'complete',
        mealName: 'Oatmeal',
        calories: 300,
        protein: 10,
        carbs: 55,
        fats: 5,
        confidence: 0.9,
        confidenceLabel: 'high',
        assumptions: [],
        flags: [],
        items: [],
        estimationMethod: 'image_only',
        analysisVersion: 'v2',
      );

      final legacy = result.toLegacyMap();
      expect(legacy.keys.toSet(),
          {'meal_name', 'calories', 'protein', 'carbs', 'fats'});
      expect(legacy['calories'], 300);
    });

    test('items capped at 6 via model', () {
      final items = List.generate(
        10,
        (i) => {
          'name': 'item$i',
          'portion_text': '100g',
          'calories': 100,
          'protein': 10,
          'carbs': 10,
          'fats': 5,
          'confidence': 0.7,
        },
      );
      final json = {
        'meal_name': 'Big Plate',
        'calories': 1000,
        'protein': 100,
        'carbs': 100,
        'fats': 50,
        'items': items,
      };
      // No cap at model level — server enforces cap, model just parses
      final result = FoodAnalysisResult.fromJson(json);
      // All 10 items parsed by the client model (server caps at 6)
      expect(result.items.length, 10);
    });
  });

  group('FoodAnalysisItem.fromJson', () {
    test('parses item correctly', () {
      final item = FoodAnalysisItem.fromJson({
        'name': 'Brown Rice',
        'portion_text': '1 cup cooked',
        'calories': 215,
        'protein': 5,
        'carbs': 45,
        'fats': 2,
        'confidence': 0.9,
      });

      expect(item.name, 'Brown Rice');
      expect(item.portionText, '1 cup cooked');
      expect(item.calories, 215);
      expect(item.confidence, closeTo(0.9, 0.001));
    });
  });
}
