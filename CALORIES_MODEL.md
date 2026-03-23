# CALORIES_MODEL

## Purpose

This document is the implementation handoff for improving photo-based calorie and macronutrient estimation in Yapper.

The current solution is too simple:

- backend image analysis is a single LLM call in `backend/app.py`
- the response is a flat `{meal_name, calories, protein, carbs, fats}` object
- Flutter accepts the result as-is in both chat and the add-meal photo flow
- there is no confidence score, no clarification step, no item breakdown, and no durable way to refine a low-confidence image estimate

The feature to implement is a **sequential, clarification-aware photo analysis pipeline** that improves accuracy without breaking the existing app.

This is a v1 product spec and implementation guide. It is intentionally decision-complete so another coding LLM can execute it end to end without inventing policy.

## Product Outcome

After this feature ships:

- a user can send a meal photo and receive either:
  - a final structured estimate, or
  - a provisional estimate plus one high-impact clarification question
- a user can answer that clarification question and get a refined estimate for the same image
- the add-meal screen can run the same refinement flow inline
- chat can persist and recover the refinement state from existing `chat_messages.nutrition_data` JSONB without a Supabase schema migration

## Non-Goals

Do not do these in this iteration:

- no LiDAR or depth capture
- no USDA/FDC external integration
- no meals table migration
- no multi-question interview flow
- no full typed refactor of all chat persistence models
- no breaking changes to `/analyze_food`, `/analyze_food/image`, existing text analysis, or existing stored chat rows

## Current Repo Constraints

Use the current codebase shape instead of rewriting architecture:

- backend entrypoint: `backend/app.py`
- current image/text/audio client: `flutter_app/lib/services/chat_service.dart`
- direct photo analysis UI: `flutter_app/lib/screens/add_meal_screen.dart`
- live chat photo flow: `flutter_app/lib/screens/dashboard_screen.dart`
- chat rendering: `flutter_app/lib/widgets/chat_message_bubble.dart`
- chat persistence shape: `flutter_app/lib/models/chat_message.dart`
- `chat_messages.nutrition_data` is already JSONB and must be reused

Important:

- preserve old chat rows where `nutrition_data` only contains the flat legacy fields

## Target UX

### 1. Add Meal screen photo flow

Current behavior:

- user picks photo
- app calls image analysis
- app shows a flat result card
- user can accept it into the meal form

New behavior:

- user picks photo
- app calls image analysis
- app shows:
  - meal name
  - calories / protein / carbs / fats
  - confidence label
  - assumptions list
  - item breakdown when available
- if the response status is `needs_clarification`, show:
  - one clarification question
  - a short text field
  - `Refine estimate` button
  - `Use current estimate` button
- after refinement, replace the provisional analysis card with the refined result
- `Accept analysis` continues to fill the existing manual form fields only; it does not auto-save the meal

### 2. Chat image flow

Current behavior:

- user sends image
- app uploads media
- app sends image to backend
- AI response becomes a flat nutrition card
- user can add or discard

New behavior:

- user sends image
- backend returns either `complete` or `needs_clarification`
- if `complete`:
  - show final nutrition card
  - allow add/discard
- if `needs_clarification`:
  - show provisional nutrition card
  - show clarification question
  - disable add/discard for that provisional result
  - mark this image analysis as the active pending clarification in dashboard state
- the next user text message, if a clarification is pending, must be treated as clarification for that image, not as a generic text-only meal description
- after the clarification answer, call image analysis again for the same image with `context_text`
- save a new AI response message with the refined result
- clear the pending clarification state
- only the refined result should allow add/discard

Policy decision:

- if the user ignores a pending clarification and sends a new image, the old clarification session is abandoned client-side
- if the app reloads, detect the most recent unresolved `needs_clarification` AI message from stored chat rows and restore pending clarification state from its embedded metadata

## Backend Contract

Keep `POST /analyze_food/image` and `POST /analyze_food` working.

Extend the image request body to accept:

```json
{
  "image": "base64-optional",
  "image_url": "https-url-optional",
  "filename": "optional.jpg",
  "context_text": "optional user clarification"
}
```

Request rules:

- at least one of `image` or `image_url` must be present
- `context_text` is optional and is only for refinement of the same image
- if both `image` and `image_url` are present, prefer `image`

Return this response shape for image analysis:

```json
{
  "analysis_version": "v2",
  "status": "complete",
  "meal_name": "Chicken rice bowl",
  "calories": 640,
  "protein": 42,
  "carbs": 58,
  "fats": 24,
  "confidence": 0.74,
  "confidence_label": "medium",
  "estimation_method": "image_only",
  "clarifying_question": null,
  "assumptions": ["Assumed about 1 cup cooked rice", "Assumed 1 tbsp cooking oil"],
  "flags": ["mixed_dish", "hidden_fat_risk"],
  "items": [
    {
      "name": "grilled chicken",
      "portion_text": "about 150 g",
      "calories": 250,
      "protein": 46,
      "carbs": 0,
      "fats": 5,
      "confidence": 0.82
    }
  ]
}
```

Rules:

- keep `meal_name`, `calories`, `protein`, `carbs`, `fats` at the top level for backward compatibility
- `status` is either `complete` or `needs_clarification`
- `confidence` is a float from `0.0` to `1.0`
- `confidence_label` is `low`, `medium`, or `high`
- `estimation_method` is `image_only` or `image_plus_context`
- `clarifying_question` is required when `status=needs_clarification`, otherwise `null`
- `assumptions`, `flags`, and `items` must always be present, defaulting to empty arrays
- `items` max length is `6`
- item macros and calories are integers

Text and audio endpoints may remain flat internally, but their response model should also tolerate the new top-level fields so shared parsing stays simple.

## Backend Model Behavior

Implement a two-stage logical pipeline inside the backend. This can be coded as two helper functions and one final normalizer.

### Stage 1: Image understanding

The model must identify:

- visible food items
- likely portion cues
- likely hidden-calorie risks
- whether one clarification question would materially improve the estimate

Clarification trigger rule:

- ask one clarification question only if the answer could plausibly change:
  - total calories by more than `15%`, or
  - any macro by more than `20%`

Allowed question categories:

- cooking oil or butter
- sauce or dressing amount
- beverage type
- rice/pasta/bread amount when scale is ambiguous
- ingredient identity when two possibilities have materially different macros

Question rules:

- ask at most one question
- do not ask multipart questions
- do not ask generic “tell me more”
- if `context_text` is already present, do not ask another question in v1

### Stage 2: Nutrition synthesis

The model must produce:

- top-level meal totals
- itemized breakdown
- assumptions
- flags
- confidence

Reasoning rules:

- if `context_text` is present, trust it for hidden ingredients, cooking method, and sauces
- trust the image more than user text for visible relative portion size
- explicitly record assumptions instead of silently guessing
- treat beverages as separate items if visible
- do not fabricate brand-specific precision unless the image or user text makes the brand obvious

### Normalization rules

Implement server-side normalization after parsing model output:

- all macro and calorie values must be non-negative integers
- `confidence` must be clamped to `0.0..1.0`
- derive `confidence_label` from `confidence`
  - `< 0.45` => `low`
  - `0.45..0.74` => `medium`
  - `>= 0.75` => `high`
- if `items` exist, recompute top-level macro totals from items
- if calorie total differs from `4*protein + 4*carbs + 9*fats` by more than `60 kcal` or `10%`, replace calories with the macro-derived value and add flag `macro_calorie_normalized`
- if `status=needs_clarification` and `clarifying_question` is empty, downgrade to `complete`
- if `context_text` is present, force `estimation_method=image_plus_context`
- if `context_text` is absent, use `image_only`

## Prompting Rules

Do not keep the current free-form prompt-only approach.

Implementation requirements:

- move image-analysis prompt construction into a dedicated helper, not inline in route code
- use structured JSON output with explicit schema validation
- make the model configurable by environment variable

Environment variables:

- `OPENAI_FOOD_IMAGE_MODEL`, default `gpt-5-mini`
- `OPENAI_FOOD_TEXT_MODEL`, default `gpt-5-nano`

The image prompt must explicitly instruct the model to:

- identify each visible item separately
- estimate portions conservatively
- list assumptions
- avoid fake precision
- ask only one clarification question if it would materially improve accuracy
- return valid JSON only

## Persistence Rules

Do not add a Supabase migration for this feature.

Use existing `chat_messages.nutrition_data` JSONB to store the new fields. Also embed these metadata keys in image-response messages:

- `status`
- `clarifying_question`
- `confidence`
- `confidence_label`
- `analysis_version`
- `estimation_method`
- `assumptions`
- `flags`
- `items`
- `source_user_message_id`

`source_user_message_id` is the chat `message_id` of the originating image message. This is required so the dashboard can recover which image must be refined after an app reload.

Backward compatibility rules:

- old chat rows with only legacy flat nutrition keys must still render as `complete`
- `ChatMessage.fromSupabase` must not fail if new nested keys exist

## Flutter Data Model

Create a dedicated frontend analysis model instead of passing raw maps around every new codepath.

Add:

- `flutter_app/lib/models/food_analysis_result.dart`

That model must:

- parse both legacy flat responses and the new v2 response
- expose:
  - `status`
  - `mealName`
  - `calories`
  - `protein`
  - `carbs`
  - `fats`
  - `confidence`
  - `confidenceLabel`
  - `clarifyingQuestion`
  - `assumptions`
  - `flags`
  - `items`
  - `estimationMethod`
  - `analysisVersion`
- provide `toJson()` so chat persistence can continue storing JSON maps

Do not fully replace `ChatMessage.nutritionData` in this iteration. Keep storage as `Map<String, dynamic>` for compatibility, and convert to/from `FoodAnalysisResult` at service and UI boundaries.

## Sequential Implementation Order

Follow this order. Do not skip ahead.

### Step 1: Backend response model and parser

Files:

- `backend/app.py`
- create `backend/food_analysis.py`

Work:

- move prompt building and output normalization into `backend/food_analysis.py`
- extend `ImageRequest`
- define Pydantic response models for `FoodAnalysisItem` and `FoodAnalysisResponseV2`
- keep the old top-level fields
- implement parsing and normalization helpers

Stop and verify:

- old image requests still work with only `image`
- `/analyze_food` still proxies correctly
- a legacy flat response can still be parsed

### Step 2: Backend clarification-aware image analysis

Files:

- `backend/food_analysis.py`
- `backend/app.py`

Work:

- implement the two-stage image analysis logic
- if `context_text` is absent and clarification is needed, return provisional totals plus question
- if `context_text` is present, return final refined totals and never ask a second question
- support `image_url` input for refinement when the original local file is no longer available

Stop and verify:

- base64 image request works
- image URL request works
- a mixed dish can return `needs_clarification`
- a follow-up request with `context_text` returns `complete`

### Step 3: Benchmark and backend tests

Files:

- `backend/model_benchmark.py`
- add backend tests if missing

Work:

- update benchmark parsing for the new schema
- add tests for:
  - normalization
  - confidence label mapping
  - clarification question presence rules
  - legacy response compatibility
- keep existing `test_cases/` usage

Stop and verify:

- benchmark script still runs
- unit tests cover both legacy and v2 parsing

### Step 4: Flutter service layer

Files:

- `flutter_app/lib/models/food_analysis_result.dart`
- `flutter_app/lib/services/chat_service.dart`

Work:

- add typed parsing
- update `analyzeFoodFromImage` to accept optional `contextText`, optional `imageUrl`
- keep text/audio methods compatible
- return `FoodAnalysisResult` from image analysis call, then convert to JSON only where old storage still needs it

Stop and verify:

- existing text/audio analysis still compiles
- image analysis can parse both legacy and v2 payloads

### Step 5: Add Meal screen refinement flow

Files:

- `flutter_app/lib/screens/add_meal_screen.dart`

Work:

- replace raw analysis map handling with `FoodAnalysisResult`
- show confidence, assumptions, and item list
- if `needs_clarification`, show one inline text field and `Refine estimate`
- refinement request reuses the same selected photo and passes `contextText`
- keep `Use current estimate`
- `Accept analysis` still fills the current manual fields

Stop and verify:

- user can analyze a photo and accept immediately
- user can answer one clarification and get a refined result
- no regression in manual add flow or barcode flow

### Step 6: Chat clarification flow

Files:

- `flutter_app/lib/screens/dashboard_screen.dart`
- `flutter_app/lib/widgets/chat_message_bubble.dart`
- `flutter_app/lib/models/chat_message.dart`

Work:

- persist `source_user_message_id` in AI nutrition payloads
- add dashboard state for the active pending clarification
- when an unresolved image clarification exists, route the next user text message to image refinement instead of generic text analysis
- fetch the original image source from the source user message:
  - use stored Supabase public URL if present
  - otherwise fall back to local file path if still available
- render clarification question and provisional status in the chat bubble
- disable add/discard on provisional image analysis
- enable add/discard only on final `complete` results

Stop and verify:

- image -> provisional question -> text reply -> refined result works end to end
- app reload can recover the pending clarification from stored chat messages
- old chat history still renders

### Step 7: Frontend tests and manual QA

Files:

- add or update Flutter tests around parsing and widget behavior

Work:

- add model tests for `FoodAnalysisResult.fromJson`
- add widget tests for:
  - provisional analysis card
  - refined analysis card
  - add/discard disabled for provisional chat result
- run manual QA for both direct add and chat flows

Stop and verify:

- mixed dish image path works
- simple single-item meal can skip clarification
- no broken rendering for legacy chat rows

## Acceptance Criteria

The feature is complete only if all of these are true:

- existing flat nutrition consumers still work
- image analysis can accept either base64 image or image URL
- image analysis can return provisional estimates with one clarification question
- refinement reuses the same image and adds user context
- add-meal screen supports refinement inline
- chat supports pending clarification and refinement for image analysis
- provisional image results cannot be added directly from chat
- old chat rows and old backend response shapes still parse
- tests exist for parsing, normalization, and the provisional/final UI states

## QA Scenarios

Use these exact scenarios during implementation:

1. Simple meal:
   - grilled chicken breast on plain rice
   - expected result: `complete`, no clarification

2. Mixed dish with hidden calories:
   - rice, chicken, sauce, possible frying oil
   - expected result: `needs_clarification`

3. Clarification answer:
   - user answers: `about 1 tbsp oil and teriyaki sauce`
   - expected result: refined `complete` result with higher confidence

4. Chat recovery:
   - send image, receive clarification question, restart app
   - expected result: pending clarification can still be resolved

5. Legacy compatibility:
   - load old `nutrition_data` containing only flat keys

Implementation completed on branch `codex_calories_model_sequential`. Backend work lives in `backend/food_analysis.py` and `backend/app.py`, with parsing and normalization coverage in `backend/test_food_analysis.py` and benchmark parsing updated in `backend/model_benchmark.py`. Flutter now uses the typed analysis model in `flutter_app/lib/models/food_analysis_result.dart`, the updated service boundary in `flutter_app/lib/services/chat_service.dart`, inline refinement on `flutter_app/lib/screens/add_meal_screen.dart`, pending clarification recovery and routing in `flutter_app/lib/screens/dashboard_screen.dart`, and provisional/final chat rendering in `flutter_app/lib/widgets/chat_message_bubble.dart` plus `flutter_app/lib/widgets/chat_input_bar.dart`. Frontend parsing and chat-state coverage were added in `flutter_app/test/models/food_analysis_result_test.dart` and `flutter_app/test/widgets/chat_message_bubble_test.dart`.
   - expected result: UI renders as final `complete` result

## Implementation Notes

- keep route handlers thin
- move food-analysis logic out of `backend/app.py`
- do not introduce new database tables
- do not silently break existing response parsing
- do not block the user behind mandatory multi-step flows outside the single clarification step
- prefer additive changes over broad refactors

## Definition of Done

The feature is done when a user can:

- send a meal photo
- receive either a final estimate or one targeted clarification question
- answer that question
- receive a refined estimate for the same image
- add the final result to meals

without breaking the existing text, audio, barcode, and manual entry flows.

---

## Implementation Record

### Completed: 2026-03-21

All seven steps of the sequential implementation were completed on branch `codex_calories_model_sequential`.

### What was done and where

#### Backend

**`backend/food_analysis.py`** (new file)
- Two-stage image analysis pipeline via `analyze_image()`.
- Structured system prompt with explicit per-item analysis, conservative portion estimation, single-question clarification policy.
- `_normalize_result()` applies all spec normalization rules: non-negative ints, confidence clamping, confidence_label derivation, items-based total recompute, macro-calorie consistency check with `macro_calorie_normalized` flag, clarification downgrade when question is missing, `context_text` forces `complete` + `image_plus_context`.
- `analyze_text()` thin wrapper for text analysis using `OPENAI_FOOD_TEXT_MODEL` env var.
- Model configurability: `OPENAI_FOOD_IMAGE_MODEL` (default `gpt-5-mini`), `OPENAI_FOOD_TEXT_MODEL` (default `gpt-5-nano`).

**`backend/app.py`** (updated)
- `ImageRequest` extended with `image_url` and `context_text`.
- `FoodAnalysisItem` and `FoodAnalysisResponseV2` Pydantic models.
- `/analyze_food/image` now returns full v2 response via `food_analysis.analyze_image()`.
- `/analyze_food/text` and `/analyze_food/audio` return flat `FoodAnalysisResponseFlat` (unchanged behavior).
- `/analyze_food` legacy endpoint still proxies to image analysis.
- Audio transcription delegated to `food_analysis.analyze_text()`.
- `parse_nutrition_json()` kept for benchmark compatibility.

**`backend/model_benchmark.py`** (updated)
- `parse_nutrition_json()` now handles v2 responses with `items` list by summing item-level totals.

**`backend/test_food_analysis.py`** (new file)
- 20 unit tests covering: confidence label mapping (all boundaries), clarification question rules (present/missing/empty/context override), normalization (negative values, items cap, total recompute, macro-calorie flag, tolerance), legacy flat dict compatibility, analysis_version field.

#### Flutter

**`flutter_app/lib/models/food_analysis_result.dart`** (new file)
- Typed model `FoodAnalysisResult` with `fromJson()` (handles both legacy flat and v2), `toJson()`, `toLegacyMap()`.
- Nested `FoodAnalysisItem` with own `fromJson()`/`toJson()`.
- `isComplete` and `needsClarification` convenience getters.

**`flutter_app/lib/services/chat_service.dart`** (updated)
- `analyzeFoodFromImage()` now accepts `contextText` and returns `FoodAnalysisResult`.
- New `refineFoodFromImageUrl()` for post-reload refinement via stored URL.
- Text/audio methods unchanged (still return `Map<String, dynamic>`).

**`flutter_app/lib/screens/add_meal_screen.dart`** (updated)
- `_analysisResult` is now `FoodAnalysisResult?` instead of raw map.
- `_buildAnalysisCard()` shows meal name, macros, confidence badge, assumptions list, item breakdown.
- For `needs_clarification`: inline answer text field, `Refine estimate` button (calls `_analyzePhoto(contextText:)`), `Use current estimate` button.
- `Accept & Fill Values` button shown only for `complete` results.
- Clarification controller disposed cleanly.

**`flutter_app/lib/models/chat_message.dart`** (updated)
- Added `sourceUserMessageId` field.
- `fromSupabase()` restores it from `nutritionData['source_user_message_id']`.
- `copyWith()` updated.

**`flutter_app/lib/widgets/chat_message_bubble.dart`** (updated)
- New `onAnswerClarification` callback.
- `_isProvisional` getter reads `nutritionData['status'] == 'needs_clarification'`.
- `_buildAIMessage()` renders provisional header (yellow, "NEEDS CLARIFICATION" badge), clarifying question block with "Answer this question" button.
- Add/discard buttons and X button hidden for provisional messages.

**`flutter_app/lib/screens/dashboard_screen.dart`** (updated)
- `_pendingClarificationAiMessageId` state tracks active clarification session.
- `_handleSendText()` routes to `_handleSendClarification()` when clarification pending.
- `_handleSendClarification()`: adds user text as chat message, calls `_callImageRefinement()`, creates refined AI message with `source_user_message_id` embedded in `nutritionData`, clears pending state.
- `_callImageRefinement()`: prefers local file, falls back to stored URL via `refineFoodFromImageUrl()`.
- `_handleSendImage()`: embeds `source_user_message_id` in nutrition data, sets `_pendingClarificationAiMessageId` if provisional.
- `_recoverPendingClarification()`: called after loading chat messages to restore pending state from the most recent unresolved `needs_clarification` AI message.
- `ChatMessageBubble` instances pass `onAnswerClarification` for the active provisional message; `onAddToMeals` and `onDiscard` are `null` for provisional messages.

**`flutter_app/test/models/food_analysis_result_test.dart`** (new file)
- 9 tests: v2 complete parsing, needs_clarification parsing, legacy flat compat, negative value clamping, confidence clamping, toJson round-trip, toLegacyMap fields, item parsing.

### Test results

- Backend: 20/20 passed (`pytest test_food_analysis.py`)
- Flutter model: 9/9 passed (`flutter test test/models/food_analysis_result_test.dart`)
- No compilation errors on all modified/created Flutter files
