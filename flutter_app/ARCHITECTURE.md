# Food Scanner App - Architecture Documentation

## Overview

The Food Scanner application follows **Clean Architecture** principles combined with the **Repository Pattern** to ensure maintainable, testable, and scalable code. This architecture separates concerns across distinct layers, enabling independent development, testing, and modification of each component.

## Architecture Principles

### 1. Separation of Concerns
Each layer has a specific responsibility and communicates through well-defined interfaces.

### 2. Dependency Inversion
Higher-level modules don't depend on lower-level modules. Both depend on abstractions.

### 3. Single Responsibility
Each class and module has one reason to change.

### 4. Testability
Each layer can be tested in isolation using dependency injection and mocking.

## Layer Structure

```
lib/
├── core/                   # Cross-cutting concerns
│   ├── app_logger.dart     # Secure logging framework
│   ├── environment.dart    # Environment configuration
│   └── service_locator.dart # Dependency injection setup
├── domain/                 # Business logic (innermost layer)
│   ├── entities/          # Core business models
│   │   └── result.dart    # Result pattern for error handling
│   └── repositories/      # Abstract repository interfaces
│       ├── auth_repository.dart
│       ├── meal_repository.dart
│       └── profile_repository.dart
├── data/                  # Data access implementations
│   └── repositories/      # Repository implementations
│       ├── auth_repository_impl.dart
│       ├── meal_repository_impl.dart
│       └── profile_repository_impl.dart
├── presentation/          # UI layer (outermost layer)
│   ├── screens/          # Application screens
│   ├── widgets/          # Reusable UI components
│   └── providers/        # Riverpod state management
├── services/             # External service integrations
├── models/               # Data Transfer Objects (DTOs)
├── utils/                # Utility functions and helpers
└── main.dart            # Application entry point
```

## Layer Responsibilities

### Core Layer (`lib/core/`)
**Purpose**: Cross-cutting concerns that are used across all layers.

**Components**:
- **`service_locator.dart`**: Dependency injection container using GetIt
- **`app_logger.dart`**: Secure logging framework
- **`environment.dart`**: Environment configuration management

**Rules**:
- No dependencies on other application layers
- Provides foundational services
- Contains configuration and setup logic

### Domain Layer (`lib/domain/`)
**Purpose**: Contains business logic and entities. This is the core of the application.

**Components**:
- **`entities/`**: Core business models (Result, AppError)
- **`repositories/`**: Abstract interfaces for data access

**Rules**:
- No dependencies on external frameworks (except Dart core)
- Contains business rules and entities
- Defines contracts for data access
- Independent of UI and data sources

**Example**:
```dart
// domain/repositories/meal_repository.dart
abstract class MealRepository {
  Future<Result<List<Meal>>> getMealsByDate(DateTime date, String userId);
  Future<Result<Meal>> addMeal(Meal meal);
  Future<Result<void>> deleteMeal(String mealId);
  Future<Result<Meal>> updateMeal(Meal meal);
}
```

### Data Layer (`lib/data/`)
**Purpose**: Implements data access logic and external data source communication.

**Components**:
- **`repositories/`**: Concrete implementations of domain repository interfaces

**Rules**:
- Implements domain repository interfaces
- Handles data transformation (DTO ↔ Entity mapping)
- Manages external data sources (APIs, databases)
- Contains caching logic

**Example**:
```dart
// data/repositories/meal_repository_impl.dart
class MealRepositoryImpl implements MealRepository {
  final SupabaseService _supabaseService;
  
  MealRepositoryImpl(this._supabaseService);
  
  @override
  Future<Result<List<Meal>>> getMealsByDate(DateTime date, String userId) async {
    try {
      final meals = await _supabaseService.getMealsByDate(date, userId);
      return Result.success(meals);
    } catch (e) {
      return Result.failure(AppError.network(e.toString()));
    }
  }
}
```

### Presentation Layer (`lib/presentation/`)
**Purpose**: Handles user interface and user interactions.

**Components**:
- **`screens/`**: Full-screen UI components
- **`widgets/`**: Reusable UI components  
- **`providers/`**: Riverpod state management

**Rules**:
- Depends on domain layer through repository interfaces
- Manages UI state using Riverpod
- Handles user input validation
- Displays data and errors to users

**Example**:
```dart
// providers/meals_provider.dart
@riverpod
class MealsNotifier extends _$MealsNotifier {
  @override
  Future<List<Meal>> build(DateTime date) async {
    final repository = ref.read(mealRepositoryProvider);
    final result = await repository.getMealsByDate(date, getCurrentUserId());
    
    return result.when(
      success: (meals) => meals,
      failure: (error) => throw error,
    );
  }
}
```

### Services Layer (`lib/services/`)
**Purpose**: External service integrations and third-party API communication.

**Components**:
- **`supabase_service.dart`**: Backend API communication
- **`openfoodfacts_service.dart`**: Food database API
- **`nutrition_calculator_service.dart`**: Nutrition calculations
- **`profile_service.dart`**: User profile management

**Rules**:
- Handles external API communication
- Provides service abstractions
- Manages authentication and sessions
- Contains service-specific error handling

### Models Layer (`lib/models/`)
**Purpose**: Data Transfer Objects for external API communication.

**Components**:
- Freezed-generated immutable data classes
- JSON serialization/deserialization
- Data validation and transformation methods

**Rules**:
- Immutable data structures using Freezed
- Contains serialization logic
- Handles data transformation between layers
- No business logic

### Utils Layer (`lib/utils/`)
**Purpose**: Utility functions and helper classes.

**Components**:
- **`input_sanitizer.dart`**: Input validation and sanitization
- **`file_upload_validator.dart`**: File security validation

**Rules**:
- Stateless utility functions
- No dependencies on other layers
- Reusable across the application

## Data Flow

### 1. User Interaction Flow
```
User Input → Screen → Provider → Repository → Service → External API
                ↓         ↓          ↓          ↓           ↓
            UI State ← Provider ← Repository ← Service ← API Response
```

### 2. Error Handling Flow
```
External API Error → Service → Repository → Result.failure() → Provider → UI Error State
```

### 3. State Management Flow
```
Repository Data → Riverpod Provider → Consumer Widget → UI Update
```

## Dependency Injection

The application uses **GetIt** as a service locator for dependency injection:

```dart
// core/service_locator.dart
Future<void> configureDependencies() async {
  // Core services
  getIt.registerLazySingleton<SupabaseService>(SupabaseService.new);
  
  // Domain services  
  getIt.registerLazySingleton<ProfileService>(ProfileService.new);
  getIt.registerLazySingleton<UserService>(UserService.new);
  
  // Repository implementations are provided via Riverpod providers
}
```

## State Management Strategy

### Riverpod Integration
- **Providers**: Generate type-safe providers using `riverpod_generator`
- **State**: Managed through Riverpod's reactive system
- **Loading States**: Handled via `AsyncValue<T>`
- **Error States**: Propagated through Result pattern

### Provider Structure
```dart
// Repository providers
@riverpod
MealRepository mealRepository(MealRepositoryRef ref) {
  return MealRepositoryImpl(getIt<SupabaseService>());
}

// Data providers
@riverpod
class MealsNotifier extends _$MealsNotifier {
  @override
  Future<List<Meal>> build(DateTime date) async {
    // Implementation
  }
}
```

## Error Handling Strategy

### Result Pattern
All data operations return `Result<T>` objects:

```dart
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppError error) = Failure<T>;
}

@freezed  
class AppError with _$AppError {
  const factory AppError.network(String message, {int? statusCode}) = NetworkError;
  const factory AppError.authentication(String message) = AuthenticationError;
  const factory AppError.validation(String message) = ValidationError;
  // ... other error types
}
```

### Error Propagation
1. **Service Layer**: Catches exceptions, converts to AppError
2. **Repository Layer**: Returns Result<T> with success/failure
3. **Provider Layer**: Handles Result, updates UI state
4. **UI Layer**: Displays error messages to user

## Security Implementation

### 1. Input Sanitization
All user input is sanitized using `InputSanitizer` utility:
```dart
final sanitizedName = InputSanitizer.sanitizeMealName(userInput);
final validCalories = InputSanitizer.sanitizeCalories(calorieInput);
```

### 2. File Upload Security
File uploads are validated using `FileUploadValidator`:
```dart
final validationResult = FileUploadValidator.validateImage(selectedFile);
if (validationResult.isFailure) {
  // Handle validation error
}
```

### 3. Secure Logging
Production-safe logging using custom logger:
```dart
AppLogger.info('User action completed');
AppLogger.error('Operation failed', error: exception);
// Never logs sensitive data in production
```

### 4. Environment Configuration
Sensitive configuration via build-time variables:
```dart
abstract class Environment {
  static String get supabaseUrl => 
    const String.fromEnvironment('SUPABASE_URL');
  static String get supabaseAnonKey => 
    const String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

## Testing Strategy

### Test Structure
```
test/
├── unit/          # Pure logic testing
├── widget/        # UI component testing  
├── integration/   # End-to-end flows
└── helpers/       # Test utilities and mocks
```

### Testing Patterns
1. **Unit Tests**: Test business logic in isolation
2. **Widget Tests**: Test UI components with mocked dependencies
3. **Integration Tests**: Test complete user flows
4. **Repository Tests**: Test data layer with mocked services

### Mock Implementation
```dart
class MockMealRepository extends Mock implements MealRepository {}

// Test setup
setUp(() {
  mockRepository = MockMealRepository();
  when(() => mockRepository.getMealsByDate(any(), any()))
      .thenAnswer((_) async => Result.success(testMeals));
});
```

## Code Generation

The project uses several code generation tools:

### Build Runner Commands
```bash
# Generate all code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Clean and rebuild
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Generated Files
- **`.freezed.dart`**: Immutable data classes
- **`.g.dart`**: JSON serialization
- **`.gr.dart`**: Auto routing (future implementation)

## Development Workflow

### 1. Feature Development
1. Define domain entities and repository interfaces
2. Implement repository in data layer
3. Create Riverpod providers for state management
4. Build UI components in presentation layer
5. Write comprehensive tests

### 2. Code Quality Checks
```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Generate code
flutter packages pub run build_runner build
```

### 3. Security Review
- Validate all user inputs using sanitization utilities
- Ensure no sensitive data in logs
- Review file upload security
- Check environment variable usage

## Performance Considerations

### 1. Widget Optimization
- Use `const` constructors where possible
- Implement proper `Key` usage for list items
- Minimize widget rebuilds with targeted state management

### 2. Memory Management
- Proper controller disposal (automated with hooks or manual)
- Efficient list rendering with `ListView.builder`
- Image caching and optimization

### 3. Network Optimization
- Request caching at repository level
- Offline-first data strategy (planned)
- Background sync capabilities (planned)

## Future Enhancements

### Planned Architecture Improvements
1. **Use Cases Layer**: Add business logic abstraction
2. **Caching Strategy**: Implement local database with Isar
3. **Offline Support**: Background sync and local-first approach
4. **Event Sourcing**: Consider for audit trail requirements

### Migration Roadmap
1. **Phase 3**: Complete Riverpod migration for all screens
2. **Phase 4**: Add local database with caching
3. **Phase 5**: Implement offline-first strategy
4. **Phase 6**: Add comprehensive monitoring and analytics

This architecture provides a solid foundation for scaling the application while maintaining code quality, security, and performance standards.