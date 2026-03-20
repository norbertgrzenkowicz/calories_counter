"""
Two-stage food image analysis pipeline.

Stage 1: Image understanding — items, portions, hidden-calorie risks, clarification decision
Stage 2: Nutrition synthesis — per-item macros, totals, assumptions, flags, confidence
"""

from __future__ import annotations

import json
import os
import re
from typing import Optional

from openai import OpenAI

FOOD_IMAGE_MODEL = os.getenv("OPENAI_FOOD_IMAGE_MODEL", "gpt-5-mini")
FOOD_TEXT_MODEL = os.getenv("OPENAI_FOOD_TEXT_MODEL", "gpt-5-nano")

_IMAGE_SYSTEM_PROMPT = """You are a precise nutrition expert and registered dietitian.
Your task is to analyze meal photos and estimate nutritional content with scientific rigor.

Rules you must follow:
- Identify each visible food item separately.
- Estimate portions conservatively; do not inflate estimates.
- List every assumption you make explicitly (e.g. "Assumed 1 tbsp olive oil").
- Avoid fake precision: round to the nearest 5 kcal and nearest gram.
- Treat beverages as separate items when visible.
- Do not fabricate brand-specific precision unless the brand is clearly visible.
- If one clarification question would plausibly change total calories by >15% or any macro by >20%, set needs_clarification=true and provide exactly one short, direct question.
- Ask at most ONE question. Never ask multipart questions. Never ask generic "tell me more".
- Only ask about: cooking oil/butter, sauce/dressing amount, beverage type, rice/pasta/bread amount when scale is ambiguous, or ingredient identity when two options have materially different macros.
- If context_text is provided, do NOT ask another question — use the context to refine the estimate.
- Return ONLY valid JSON — no prose, no markdown fences.

Return this exact JSON structure:
{
  "needs_clarification": false,
  "clarifying_question": null,
  "meal_name": "string",
  "confidence": 0.75,
  "items": [
    {
      "name": "string",
      "portion_text": "string",
      "calories": 0,
      "protein": 0,
      "carbs": 0,
      "fats": 0,
      "confidence": 0.0
    }
  ],
  "assumptions": ["string"],
  "flags": ["string"]
}

Valid flags: mixed_dish, hidden_fat_risk, sauce_unknown, portion_ambiguous, beverage_detected, brand_detected, macro_calorie_normalized
"""


def _build_image_user_prompt(context_text: Optional[str]) -> str:
    base = (
        "Analyze this meal photo. Identify each food item, estimate portions conservatively, "
        "list assumptions, and assess whether a clarification question would materially improve accuracy."
    )
    if context_text:
        base += f"\n\nUser provided additional context: \"{context_text}\"\nUse this context to refine your estimate. Do NOT ask another question."
    return base


def _normalize_result(raw: dict, context_text: Optional[str]) -> dict:
    """Apply all normalization rules from the spec."""

    def clamp_int(v, default=0):
        try:
            return max(0, int(round(float(v))))
        except (TypeError, ValueError):
            return default

    def clamp_float(v, lo=0.0, hi=1.0, default=0.5):
        try:
            return max(lo, min(hi, float(v)))
        except (TypeError, ValueError):
            return default

    # Normalize items
    raw_items = raw.get("items") or []
    items = []
    for item in raw_items[:6]:
        if not isinstance(item, dict):
            continue
        items.append({
            "name": str(item.get("name", "Unknown")),
            "portion_text": str(item.get("portion_text", "")),
            "calories": clamp_int(item.get("calories")),
            "protein": clamp_int(item.get("protein")),
            "carbs": clamp_int(item.get("carbs")),
            "fats": clamp_int(item.get("fats")),
            "confidence": clamp_float(item.get("confidence")),
        })

    # If items present, recompute totals from items
    if items:
        total_calories = sum(i["calories"] for i in items)
        total_protein = sum(i["protein"] for i in items)
        total_carbs = sum(i["carbs"] for i in items)
        total_fats = sum(i["fats"] for i in items)
    else:
        total_calories = clamp_int(raw.get("calories"))
        total_protein = clamp_int(raw.get("protein"))
        total_carbs = clamp_int(raw.get("carbs"))
        total_fats = clamp_int(raw.get("fats"))

    # Macro-derived calorie check
    flags = list(raw.get("flags") or [])
    macro_calories = 4 * total_protein + 4 * total_carbs + 9 * total_fats
    if macro_calories > 0:
        diff = abs(total_calories - macro_calories)
        if diff > 60 or (total_calories > 0 and diff / total_calories > 0.10):
            total_calories = macro_calories
            if "macro_calorie_normalized" not in flags:
                flags.append("macro_calorie_normalized")

    # Confidence
    confidence = clamp_float(raw.get("confidence"))

    # Confidence label
    if confidence < 0.45:
        confidence_label = "low"
    elif confidence < 0.75:
        confidence_label = "medium"
    else:
        confidence_label = "high"

    # Clarification logic
    needs_clarification = bool(raw.get("needs_clarification", False))
    clarifying_question = raw.get("clarifying_question") or None
    if isinstance(clarifying_question, str):
        clarifying_question = clarifying_question.strip() or None

    # If context_text present, never ask another question
    if context_text:
        needs_clarification = False
        clarifying_question = None

    # Downgrade if question missing
    if needs_clarification and not clarifying_question:
        needs_clarification = False

    status = "needs_clarification" if needs_clarification else "complete"
    estimation_method = "image_plus_context" if context_text else "image_only"

    return {
        "analysis_version": "v2",
        "status": status,
        "meal_name": str(raw.get("meal_name") or "Unknown Meal"),
        "calories": total_calories,
        "protein": total_protein,
        "carbs": total_carbs,
        "fats": total_fats,
        "confidence": confidence,
        "confidence_label": confidence_label,
        "estimation_method": estimation_method,
        "clarifying_question": clarifying_question,
        "assumptions": [str(a) for a in (raw.get("assumptions") or [])],
        "flags": [str(f) for f in flags],
        "items": items,
    }


def _parse_model_json(raw_content: str) -> dict:
    """Extract and parse JSON from model output, stripping markdown fences."""
    content = raw_content.strip()
    # Strip markdown code fences
    match = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", content, re.DOTALL)
    if match:
        content = match.group(1)
    return json.loads(content)


def analyze_image(
    client: OpenAI,
    image_data: Optional[str] = None,
    image_url: Optional[str] = None,
    context_text: Optional[str] = None,
) -> dict:
    """
    Two-stage image analysis. Returns a normalized v2 response dict.
    At least one of image_data (base64) or image_url must be provided.
    """
    if not image_data and not image_url:
        raise ValueError("At least one of image_data or image_url must be provided")

    user_prompt = _build_image_user_prompt(context_text)

    # Build the image content block — prefer base64 if both supplied
    if image_data:
        image_block = {
            "type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{image_data}"},
        }
    else:
        image_block = {
            "type": "image_url",
            "image_url": {"url": image_url},
        }

    messages = [
        {"role": "system", "content": _IMAGE_SYSTEM_PROMPT},
        {
            "role": "user",
            "content": [
                {"type": "text", "text": user_prompt},
                image_block,
            ],
        },
    ]

    try:
        response = client.chat.completions.create(
            model=FOOD_IMAGE_MODEL,
            messages=messages,
        )
        raw_content = response.choices[0].message.content.strip()
        raw = _parse_model_json(raw_content)
    except json.JSONDecodeError as e:
        print(f"JSON parse error in food_analysis.analyze_image: {e}")
        raw = {}
    except Exception as e:
        print(f"OpenAI API error in food_analysis.analyze_image: {e}")
        raw = {}

    return _normalize_result(raw, context_text)


def analyze_text(client: OpenAI, text: str) -> dict:
    """
    Text-based food analysis (unchanged internally, but returns v2 shape for caller convenience).
    Keeps the flat legacy shape the text endpoint uses.
    """
    system_prompt = (
        "You are a nutrition expert. Analyze text descriptions of food and ingredients to estimate "
        "nutritional values. Parse quantities, ingredient names, and cooking methods. Use standard "
        "nutrition database knowledge to calculate totals. Generate a descriptive meal name based on "
        "the ingredients. Return only a JSON object with meal_name (string), calories, protein, "
        "carbs, and fats as integers (grams for macronutrients)."
    )
    user_prompt = (
        f'Estimate the total nutritional content of this food description and give it a descriptive name: '
        f'"{text}". Return JSON format: {{"meal_name": "descriptive name", "calories": number, '
        f'"protein": grams, "carbs": grams, "fats": grams}}'
    )

    try:
        response = client.chat.completions.create(
            model=FOOD_TEXT_MODEL,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
        )
        raw_content = response.choices[0].message.content.strip()
        raw = _parse_model_json(raw_content)
    except json.JSONDecodeError as e:
        print(f"JSON parse error in food_analysis.analyze_text: {e}")
        raw = {}
    except Exception as e:
        print(f"OpenAI API error in food_analysis.analyze_text: {e}")
        raw = {}

    def _ci(v):
        try:
            return max(0, int(round(float(v))))
        except (TypeError, ValueError):
            return 0

    return {
        "meal_name": str(raw.get("meal_name") or "Unknown Meal"),
        "calories": _ci(raw.get("calories")),
        "protein": _ci(raw.get("protein")),
        "carbs": _ci(raw.get("carbs")),
        "fats": _ci(raw.get("fats")),
    }
