"""Benchmark multiple OpenAI models on a fixed food description prompt."""

from __future__ import annotations

import argparse
import csv
import os
import re
import statistics
import time
from dataclasses import dataclass
from typing import Dict, Iterable, List, Optional, Tuple

from dotenv import load_dotenv
from openai import OpenAI

from app import parse_nutrition_json as _parse_nutrition_json


WORD_TO_NUMBER = {
    "zero": 0,
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
    "ten": 10,
    "eleven": 11,
    "twelve": 12,
    "thirteen": 13,
    "fourteen": 14,
    "fifteen": 15,
    "sixteen": 16,
    "seventeen": 17,
    "eighteen": 18,
    "nineteen": 19,
    "twenty": 20,
    "thirty": 30,
    "forty": 40,
    "fifty": 50,
    "sixty": 60,
    "seventy": 70,
    "eighty": 80,
    "ninety": 90,
    "hundred": 100,
}


def get_response_token_limits(model: str) -> List[int]:
    for prefix, limits in RESPONSE_TOKEN_LIMIT_OVERRIDES.items():
        if model.startswith(prefix):
            return limits
    return [RESPONSES_DEFAULT_MAX_TOKENS]


def _word_number_to_int(text: str) -> Optional[int]:
    cleaned = text.lower().replace("-", " ")
    total = 0
    current = 0
    found = False
    for word in cleaned.split():
        if word not in WORD_TO_NUMBER:
            continue
        found = True
        value = WORD_TO_NUMBER[word]
        if value == 100:
            current = (current or 1) * 100
        else:
            current += value
    if not found:
        return None
    total += current
    return total


def _coerce_float(value) -> float:
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        match = re.search(r"-?\d+(?:\.\d+)?", value)
        if match:
            return float(match.group())
        word_val = _word_number_to_int(value)
        if word_val is not None:
            return float(word_val)
    return 0.0


def _coerce_int(value) -> int:
    return int(round(_coerce_float(value)))


def _aggregate_list_payload(items: Iterable[dict]) -> Dict[str, int | str]:
    totals = {
        "meal_name": "Composite Meal",
        "calories": 0,
        "protein": 0,
        "carbs": 0,
        "fats": 0,
    }
    meal_names: List[str] = []
    for item in items:
        if not isinstance(item, dict):
            continue
        name = str(item.get("meal_name", "")).strip()
        if name:
            meal_names.append(name)
        totals["calories"] += _coerce_int(item.get("calories", 0))
        totals["protein"] += _coerce_int(item.get("protein", 0))
        totals["carbs"] += _coerce_int(item.get("carbs", 0))
        totals["fats"] += _coerce_int(item.get("fats", 0))

    if meal_names:
        display = " + ".join(meal_names[:3])
        if len(meal_names) > 3:
            display += " + ..."
        totals["meal_name"] = display
    return totals


def parse_nutrition_json(raw_content: str) -> Dict[str, int | str]:
    parsed = _parse_nutrition_json(raw_content)
    if isinstance(parsed, list):
        parsed = _aggregate_list_payload(parsed)
    return {
        "meal_name": parsed.get("meal_name", "Unknown Meal"),
        "calories": _coerce_int(parsed.get("calories", 0)),
        "protein": _coerce_int(parsed.get("protein", 0)),
        "carbs": _coerce_int(parsed.get("carbs", 0)),
        "fats": _coerce_int(parsed.get("fats", 0)),
    }


load_dotenv()

DEFAULT_FOOD_DESCRIPTION = (
    "150 g grilled chicken breast seasoned with herbs, plus 1 cup steamed broccoli, "
    "a half cup cooked brown rice, and a drizzle (1 tablespoon) of extra virgin olive oil."
)

# Rough ground-truth values derived from standard nutrition references (USDA/FDA).
DEFAULT_GROUND_TRUTH = {
    "calories": 531,
    "protein": 53,
    "carbs": 34,
    "fats": 20,
}

RESPONSES_DEFAULT_MAX_TOKENS = 1200
RESPONSE_TOKEN_LIMIT_OVERRIDES: Dict[str, List[int]] = {
    "gpt-5-nano": [2048, 4096, 8192],
    "gpt-5-mini": [2048],
    "gpt-5": [2048, 4096, 8192],
    "o4": [2048],
}

SYSTEM_PROMPT = (
    "You are a nutrition expert. Analyze text descriptions of food and ingredients to "
    "estimate nutritional values. Parse quantities, ingredient names, and cooking "
    "methods. Use standard nutrition database knowledge to calculate totals. Generate "
    "a descriptive meal name based on the ingredients. Return only a JSON object with "
    "meal_name (string), calories, protein, carbs, and fats as integers (grams for "
    "macronutrients)."
)


@dataclass
class RunResult:
    model: str
    calories: int
    protein: int
    carbs: int
    fats: int
    meal_name: str
    duration_s: float


def build_client() -> OpenAI:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY environment variable is not set")
    return OpenAI(api_key=api_key)


def use_responses_api(model: str) -> bool:
    return model.startswith("o4") or model.startswith("gpt-5")


def extract_text_from_responses(response) -> str:
    text = getattr(response, "output_text", None)
    if text:
        return text

    segments = []
    for item in getattr(response, "output", []) or []:
        for block in getattr(item, "content", []) or []:
            block_text = getattr(block, "text", None)
            if block_text:
                segments.append(block_text)
    return "\n".join(segments)


def run_single_prompt(client: OpenAI, model: str, description: str) -> RunResult:
    start = time.perf_counter()
    user_prompt = (
        "Estimate the total nutritional content of this food description and give it a "
        "descriptive name: \"{}\". Return JSON format: {{\"meal_name\": \"descriptive name\", "
        "\"calories\": number, \"protein\": grams, \"carbs\": grams, \"fats\": grams}}"
    ).format(description)

    if use_responses_api(model):
        content = ""
        token_limits = get_response_token_limits(model)
        last_response = None
        for limit in token_limits:
            response = client.responses.create(
                model=model,
                input=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": user_prompt},
                ],
                max_output_tokens=limit,
            )
            last_response = response
            content = extract_text_from_responses(response).strip()
            if content:
                break
            incomplete = getattr(response, "incomplete_details", None)
            reason = getattr(incomplete, "reason", None) if incomplete else None
            if reason != "max_output_tokens":
                break

        if not content:
            status = getattr(last_response, "status", "unknown") if last_response else "unknown"
            reason = getattr(getattr(last_response, "incomplete_details", None), "reason", "unknown")
            raise RuntimeError(f"{model} returned no text (status={status}, reason={reason})")
    else:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_prompt},
            ],
            max_tokens=150,
        )
        content = (response.choices[0].message.content or "").strip()

    duration = time.perf_counter() - start
    parsed = parse_nutrition_json(content)
    return RunResult(
        model=model,
        meal_name=str(parsed["meal_name"]),
        calories=int(parsed["calories"]),
        protein=int(parsed["protein"]),
        carbs=int(parsed["carbs"]),
        fats=int(parsed["fats"]),
        duration_s=duration,
    )


def summarize_runs(runs: List[RunResult], truth: Dict[str, int]) -> Dict[str, Dict[str, float]]:
    if not runs:
        return {}

    nutrients = ["calories", "protein", "carbs", "fats"]
    summary: Dict[str, Dict[str, float]] = {}
    for nutrient in nutrients:
        values = [getattr(run, nutrient) for run in runs]
        summary[nutrient] = {
            "mean": statistics.mean(values),
            "range": max(values) - min(values),
            "mae": statistics.mean(abs(v - truth[nutrient]) for v in values),
        }

    summary["duration_s"] = {
        "mean": statistics.mean(run.duration_s for run in runs),
        "range": max(run.duration_s for run in runs) - min(run.duration_s for run in runs),
    }

    summary["aggregate_score"] = {
        "value": summary["calories"]["mae"]
        + 0.5 * (summary["protein"]["mae"] + summary["carbs"]["mae"] + summary["fats"]["mae"])
    }
    return summary


def format_summary_table(all_summaries: Dict[str, Dict[str, Dict[str, float]]]) -> str:
    header = (
        "Model".ljust(20)
        + " | MAE cal | Range cal | MAE protein | Range protein | MAE carbs | Range carbs | MAE fats | Range fats | Avg time (s)"
    )
    lines = [header, "-" * len(header)]
    for model, summary in all_summaries.items():
        line = (
            model.ljust(20)
            + f" | {summary['calories']['mae']:7.2f} | {summary['calories']['range']:9.2f}"
            + f" | {summary['protein']['mae']:11.2f} | {summary['protein']['range']:13.2f}"
            + f" | {summary['carbs']['mae']:8.2f} | {summary['carbs']['range']:10.2f}"
            + f" | {summary['fats']['mae']:7.2f} | {summary['fats']['range']:9.2f}"
            + f" | {summary['duration_s']['mean']:10.2f}"
        )
        lines.append(line)
    return "\n".join(lines)


def write_csv_report(
    path: str,
    summaries: Dict[str, Dict[str, Dict[str, float]]],
    detailed_runs: Dict[str, List[RunResult]],
) -> None:
    if not summaries:
        return

    directory = os.path.dirname(path)
    if directory:
        os.makedirs(directory, exist_ok=True)

    fieldnames = [
        "model",
        "run_count",
        "mae_calories",
        "mae_protein",
        "mae_carbs",
        "mae_fats",
        "range_calories",
        "range_protein",
        "range_carbs",
        "range_fats",
        "avg_duration_s",
        "duration_range_s",
        "aggregate_score",
    ]

    with open(path, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for model, summary in summaries.items():
            runs = detailed_runs.get(model, [])
            writer.writerow(
                {
                    "model": model,
                    "run_count": len(runs),
                    "mae_calories": f"{summary['calories']['mae']:.2f}",
                    "mae_protein": f"{summary['protein']['mae']:.2f}",
                    "mae_carbs": f"{summary['carbs']['mae']:.2f}",
                    "mae_fats": f"{summary['fats']['mae']:.2f}",
                    "range_calories": f"{summary['calories']['range']:.2f}",
                    "range_protein": f"{summary['protein']['range']:.2f}",
                    "range_carbs": f"{summary['carbs']['range']:.2f}",
                    "range_fats": f"{summary['fats']['range']:.2f}",
                    "avg_duration_s": f"{summary['duration_s']['mean']:.2f}",
                    "duration_range_s": f"{summary['duration_s']['range']:.2f}",
                    "aggregate_score": f"{summary['aggregate_score']['value']:.2f}",
                }
            )

    print(f"\nWrote CSV summary to {path}")


def run_benchmark(
    models: List[str], runs: int, description: str, truth: Dict[str, int]
) -> Tuple[Dict[str, Dict[str, Dict[str, float]]], Dict[str, List[RunResult]]]:
    client = build_client()
    summaries: Dict[str, Dict[str, Dict[str, float]]] = {}
    detailed_runs: Dict[str, List[RunResult]] = {model: [] for model in models}

    for model in models:
        print(f"\nRunning {runs} trial(s) for {model}...")
        for i in range(runs):
            try:
                result = run_single_prompt(client, model, description)
                detailed_runs[model].append(result)
                print(
                    f"  Trial {i + 1}: {result.calories} kcal, P{result.protein}/C{result.carbs}/F{result.fats} g "
                    f"({result.meal_name}) in {result.duration_s:.2f}s"
                )
            except Exception as exc:  # noqa: BLE001
                print(f"  Trial {i + 1} failed: {exc}")

        if detailed_runs[model]:
            summaries[model] = summarize_runs(detailed_runs[model], truth)
        else:
            print(f"  Skipping summary for {model}; no successful runs.")

    print("\nBenchmark summary (closer to zero is better):")
    if summaries:
        print(format_summary_table(summaries))
    else:
        print("  No successful runs to summarize.")

    ranked = [m for m in models if m in summaries]
    if ranked:
        ranked.sort(key=lambda m: summaries[m]["aggregate_score"]["value"])
        print("\nRanking (lowest aggregate score = best):")
        for idx, model in enumerate(ranked, start=1):
            score = summaries[model]["aggregate_score"]["value"]
            print(f"  {idx}. {model}: aggregate score {score:.2f}")
    else:
        print("\nNo ranking available (all runs failed).")

    return summaries, detailed_runs


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Benchmark OpenAI nutrition prompts across models")
    parser.add_argument(
        "--models",
        nargs="+",
        default=["gpt-4o-mini", "gpt-4o-mini-1"],
        help="Space-separated list of model IDs to test",
    )
    parser.add_argument(
        "--runs",
        type=int,
        default=3,
        help="Number of times to call each model",
    )
    parser.add_argument(
        "--description",
        type=str,
        default=DEFAULT_FOOD_DESCRIPTION,
        help="Food description prompt to analyze",
    )
    parser.add_argument("--truth-calories", type=int, help="Override ground-truth calories")
    parser.add_argument("--truth-protein", type=int, help="Override ground-truth protein (g)")
    parser.add_argument("--truth-carbs", type=int, help="Override ground-truth carbs (g)")
    parser.add_argument("--truth-fats", type=int, help="Override ground-truth fats (g)")
    parser.add_argument("--csv-output", type=str, help="Optional path to write summary CSV")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    truth = DEFAULT_GROUND_TRUTH.copy()
    if args.truth_calories is not None:
        truth["calories"] = args.truth_calories
    if args.truth_protein is not None:
        truth["protein"] = args.truth_protein
    if args.truth_carbs is not None:
        truth["carbs"] = args.truth_carbs
    if args.truth_fats is not None:
        truth["fats"] = args.truth_fats

    summaries, detailed_runs = run_benchmark(args.models, args.runs, args.description, truth)
    if args.csv_output and summaries:
        write_csv_report(args.csv_output, summaries, detailed_runs)
