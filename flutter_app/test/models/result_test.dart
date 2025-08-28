import 'package:flutter_test/flutter_test.dart';
import '../../lib/domain/entities/result.dart';

void main() {
  group('Result Pattern', () {
    test('creates success result', () {
      // Arrange & Act
      const result = Result.success('test data');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals('test data'));
      expect(result.errorOrNull, isNull);
    });

    test('creates failure result', () {
      // Arrange & Act
      const error = AppError.validation('Invalid input');
      const result = Result<String>.failure(error);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, equals(error));
    });

    test('when handles success result', () {
      // Arrange
      const result = Result.success('test');

      // Act
      final value = result.when(
        success: (data) => data.toUpperCase(),
        failure: (_) => 'error',
      );

      // Assert
      expect(value, equals('TEST'));
    });

    test('when handles failure result', () {
      // Arrange
      const error = AppError.server('Server error');
      const result = Result<String>.failure(error);

      // Act
      final value = result.when(
        success: (data) => data.toUpperCase(),
        failure: (_) => 'error',
      );

      // Assert
      expect(value, equals('error'));
    });

    test('flatMap success result', () {
      // Arrange
      const result = Result.success(5);

      // Act
      final flatMapped =
          result.flatMap((value) => Result.success(value.toString()));

      // Assert
      expect(flatMapped.isSuccess, isTrue);
      expect(flatMapped.dataOrNull, equals('5'));
    });

    test('flatMap failure result unchanged', () {
      // Arrange
      const error = AppError.network('Network error');
      const result = Result<int>.failure(error);

      // Act
      final flatMapped =
          result.flatMap((value) => Result.success(value.toString()));

      // Assert
      expect(flatMapped.isFailure, isTrue);
      expect(flatMapped.errorOrNull, equals(error));
    });
  });

  group('AppError Types', () {
    test('creates network error', () {
      const error = AppError.network('Connection failed', statusCode: 503);
      expect(error, isA<NetworkError>());
    });

    test('creates authentication error', () {
      const error = AppError.authentication('Invalid credentials');
      expect(error, isA<AuthenticationError>());
    });

    test('creates validation error', () {
      const error = AppError.validation('Required field missing');
      expect(error, isA<ValidationError>());
    });

    test('creates not found error', () {
      const error = AppError.notFound('Resource not found');
      expect(error, isA<NotFoundError>());
    });

    test('creates server error', () {
      const error = AppError.server('Internal server error', statusCode: 500);
      expect(error, isA<ServerError>());
    });

    test('creates unknown error', () {
      const error = AppError.unknown('Unexpected error');
      expect(error, isA<UnknownError>());
    });
  });
}
