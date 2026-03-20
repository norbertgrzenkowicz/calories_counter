import 'package:flutter_test/flutter_test.dart';
import 'package:food_scanner/models/food_analysis_result.dart';

void main() {
  group('FoodAnalysisResult.fromJson', () {
    test('parses legacy flat payloads', () {
      final result = FoodAnalysisResult.fromJson({
        'meal_name': 'Chicken and rice',
        'calories': 540,
        'protein': 42,
        'carbs': 48,
        'fats': 16,
      });

      expect(result.status, 'complete');
      expect(result.analysisVersion, 'legacy');
      expect(result.mealName, 'Chicken and rice');
      expect(result.calories, 540);
      expect(result.protein, 42);
      expect(result.items, isEmpty);
      expect(result.assumptions, isEmpty);
    });

    test('parses v2 payloads with clarification metadata', () {
      final result = FoodAnalysisResult.fromJson({
        'analysis_version': 'v2',
        'status': 'needs_clarification',
        'meal_name': 'Rice bowl',
        'calories': 640,
        'protein': 36,
        'carbs': 58,
        'fats': 22,
        'confidence': 0.61,
        'confidence_label': 'medium',
        'clarifying_question': 'How much oil was used?',
        'assumptions': ['Assumed about 1 cup cooked rice'],
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
          },
        ],
        'estimation_method': 'image_only',
      });

      expect(result.analysisVersion, 'v2');
      expect(result.needsClarification, isTrue);
      expect(result.clarifyingQuestion, 'How much oil was used?');
      expect(result.assumptions, ['Assumed about 1 cup cooked rice']);
      expect(result.flags, ['mixed_dish']);
      expect(result.items, hasLength(1));
      expect(result.items.first.name, 'grilled chicken');
      expect(result.confidenceLabel, 'medium');
    });
  });
}
