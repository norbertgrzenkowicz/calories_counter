import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// Result pattern for consistent error handling throughout the application
///
/// This pattern allows us to handle success and failure cases in a type-safe way
/// without throwing exceptions. All repository methods should return Result<T>
/// to ensure consistent error handling.
@freezed
class Result<T> with _$Result<T> {
  /// Success case containing the expected data
  const factory Result.success(T data) = Success<T>;

  /// Failure case containing error information
  const factory Result.failure(AppError error) = Failure<T>;
}

/// Application error types for better error categorization
@freezed
class AppError with _$AppError {
  /// Network-related errors (no internet, timeout, server errors)
  const factory AppError.network(String message, {int? statusCode}) =
      NetworkError;

  /// Authentication and authorization errors
  const factory AppError.authentication(String message) = AuthenticationError;

  /// Validation errors (invalid input, constraint violations)
  const factory AppError.validation(String message,
      {Map<String, String>? fieldErrors}) = ValidationError;

  /// Data not found errors
  const factory AppError.notFound(String message) = NotFoundError;

  /// Conflict errors (duplicate data, concurrent modification)
  const factory AppError.conflict(String message) = ConflictError;

  /// Server errors (500, 503, etc.)
  const factory AppError.server(String message, {int? statusCode}) =
      ServerError;

  /// Unknown/unexpected errors
  const factory AppError.unknown(String message, {Object? exception}) =
      UnknownError;

  /// Cached data is stale and couldn't be refreshed
  const factory AppError.staleData(String message) = StaleDataError;
}

/// Extension methods for easier Result handling
extension ResultExtensions<T> on Result<T> {
  /// Returns true if this is a success result
  bool get isSuccess => when(
        success: (_) => true,
        failure: (_) => false,
      );

  /// Returns true if this is a failure result
  bool get isFailure => !isSuccess;

  /// Returns the data if success, null if failure
  T? get dataOrNull => when(
        success: (data) => data,
        failure: (_) => null,
      );

  /// Returns the error if failure, null if success
  AppError? get errorOrNull => when(
        success: (_) => null,
        failure: (error) => error,
      );

  /// Maps the success value to a new type
  Result<R> map<R>(R Function(T) mapper) => when(
        success: (data) => Result.success(mapper(data)),
        failure: (error) => Result.failure(error),
      );

  /// Flat maps the success value to a new Result
  Result<R> flatMap<R>(Result<R> Function(T) mapper) => when(
        success: mapper,
        failure: (error) => Result.failure(error),
      );
}
