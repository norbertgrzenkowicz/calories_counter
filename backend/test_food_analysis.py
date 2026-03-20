import unittest

import food_analysis as fa


class FoodAnalysisNormalizationTests(unittest.TestCase):
    def test_normalization_recomputes_macros_and_calories_from_items(self) -> None:
        result = fa.normalize_food_analysis(
            {
                "analysis_version": "v2",
                "status": "complete",
                "meal_name": "Chicken rice bowl",
                "calories": 999,
                "protein": 999,
                "carbs": 999,
                "fats": 999,
                "confidence": 1.7,
                "assumptions": ["Assumed grilled chicken"],
                "items": [
                    {
                        "name": "chicken",
                        "portion_text": "150 g",
                        "calories": 250,
                        "protein": 31,
                        "carbs": 0,
                        "fats": 4,
                        "confidence": 0.8,
                    },
                    {
                        "name": "rice",
                        "portion_text": "1 cup",
                        "calories": 220,
                        "protein": 4,
                        "carbs": 45,
                        "fats": 0,
                        "confidence": 0.75,
                    },
                    {
                        "name": "sauce",
                        "portion_text": "2 tbsp",
                        "calories": 30,
                        "protein": 0,
                        "carbs": 2,
                        "fats": 2,
                        "confidence": 0.5,
                    },
                ],
            }
        )

        self.assertEqual(result.protein, 35)
        self.assertEqual(result.carbs, 47)
        self.assertEqual(result.fats, 6)
        self.assertEqual(result.calories, 382)
        self.assertEqual(result.confidence, 1.0)
        self.assertEqual(result.confidence_label, "high")
        self.assertIn("macro_calorie_normalized", result.flags)

    def test_confidence_label_mapping_boundaries(self) -> None:
        self.assertEqual(fa.confidence_label_for(0.0), "low")
        self.assertEqual(fa.confidence_label_for(0.44), "low")
        self.assertEqual(fa.confidence_label_for(0.45), "medium")
        self.assertEqual(fa.confidence_label_for(0.74), "medium")
        self.assertEqual(fa.confidence_label_for(0.75), "high")

    def test_clarification_rules_require_question_and_stop_after_context(self) -> None:
        provisional = fa.normalize_food_analysis(
            {
                "status": "needs_clarification",
                "meal_name": "Pasta",
                "calories": 500,
                "protein": 20,
                "carbs": 60,
                "fats": 15,
                "clarifying_question": "   ",
            }
        )
        refined = fa.normalize_food_analysis(
            {
                "status": "needs_clarification",
                "meal_name": "Pasta",
                "calories": 520,
                "protein": 22,
                "carbs": 60,
                "fats": 16,
                "clarifying_question": "How much oil was used?",
            },
            context_text="about 1 tbsp oil",
        )

        self.assertEqual(provisional.status, "complete")
        self.assertIsNone(provisional.clarifying_question)
        self.assertEqual(refined.status, "complete")
        self.assertIsNone(refined.clarifying_question)
        self.assertEqual(refined.estimation_method, "image_plus_context")

    def test_legacy_response_parses_cleanly(self) -> None:
        raw_content = """
        ```json
        {
          "meal_name": "Turkey sandwich",
          "calories": "430",
          "protein": "28",
          "carbs": 36,
          "fats": 18
        }
        ```
        """

        parsed = fa.parse_nutrition_json(raw_content)

        self.assertEqual(parsed["meal_name"], "Turkey sandwich")
        self.assertEqual(parsed["calories"], 430)
        self.assertEqual(parsed["protein"], 28)
        self.assertEqual(parsed["carbs"], 36)
        self.assertEqual(parsed["fats"], 18)


if __name__ == "__main__":
    unittest.main()
