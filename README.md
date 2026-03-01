# Yapper

An AI-powered food tracking app built with Flutter and FastAPI. Users can log meals via text, audio, or barcode scanning, track weight, and view nutrition data.

## Current Status

MVP with core features implemented. Stripe integration complete but paywall enforcement not yet wired. Built for iOS and Android.

### Working Features

- User authentication (email/password via Supabase JWT)
- Meal logging via text chat and audio input
- Barcode scanning with product cache (OpenFoodFacts fallback)
- Manual meal entry with input validation
- Weight tracking with charts
- Calendar view of meal history
- Stripe subscription backend (checkout, webhooks, customer portal)
- Data export (PDF/CSV)
- Personalized nutrition targets in profile

### Known Issues

- Paywall exists but not enforced (free users have unlimited access)
- Two dashboard implementations (old one is live, Riverpod version is unused)
- Photo analysis API exists but UI doesn't use it
- No crash reporting
- No offline support (fully network-dependent)
- Account deletion doesn't actually delete data

## Architecture

```
yapper/
├── flutter_app/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── repositories/
│   │   └── widgets/
│   └── pubspec.yaml
│
├── backend/
│   ├── app.py
│   └── requirements.txt
│
└── database/ (Supabase PostgreSQL)
```

## Tech Stack

**Frontend:**
- Flutter 3.0+
- Dart
- Riverpod (state management)
- FL Chart (data visualization)
- Mobile Scanner (barcode scanning)

**Backend:**
- Python 3.8+
- FastAPI
- OpenAI GPT-4 Vision API
- Uvicorn

**Infrastructure:**
- Supabase (PostgreSQL, auth, storage)
- Stripe (subscriptions)
- OpenFoodFacts API (barcode lookup)

## Setup

### Prerequisites
- Flutter SDK 3.0+
- Python 3.8+
- OpenAI API key
- Supabase project
- Stripe account (test mode)

### Backend

```bash
cd backend
pip install -r requirements.txt
export OPENAI_API_KEY=your_key
python app.py
```

### Flutter App

```bash
cd flutter_app
flutter pub get
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### iOS Release Build

```bash
flutter build ios --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY && flutter install -d iPhone
```

## Environment Variables

Backend (.env):
```
OPENAI_API_KEY=your_openai_key
```

Flutter (--dart-define flags):
```
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Next Steps

1. Enforce paywall (gate features behind subscription check)
2. Switch to Riverpod dashboard
3. Add Sentry crash reporting
4. Wire photo capture to existing analysis API
5. Implement real account deletion
