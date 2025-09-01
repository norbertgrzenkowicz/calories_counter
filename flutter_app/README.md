# Food Scanner - Nutrition Tracking App

A Flutter application for tracking meals, calories, and nutritional intake using barcode scanning, manual entry, and AI-powered food recognition.

## Project Status

**Current State**: Development-Ready Application with Clean Architecture  
**Architecture**: Repository Pattern + Clean Architecture + Riverpod State Management  
**Test Coverage**: Model layer comprehensively tested, expanding to full coverage  
**Security**: Input sanitization and secure logging implemented  

## Features Implemented

### ✅ Core Architecture
- **Clean Architecture** with separation of concerns (domain/data/presentation layers)
- **Repository Pattern** for data access abstraction
- **Dependency Injection** using GetIt service locator
- **Result Pattern** for consistent error handling
- **Freezed Models** for immutable data structures
- **Riverpod** state management (partially migrated)

### ✅ Security & Quality
- **Input Sanitization** with comprehensive validation utilities
- **Secure Logging** replacing debug print statements
- **File Upload Validation** with security checks
- **Code Quality** tooling with very_good_analysis
- **Type Safety** with null safety compliance

### ✅ Data Management
- **Supabase Integration** for backend services
- **Local Storage** capabilities
- **Data Export** functionality for weight history
- **Nutrition Calculator** service
- **OpenFoodFacts API** integration

### ✅ User Interface
- **Authentication** (login/register screens)
- **Dashboard** with meal tracking
- **Barcode Scanner** for food identification
- **Calendar View** for historical data
- **Profile Management** with weight tracking
- **Settings** and export functionality

### ✅ Testing Framework
- **Unit Tests** for models and utilities
- **Test Helpers** for consistent test setup
- **Mocktail** integration for mocking
- **Model Testing** with edge case coverage

## Development Setup

### Prerequisites
- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0
- iOS development: Xcode and iOS Simulator
- Android development: Android Studio and Android SDK

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd flutter_app

# Install dependencies
flutter pub get

# Generate code for Freezed models
flutter packages pub run build_runner build

# Run the app (with environment variables)
flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### iOS Build & Install
```bash
# Build for iOS release
flutter build ios --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Install on connected iPhone
flutter install -d iPhone
```

### Environment Configuration
Create environment variables for Supabase configuration:
```bash
export SUPABASE_URL="your_supabase_project_url"
export SUPABASE_ANON_KEY="your_supabase_anon_key"
```

## Architecture Overview

The application follows Clean Architecture principles:

```
lib/
├── core/           # Cross-cutting concerns (DI, logging, environment)
├── domain/         # Business logic and entities
│   ├── entities/   # Core domain models
│   └── repositories/ # Abstract repository interfaces
├── data/           # Data layer implementations
│   └── repositories/ # Repository implementations
├── presentation/   # UI layer
│   ├── screens/    # Application screens
│   ├── widgets/    # Reusable UI components
│   ├── providers/  # Riverpod state management
├── services/       # External service integrations
├── models/         # Data transfer objects
└── utils/          # Utility functions and helpers
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/meal_test.dart
```

## Code Quality

```bash
# Analyze code
flutter analyze

# Generate code for Freezed/JSON serialization
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Documentation

- **[IMPLEMENTATION_ROADMAP.md](IMPLEMENTATION_ROADMAP.md)** - Development phases and milestones
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detailed architecture documentation
- **[BUGS.md](BUGS.md)** - Known issues and their resolution status
- **[REFACTOR.md](REFACTOR.md)** - Refactoring strategy and progress
- **[FLUTTER_QUALITY_TOOLS.md](FLUTTER_QUALITY_TOOLS.md)** - Quality tools and best practices

## Contributing

1. Follow the established architecture patterns
2. Ensure all new code has corresponding tests
3. Run `flutter analyze` before committing
4. Use Freezed for data models
5. Follow Repository pattern for data access
6. Use Result pattern for error handling

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **Backend**: Supabase
- **State Management**: Riverpod
- **Local Storage**: Shared Preferences
- **HTTP Client**: Built-in HTTP package
- **Testing**: flutter_test + mocktail
- **Code Generation**: Freezed + build_runner
- **Dependency Injection**: GetIt
