# AGENTS.md

This file is for agentic coding assistants working in this repo. It summarizes how to
build, lint, test, and follow the local conventions. Keep changes minimal and aligned
with existing architecture and tooling.

## Repo Layout
- `flutter_app/` Flutter mobile app (Dart, Riverpod, Freezed, GetIt, Clean Architecture).
- `backend/` FastAPI-based services and Stripe subscription routes.

## Global Notes
- Prefer minimal, targeted changes; do not reformat unrelated files.
- Do not commit secrets; `.env` files are not for version control.
- Environment variables used in this repo:
  - `SUPABASE_URL`, `SUPABASE_ANON_KEY` (Flutter app)
  - `OPENAI_API_KEY` (backend)

## Flutter (flutter_app)

### Build / Run
- Install deps: `flutter pub get`
- Run app: `flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY`
- Build iOS + install (from repo instructions):
  `flutter build ios --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY && flutter install -d iPhone`

### Lint / Format
- Static analysis (very_good_analysis rules): `flutter analyze`
- Format Dart code: `flutter format .`

### Code Generation
- Freezed/JSON + Riverpod generator:
  - `flutter packages pub run build_runner build --delete-conflicting-outputs`

### Tests
- All tests: `flutter test`
- With coverage: `flutter test --coverage`
- Single test file: `flutter test test/models/meal_test.dart`
- Single test by name: `flutter test --plain-name "<test name substring>"`

## Backend (backend)

### Install / Run
- Install deps: `pip install -r requirements.txt`
- Run local API server: `python app.py`
- Cloud Functions entrypoint (for deployment): `main.py` uses `functions_framework`

### Lint / Format / Tests
- No Python lint/test tooling is declared in this repo. If you add tests or linting,
  document the command in this file and keep it lightweight.

## Cursor / Copilot Rules
- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` files were found.

## Coding Style Guidelines

### Dart / Flutter
- Follow Clean Architecture: domain/data/presentation separation and repository pattern.
- Use Riverpod for state management and GetIt for dependency injection.
- Use Freezed + JSON serialization for immutable models.
- Prefer null-safe APIs and avoid dynamic where possible.
- Use the Result pattern for error handling; avoid throwing across layers.
- Input sanitization and secure logging are preferred over `print` in app code.
- Respect `analysis_options.yaml`:
  - strict-casts, strict-inference, strict-raw-types enabled.
  - generated files excluded from analysis (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`).

#### Imports
- Group imports in standard Dart order: `dart:` then `package:` then relative.
- Avoid unused imports; keep import lists minimal.

#### Formatting / Naming
- Keep line length reasonable; `lines_longer_than_80_chars` is disabled but avoid
  overly long lines when it hurts readability.
- Use lower_snake_case for file names, UpperCamelCase for types, lowerCamelCase for
  variables/functions, and ALL_CAPS for constants.

#### Error Handling
- Validate input early (UI and service boundaries).
- Return Result/Failure types instead of exceptions for recoverable conditions.
- Log errors with the app logging utility, not `print`.

### Python (backend)
- Follow PEP 8 formatting and import ordering (stdlib, third-party, local).
- Prefer type hints for new functions and data structures.
- Use FastAPI conventions: Pydantic models for request/response schemas.
- Use `HTTPException` for user-facing errors and log internal errors with context.
- Keep endpoints small; move reusable logic into helper functions.

## Architectural Conventions
- Keep Flutter domain entities free of UI framework dependencies.
- Repository interfaces live in `lib/domain/repositories` and implementations in `lib/data`.
- Services for external integrations live under `lib/services`.
- UI widgets stay in `lib/presentation` and `lib/widgets`.

## When Adding New Code
- Prefer consistency with existing patterns over inventing new abstractions.
- Add tests for new domain logic or utilities when feasible.
- Update this file if you add new commands, tools, or rules.
