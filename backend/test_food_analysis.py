"""Unit tests for food_analysis.py normalization logic."""

import pytest
from food_analysis import _normalize_result


def _base_raw(**overrides):
    raw = {
        "needs_clarification": False,
        "clarifying_question": None,
        "meal_name": "Test Meal",
        "confidence": 0.8,
        "items": [],
        "assumptions": [],
        "flags": [],
    }
    raw.update(overrides)
    return raw


# ---------------------------------------------------------------------------
# Confidence label mapping
# ---------------------------------------------------------------------------

class TestConfidenceLabel:
    def test_low(self):
        r = _normalize_result(_base_raw(confidence=0.2), None)
        assert r["confidence_label"] == "low"

    def test_low_boundary(self):
        r = _normalize_result(_base_raw(confidence=0.44), None)
        assert r["confidence_label"] == "low"

    def test_medium_lower(self):
        r = _normalize_result(_base_raw(confidence=0.45), None)
        assert r["confidence_label"] == "medium"

    def test_medium_upper(self):
        r = _normalize_result(_base_raw(confidence=0.74), None)
        assert r["confidence_label"] == "medium"

    def test_high_boundary(self):
        r = _normalize_result(_base_raw(confidence=0.75), None)
        assert r["confidence_label"] == "high"

    def test_high(self):
        r = _normalize_result(_base_raw(confidence=1.0), None)
        assert r["confidence_label"] == "high"

    def test_clamp_above_1(self):
        r = _normalize_result(_base_raw(confidence=1.5), None)
        assert r["confidence"] == 1.0
        assert r["confidence_label"] == "high"

    def test_clamp_below_0(self):
        r = _normalize_result(_base_raw(confidence=-0.1), None)
        assert r["confidence"] == 0.0
        assert r["confidence_label"] == "low"


# ---------------------------------------------------------------------------
# Clarification question rules
# ---------------------------------------------------------------------------

class TestClarificationRules:
    def test_needs_clarification_with_question(self):
        r = _normalize_result(
            _base_raw(needs_clarification=True, clarifying_question="How much oil?"),
            context_text=None,
        )
        assert r["status"] == "needs_clarification"
        assert r["clarifying_question"] == "How much oil?"

    def test_needs_clarification_missing_question_downgrades(self):
        r = _normalize_result(
            _base_raw(needs_clarification=True, clarifying_question=None),
            context_text=None,
        )
        assert r["status"] == "complete"
        assert r["clarifying_question"] is None

    def test_needs_clarification_empty_question_downgrades(self):
        r = _normalize_result(
            _base_raw(needs_clarification=True, clarifying_question="   "),
            context_text=None,
        )
        assert r["status"] == "complete"

    def test_context_text_forces_complete(self):
        r = _normalize_result(
            _base_raw(needs_clarification=True, clarifying_question="How much sauce?"),
            context_text="about 1 tbsp teriyaki",
        )
        assert r["status"] == "complete"
        assert r["clarifying_question"] is None
        assert r["estimation_method"] == "image_plus_context"

    def test_no_context_uses_image_only(self):
        r = _normalize_result(_base_raw(), context_text=None)
        assert r["estimation_method"] == "image_only"


# ---------------------------------------------------------------------------
# Normalization — values
# ---------------------------------------------------------------------------

class TestNormalization:
    def test_non_negative_macros(self):
        r = _normalize_result(
            _base_raw(calories=-100, protein=-5, carbs=-10, fats=-2),
            None,
        )
        assert r["calories"] >= 0
        assert r["protein"] >= 0
        assert r["carbs"] >= 0
        assert r["fats"] >= 0

    def test_items_cap_at_6(self):
        items = [
            {"name": f"item{i}", "portion_text": "", "calories": 10, "protein": 1,
             "carbs": 1, "fats": 0, "confidence": 0.5}
            for i in range(10)
        ]
        r = _normalize_result(_base_raw(items=items), None)
        assert len(r["items"]) == 6

    def test_items_recompute_totals(self):
        items = [
            {"name": "chicken", "portion_text": "150g", "calories": 200, "protein": 40,
             "carbs": 0, "fats": 5, "confidence": 0.9},
            {"name": "rice", "portion_text": "1 cup", "calories": 200, "protein": 4,
             "carbs": 44, "fats": 0, "confidence": 0.8},
        ]
        r = _normalize_result(_base_raw(items=items), None)
        assert r["protein"] == 44
        assert r["carbs"] == 44
        assert r["fats"] == 5

    def test_macro_calorie_normalization(self):
        # protein=50 carbs=50 fats=10 → macro_cal = 200+200+90 = 490
        # stated calories=700 — diff is 210 > 60, so should normalize
        r = _normalize_result(
            _base_raw(calories=700, protein=50, carbs=50, fats=10),
            None,
        )
        assert r["calories"] == 490
        assert "macro_calorie_normalized" in r["flags"]

    def test_no_macro_normalization_within_tolerance(self):
        # protein=50 carbs=50 fats=10 → macro_cal=490; stated=500 — diff=10 < 60
        r = _normalize_result(
            _base_raw(calories=500, protein=50, carbs=50, fats=10),
            None,
        )
        assert "macro_calorie_normalized" not in r["flags"]


# ---------------------------------------------------------------------------
# Legacy compatibility
# ---------------------------------------------------------------------------

class TestLegacyCompatibility:
    def test_legacy_flat_dict(self):
        """Old nutrition_data with only flat keys must parse without error."""
        legacy = {
            "meal_name": "Pasta",
            "calories": 600,
            "protein": 20,
            "carbs": 80,
            "fats": 15,
        }
        r = _normalize_result(legacy, None)
        assert r["meal_name"] == "Pasta"
        assert r["status"] == "complete"
        assert r["assumptions"] == []
        assert r["items"] == []

    def test_analysis_version_always_set(self):
        r = _normalize_result(_base_raw(), None)
        assert r["analysis_version"] == "v2"
