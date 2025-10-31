import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_logger.dart';
import '../models/subscription.dart';

class SubscriptionService {
  // Production backend
  static const String _apiBaseUrl =
      'https://yapper-backend-789863392317.us-central1.run.app';

  // Local backend for testing (comment out for production)
  // static const String _apiBaseUrl = 'http://192.168.1.12:5001';

  /// Create a Stripe Checkout session
  /// Returns checkout URL and session ID
  Future<Map<String, String>> createCheckoutSession({
    required String userId,
    required String tier, // 'monthly' or 'yearly'
  }) async {
    try {
      AppLogger.debug(
          'Creating checkout session for user $userId, tier: $tier');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/subscription/create-checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'tier': tier,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Checkout session created: ${data['session_id']}');

        return {
          'checkout_url': data['checkout_url'] as String,
          'session_id': data['session_id'] as String,
        };
      } else {
        final error = response.statusCode == 500
            ? jsonDecode(response.body)['detail']
            : 'Failed to create checkout session: ${response.statusCode}';
        throw Exception(error);
      }
    } catch (e) {
      AppLogger.error('Create checkout session error', e);
      rethrow;
    }
  }

  /// Create a Stripe Customer Portal session
  /// Returns portal URL for managing subscription
  Future<String> createCustomerPortalSession({
    required String userId,
  }) async {
    try {
      AppLogger.debug('Creating customer portal session for user $userId');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/subscription/create-portal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Customer portal session created');

        return data['portal_url'] as String;
      } else {
        final error = response.statusCode == 500
            ? jsonDecode(response.body)['detail']
            : 'Failed to create portal session: ${response.statusCode}';
        throw Exception(error);
      }
    } catch (e) {
      AppLogger.error('Create portal session error', e);
      rethrow;
    }
  }

  /// Get current subscription status for a user
  /// Returns Subscription object
  Future<Subscription> getSubscriptionStatus({
    required String userId,
  }) async {
    try {
      AppLogger.debug('Getting subscription status for user $userId');

      final response = await http.get(
        Uri.parse('$_apiBaseUrl/subscription/status/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Subscription status: ${data['status']}');

        return Subscription.fromJson(data);
      } else {
        throw Exception(
            'Failed to get subscription status: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Get subscription status error', e);
      rethrow;
    }
  }

  /// Check if user has access (has active subscription or trial)
  Future<bool> hasAccess({required String userId}) async {
    try {
      final subscription = await getSubscriptionStatus(userId: userId);
      return subscription.hasAccess;
    } catch (e) {
      AppLogger.error('Check access error', e);
      return false;
    }
  }
}
