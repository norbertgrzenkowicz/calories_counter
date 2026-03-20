from __future__ import annotations

import base64
import json
import os
import re
from typing import Any, Dict, Iterable, List, Literal, Optional, Type, TypeVar

from pydantic import BaseModel, Field


IMAGE_MODEL_ENV = "OPENAI_FOOD_IMAGE_MODEL"
TEXT_MODEL_ENV = "OPENAI_FOOD_TEXT_MODEL"
DEFAULT_IMAGE_MODEL = "gpt-5-mini"
DEFAULT_TEXT_MODEL = "gpt-5-nano"
MAX_ITEMS = 6

ModelT = TypeVar("ModelT", bound=BaseModel)


class FoodAnalysisItem(BaseModel):
    name: str = "Unknown item"
    portion_text: str = ""
    calories: int = 0
    protein: int = 0
    carbs: int = 0
    fats: int = 0
    confidence: float = 0.0


class FoodAnalysisResponseV2(BaseModel):
    analysis_version: str = "v2"
    status: Literal["complete", "needs_clarification"] = "complete"
    meal_name: str = "Unknown Meal"
    calories: int = 0
    protein: int = 0
    carbs: int = 0
    fats: int = 0
    confidence: float = 0.0
    confidence_label: Literal["low", "medium", "high"] = "low"
    estimation_method: Literal["image_only", "image_plus_context"] = "image_only"
    clarifying_question: Optional[str] = None
    assumptions: List[str] = Field(default_factory=list)
    flags: List[str] = Field(default_factory=list)
    items: List[FoodAnalysisItem] = Field(default_factory=list)


class LegacyNutritionResponse(BaseModel):
    meal_name: str = "Unknown Meal"
    calories: int = 0
    protein: int = 0
    carbs: int = 0
    fats: int = 0


class ImageUnderstandingResponse(BaseModel):
    meal_name: str = "Unknown Meal"
    visible_items: List[str] = Field(default_factory=list)
    portion_cues: List[str] = Field(default_factory=list)
    hidden_calorie_risks: List[str] = Field(default_factory=list)
    needs_clarification: bool = False
    clarifying_question: Optional[str] = None


class ImageNutritionSynthesisResponse(BaseModel):
    meal_name: str = "Unknown Meal"
    calories: int = 0
    protein: int = 0
    carbs: int = 0
    fats: int = 0
    confidence: float = 0.0
    assumptions: List[str] = Field(default_factory=list)
    flags: List[str] = Field(default_factory=list)
    items: List[FoodAnalysisItem] = Field(default_factory=list)


def _model_schema(model_type: Type[ModelT]) -> Dict[str, Any]:
    if hasattr(model_type, "model_json_schema"):
        return model_type.model_json_schema()
    return model_type.schema()


def _model_validate(model_type: Type[ModelT], data: Any) -> ModelT:
    if hasattr(model_type, "model_validate"):
        return model_type.model_validate(data)
    return model_type.parse_obj(data)


def _model_dump(model: BaseModel) -> Dict[str, Any]:
    if hasattr(model, "model_dump"):
        return model.model_dump()
    return model.dict()


def get_image_model() -> str:
    return os.getenv(IMAGE_MODEL_ENV, DEFAULT_IMAGE_MODEL)


def get_text_model() -> str:
    return os.getenv(TEXT_MODEL_ENV, DEFAULT_TEXT_MODEL)


def confidence_label_for(value: float) -> Literal["low", "medium", "high"]:
    if value < 0.45:
        return "low"
    if value < 0.75:
        return "medium"
    return "high"


def _coerce_int(value: Any) -> int:
    if isinstance(value, bool):
        return int(value)
    if isinstance(value, (int, float)):
        return max(0, int(round(value)))
    if isinstance(value, str):
        match = re.search(r"-?\d+(?:\.\d+)?", value)
        if match:
            return max(0, int(round(float(match.group(0)))))
    return 0


def _coerce_float(value: Any) -> float:
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        match = re.search(r"-?\d+(?:\.\d+)?", value)
        if match:
            return float(match.group(0))
    return 0.0


def _normalize_string_list(value: Any) -> List[str]:
    if not isinstance(value, list):
        return []
    normalized: List[str] = []
    for item in value:
        text = str(item).strip()
        if text and text not in normalized:
            normalized.append(text)
    return normalized


def _normalize_items(items: Any) -> List[FoodAnalysisItem]:
    if not isinstance(items, list):
        return []

    normalized_items: List[FoodAnalysisItem] = []
    for item in items[:MAX_ITEMS]:
        if not isinstance(item, dict):
            continue
        normalized_items.append(
            FoodAnalysisItem(
                name=str(item.get("name", "Unknown item")).strip() or "Unknown item",
                portion_text=str(item.get("portion_text", "")).strip(),
                calories=_coerce_int(item.get("calories", 0)),
                protein=_coerce_int(item.get("protein", 0)),
                carbs=_coerce_int(item.get("carbs", 0)),
                fats=_coerce_int(item.get("fats", 0)),
                confidence=max(0.0, min(1.0, _coerce_float(item.get("confidence", 0.0)))),
            )
        )

    return normalized_items


def _extract_json_payload(raw_content: str) -> Any:
    text = (raw_content or "").strip()
    if not text:
        return {}

    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass

    code_block_match = re.search(
        r"```(?:json)?\s*(\{.*\}|\[.*\])\s*```",
        text,
        re.DOTALL,
    )
    if code_block_match:
        return json.loads(code_block_match.group(1))

    object_start = text.find("{")
    object_end = text.rfind("}")
    if object_start != -1 and object_end != -1 and object_end > object_start:
        return json.loads(text[object_start : object_end + 1])

    array_start = text.find("[")
    array_end = text.rfind("]")
    if array_start != -1 and array_end != -1 and array_end > array_start:
        return json.loads(text[array_start : array_end + 1])

    raise json.JSONDecodeError("Could not locate JSON payload", text, 0)


def _extract_response_text(response: Any) -> str:
    message = response.choices[0].message
    content = getattr(message, "content", "")
    if isinstance(content, str):
        return content.strip()

    if isinstance(content, list):
        parts: List[str] = []
        for part in content:
            if isinstance(part, dict):
                text_value = part.get("text")
                if text_value:
                    parts.append(str(text_value))
            else:
                text_value = getattr(part, "text", None)
                if text_value:
                    parts.append(str(text_value))
        return "\n".join(parts).strip()

    return str(content).strip()


def _build_response_format(model_type: Type[BaseModel], schema_name: str) -> Dict[str, Any]:
    return {
        "type": "json_schema",
        "json_schema": {
            "name": schema_name,
            "strict": True,
            "schema": _model_schema(model_type),
        },
    }


def _image_content_part(image_data: Optional[str], image_url: Optional[str]) -> Dict[str, Any]:
    if image_data:
        return {
            "type": "image_url",
            "image_url": {
                "url": f"data:image/jpeg;base64,{image_data}",
            },
        }
    if image_url:
        return {
            "type": "image_url",
            "image_url": {
                "url": image_url,
            },
        }
    raise ValueError("Either image_data or image_url must be provided")


def build_image_understanding_messages(
    image_data: Optional[str],
    image_url: Optional[str],
    context_text: Optional[str] = None,
) -> List[Dict[str, Any]]:
    clarification_state = (
        f"User clarification for this same image: {context_text.strip()}"
        if context_text and context_text.strip()
        else "No user clarification is available yet."
    )
    prompt = "\n".join(
        [
            "Analyze this food image in stage 1.",
            clarification_state,
            "Identify visible food items, portion cues, and hidden-calorie risks.",
            "Decide if exactly one clarification question would materially improve the estimate.",
            "Ask one clarification question only if the answer could plausibly change total calories by more than 15% or any macro by more than 20%.",
            "Allowed question categories: cooking oil or butter, sauce or dressing amount, beverage type, rice/pasta/bread amount, ingredient identity with materially different macros.",
            "Do not ask multipart questions.",
            "Do not ask generic tell-me-more questions.",
            "If user clarification is already present, set needs_clarification to false and clarifying_question to null.",
            "Return valid JSON only.",
        ]
    )

    return [
        {
            "role": "system",
            "content": (
                "You are a nutrition-image analyst performing the image-understanding "
                "stage of a calorie estimation pipeline."
            ),
        },
        {
            "role": "user",
            "content": [
                {"type": "text", "text": prompt},
                _image_content_part(image_data, image_url),
            ],
        },
    ]


def build_image_synthesis_messages(
    image_data: Optional[str],
    image_url: Optional[str],
    stage1: ImageUnderstandingResponse,
    context_text: Optional[str] = None,
) -> List[Dict[str, Any]]:
    stage1_json = json.dumps(_model_dump(stage1), ensure_ascii=True)
    clarification_state = (
        f"User clarification for this same image: {context_text.strip()}"
        if context_text and context_text.strip()
        else "No user clarification is available."
    )
    prompt = "\n".join(
        [
            "Analyze this food image in stage 2 and synthesize nutrition totals.",
            clarification_state,
            f"Stage 1 findings: {stage1_json}",
            "Produce top-level meal totals, an itemized breakdown, assumptions, flags, and confidence.",
            "If user clarification is present, trust it for hidden ingredients, cooking method, and sauces.",
            "Trust the image more than user text for visible relative portion size.",
            "Record explicit assumptions instead of silent guesses.",
            "Treat beverages as separate items if visible.",
            "Do not fabricate brand-specific precision unless the image or user text makes it obvious.",
            "Estimate portions conservatively.",
            "Return valid JSON only.",
        ]
    )

    return [
        {
            "role": "system",
            "content": (
                "You are a nutrition-image analyst performing the nutrition-synthesis "
                "stage of a calorie estimation pipeline."
            ),
        },
        {
            "role": "user",
            "content": [
                {"type": "text", "text": prompt},
                _image_content_part(image_data, image_url),
            ],
        },
    ]


def build_text_analysis_messages(text_description: str) -> List[Dict[str, str]]:
    return [
        {
            "role": "system",
            "content": (
                "You are a nutrition expert. Analyze text descriptions of food and "
                "ingredients to estimate calories and macronutrients. Return only JSON."
            ),
        },
        {
            "role": "user",
            "content": (
                "Estimate the total nutritional content of this food description and "
                "give it a descriptive meal name. "
                f"Description: {text_description!r}"
            ),
        },
    ]


def _run_structured_chat_completion(
    client: Any,
    *,
    model: str,
    messages: List[Dict[str, Any]],
    schema_model: Type[ModelT],
    schema_name: str,
) -> ModelT:
    response = client.chat.completions.create(
        model=model,
        messages=messages,
        response_format=_build_response_format(schema_model, schema_name),
    )
    raw_content = _extract_response_text(response)
    payload = _extract_json_payload(raw_content)
    return _model_validate(schema_model, payload)


def normalize_food_analysis(
    payload: Dict[str, Any],
    *,
    context_text: Optional[str] = None,
) -> FoodAnalysisResponseV2:
    normalized_items = _normalize_items(payload.get("items", []))
    assumptions = _normalize_string_list(payload.get("assumptions", []))
    flags = _normalize_string_list(payload.get("flags", []))

    protein = _coerce_int(payload.get("protein", 0))
    carbs = _coerce_int(payload.get("carbs", 0))
    fats = _coerce_int(payload.get("fats", 0))
    calories = _coerce_int(payload.get("calories", 0))

    if normalized_items:
        protein = sum(item.protein for item in normalized_items)
        carbs = sum(item.carbs for item in normalized_items)
        fats = sum(item.fats for item in normalized_items)
        item_calories = sum(item.calories for item in normalized_items)
        if calories <= 0 and item_calories > 0:
            calories = item_calories

    macro_calories = 4 * protein + 4 * carbs + 9 * fats
    calorie_delta = abs(calories - macro_calories)
    calorie_threshold = max(60, int(round(max(calories, macro_calories) * 0.10)))
    if macro_calories > 0 and calorie_delta > calorie_threshold:
        calories = macro_calories
        if "macro_calorie_normalized" not in flags:
            flags.append("macro_calorie_normalized")

    confidence = max(0.0, min(1.0, _coerce_float(payload.get("confidence", 0.0))))
    status = str(payload.get("status", "complete")).strip() or "complete"
    if status not in {"complete", "needs_clarification"}:
        status = "complete"

    clarifying_question = payload.get("clarifying_question")
    clarifying_question = (
        str(clarifying_question).strip() if clarifying_question is not None else None
    )
    if not clarifying_question:
        clarifying_question = None

    if context_text and context_text.strip():
        status = "complete"
        clarifying_question = None

    if status == "needs_clarification" and not clarifying_question:
        status = "complete"

    estimation_method: Literal["image_only", "image_plus_context"] = (
        "image_plus_context"
        if context_text and context_text.strip()
        else "image_only"
    )

    return FoodAnalysisResponseV2(
        analysis_version="v2",
        status=status,
        meal_name=str(payload.get("meal_name", "Unknown Meal")).strip() or "Unknown Meal",
        calories=calories,
        protein=protein,
        carbs=carbs,
        fats=fats,
        confidence=confidence,
        confidence_label=confidence_label_for(confidence),
        estimation_method=estimation_method,
        clarifying_question=clarifying_question,
        assumptions=assumptions,
        flags=flags,
        items=normalized_items,
    )


def normalize_legacy_nutrition(payload: Dict[str, Any]) -> LegacyNutritionResponse:
    return LegacyNutritionResponse(
        meal_name=str(payload.get("meal_name", "Unknown Meal")).strip() or "Unknown Meal",
        calories=_coerce_int(payload.get("calories", 0)),
        protein=_coerce_int(payload.get("protein", 0)),
        carbs=_coerce_int(payload.get("carbs", 0)),
        fats=_coerce_int(payload.get("fats", 0)),
    )


def parse_nutrition_json(raw_content: str) -> Dict[str, Any]:
    payload = _extract_json_payload(raw_content)

    if isinstance(payload, list):
        aggregate = {
            "meal_name": "Composite Meal",
            "calories": 0,
            "protein": 0,
            "carbs": 0,
            "fats": 0,
        }
        meal_names: List[str] = []
        for item in payload:
            if not isinstance(item, dict):
                continue
            name = str(item.get("meal_name", "")).strip()
            if name:
                meal_names.append(name)
            aggregate["calories"] += _coerce_int(item.get("calories", 0))
            aggregate["protein"] += _coerce_int(item.get("protein", 0))
            aggregate["carbs"] += _coerce_int(item.get("carbs", 0))
            aggregate["fats"] += _coerce_int(item.get("fats", 0))
        if meal_names:
            aggregate["meal_name"] = " + ".join(meal_names[:3])
        return aggregate

    if not isinstance(payload, dict):
        return _model_dump(LegacyNutritionResponse())

    if "status" in payload or "analysis_version" in payload or "items" in payload:
        return _model_dump(normalize_food_analysis(payload))

    return _model_dump(normalize_legacy_nutrition(payload))


def analyze_image(
    client: Any,
    *,
    image_data: Optional[str] = None,
    image_url: Optional[str] = None,
    context_text: Optional[str] = None,
) -> Dict[str, Any]:
    if not image_data and not image_url:
        raise ValueError("Either image_data or image_url must be provided")

    stage1 = _run_structured_chat_completion(
        client,
        model=get_image_model(),
        messages=build_image_understanding_messages(image_data, image_url, context_text),
        schema_model=ImageUnderstandingResponse,
        schema_name="food_image_understanding",
    )
    stage2 = _run_structured_chat_completion(
        client,
        model=get_image_model(),
        messages=build_image_synthesis_messages(image_data, image_url, stage1, context_text),
        schema_model=ImageNutritionSynthesisResponse,
        schema_name="food_image_nutrition",
    )

    payload = _model_dump(stage2)
    payload["status"] = (
        "complete"
        if context_text and context_text.strip()
        else ("needs_clarification" if stage1.needs_clarification else "complete")
    )
    payload["clarifying_question"] = (
        None
        if context_text and context_text.strip()
        else stage1.clarifying_question
    )
    if not payload.get("meal_name") and stage1.meal_name:
        payload["meal_name"] = stage1.meal_name

    normalized = normalize_food_analysis(payload, context_text=context_text)
    return _model_dump(normalized)


def analyze_text(client: Any, text_description: str) -> Dict[str, Any]:
    payload = _run_structured_chat_completion(
        client,
        model=get_text_model(),
        messages=build_text_analysis_messages(text_description),
        schema_model=LegacyNutritionResponse,
        schema_name="text_food_analysis",
    )
    return _model_dump(normalize_legacy_nutrition(_model_dump(payload)))


def encode_image_file_to_base64(image_path: str) -> str:
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")
