"""
OpenClaw Gateway client — OpenAI-compatible chat completions via local gateway.
Reads config from environment variables. Falls back gracefully if not configured.
"""

import os
import re
import json
import logging
from typing import Optional

import httpx

logger = logging.getLogger(__name__)

OPENCLAW_HOST = os.getenv("OPENCLAW_HOST", "127.0.0.1")
OPENCLAW_PORT = os.getenv("OPENCLAW_PORT", "18789")
OPENCLAW_TOKEN = os.getenv("OPENCLAW_TOKEN", "")
OPENCLAW_AGENT = os.getenv("OPENCLAW_AGENT", "main")

_BASE_URL = f"http://{OPENCLAW_HOST}:{OPENCLAW_PORT}"
_TIMEOUT = 30.0  # seconds

NUTRITION_SYSTEM_PROMPT = """\
You are a personal nutrition assistant for Yapper, an AI-powered food tracking app.

{meal_context}

You help users with:
- Analyzing meals and estimating nutrition
- Answering nutrition and diet questions
- Suggesting healthier alternatives
- Giving personalized advice based on their eating patterns

When the user describes a meal they ate or want to log, extract the nutrition data and \
embed it in your response using this exact tag:
<meal_json>{{"meal_name": "...", "calories": 0, "protein": 0, "carbs": 0, "fats": 0}}</meal_json>

For all other questions, respond conversationally. Keep answers concise and practical.\
"""

_MEAL_CONTEXT_TEMPLATE = """\
The user's recent meals (last {count}):
{meals}
"""


def is_configured() -> bool:
    """Return True if OpenClaw gateway credentials are set."""
    return bool(OPENCLAW_TOKEN)


def _build_meal_context(context_meals: list[dict]) -> str:
    if not context_meals:
        return "The user has no recent meals logged yet."
    lines = []
    for m in context_meals:
        name = m.get("meal_name", "Unknown")
        cal = m.get("calories", 0)
        p = m.get("protein", 0)
        c = m.get("carbs", 0)
        f = m.get("fats", 0)
        lines.append(f"  - {name}: {cal} kcal (P:{p}g C:{c}g F:{f}g)")
    return _MEAL_CONTEXT_TEMPLATE.format(count=len(lines), meals="\n".join(lines))


def _build_system_prompt(context_meals: list[dict]) -> str:
    meal_context = _build_meal_context(context_meals)
    return NUTRITION_SYSTEM_PROMPT.format(meal_context=meal_context)


def chat(
    user_message: str,
    user_id: str,
    context_meals: Optional[list[dict]] = None,
) -> dict:
    """
    Send a message to the OpenClaw gateway and return a structured response.

    Returns:
        {
            "response": str,          # conversational text
            "action": None | "add_meal",
            "meal_data": None | {...}
        }

    Raises:
        OpenClawError on gateway failures (caller should fall back to OpenAI).
    """
    if context_meals is None:
        context_meals = []

    system_prompt = _build_system_prompt(context_meals)
    model = f"openclaw:{OPENCLAW_AGENT}"

    payload = {
        "model": model,
        "user": user_id,  # creates a persistent session per user
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_message},
        ],
    }

    headers = {
        "Authorization": f"Bearer {OPENCLAW_TOKEN}",
        "Content-Type": "application/json",
    }

    url = f"{_BASE_URL}/v1/chat/completions"
    logger.info("OpenClaw request: user=%s url=%s", user_id, url)

    try:
        with httpx.Client(timeout=_TIMEOUT) as http:
            resp = http.post(url, json=payload, headers=headers)
        resp.raise_for_status()
    except httpx.HTTPStatusError as exc:
        raise OpenClawError(f"Gateway returned {exc.response.status_code}") from exc
    except httpx.RequestError as exc:
        raise OpenClawError(f"Gateway unreachable: {exc}") from exc

    data = resp.json()
    raw = data["choices"][0]["message"]["content"]
    return _parse_response(raw)


def _parse_response(raw: str) -> dict:
    """Extract conversational text and optional meal_json from the raw response."""
    meal_data = None
    action = None

    match = re.search(r"<meal_json>(.*?)</meal_json>", raw, re.DOTALL)
    if match:
        try:
            meal_data = json.loads(match.group(1).strip())
            action = "add_meal"
        except json.JSONDecodeError:
            logger.warning("Failed to parse meal_json block")

    # Strip the tag from the conversational text
    text = re.sub(r"<meal_json>.*?</meal_json>", "", raw, flags=re.DOTALL).strip()

    return {"response": text, "action": action, "meal_data": meal_data}


class OpenClawError(Exception):
    """Raised when the OpenClaw gateway is unavailable or returns an error."""
