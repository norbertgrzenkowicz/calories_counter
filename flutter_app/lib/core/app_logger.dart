import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Secure application logging service
/// 
/// Provides production-safe logging that prevents sensitive data exposure
/// in release builds while maintaining useful debug information in development.
class AppLogger {
  static final Logger _logger = Logger(
    level: kReleaseMode ? Level.warning : Level.debug,
    printer: kReleaseMode ? SimplePrinter() : PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  /// Log debug information (development only)
  static void debug(String message) {
    if (kDebugMode) {
      _logger.d(message);
      developer.log(message, name: 'APP_DEBUG');
    }
  }

  /// Log informational messages
  static void info(String message) {
    _logger.i(message);
    if (kDebugMode) {
      developer.log(message, name: 'APP_INFO');
    }
  }

  /// Log warning messages
  static void warning(String message) {
    _logger.w(message);
    developer.log(message, name: 'APP_WARNING');
  }

  /// Log error messages with optional exception and stack trace
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    developer.log(
      message,
      error: error,
      stackTrace: stackTrace,
      name: 'APP_ERROR',
    );
  }

  /// Log user actions without exposing sensitive data
  /// 
  /// NEVER include user IDs, emails, or personal information
  static void logUserAction(String action) {
    info('User action: $action');
  }

  /// Log API calls without exposing sensitive data
  /// 
  /// NEVER include API keys, tokens, or response data containing personal info
  static void logApiCall(String method, String endpoint, [int? statusCode]) {
    final message = statusCode != null 
        ? '$method $endpoint -> $statusCode'
        : '$method $endpoint';
    debug('API: $message');
  }

  /// Log navigation events
  static void logNavigation(String from, String to) {
    debug('Navigation: $from -> $to');
  }

  /// Log performance metrics
  static void logPerformance(String operation, Duration duration) {
    debug('Performance: $operation took ${duration.inMilliseconds}ms');
  }
}