import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/subscription.dart';
import '../services/subscription_service.dart';
import '../core/app_logger.dart';
import 'auth_provider.dart';

part 'subscription_provider.g.dart';

/// Subscription state
class SubscriptionState {
  final Subscription? subscription;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.subscription,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Subscription service provider
@riverpod
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  return SubscriptionService();
}

/// Subscription state notifier
@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  SubscriptionState build() {
    // Auto-fetch subscription status when user is authenticated
    final userId = ref.watch(currentUserIdProvider);
    if (userId != null) {
      fetchSubscriptionStatus();
    }
    return const SubscriptionState();
  }

  /// Fetch current subscription status
  Future<void> fetchSubscriptionStatus() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = const SubscriptionState(
        subscription: Subscription(
          status: SubscriptionStatus.free,
          hasAccess: false,
        ),
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final subscription = await subscriptionService.getSubscriptionStatus();

      state = SubscriptionState(
        subscription: subscription,
        isLoading: false,
      );

      AppLogger.info('Subscription status loaded: ${subscription.status.name}');
    } catch (e) {
      AppLogger.error('Failed to fetch subscription status', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load subscription status',
      );
    }
  }

  /// Start subscription purchase flow
  Future<String?> startCheckout(SubscriptionTier tier) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final result = await subscriptionService.createCheckoutSession(
        tier: tier.name,
      );

      state = state.copyWith(isLoading: false);

      AppLogger.info('Checkout session created: ${result['session_id']}');
      return result['checkout_url'];
    } catch (e) {
      AppLogger.error('Failed to create checkout session', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start checkout',
      );
      return null;
    }
  }

  /// Open customer portal for subscription management
  Future<String?> openCustomerPortal() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final portalUrl = await subscriptionService.createCustomerPortalSession();

      state = state.copyWith(isLoading: false);

      AppLogger.info('Customer portal URL created');
      return portalUrl;
    } catch (e) {
      AppLogger.error('Failed to create portal session', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to open customer portal',
      );
      return null;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider to check if user has active subscription
@riverpod
bool hasActiveSubscription(HasActiveSubscriptionRef ref) {
  final subscriptionState = ref.watch(subscriptionNotifierProvider);
  return subscriptionState.subscription?.hasAccess ?? false;
}

/// Provider to get subscription status
@riverpod
SubscriptionStatus subscriptionStatus(SubscriptionStatusRef ref) {
  final subscriptionState = ref.watch(subscriptionNotifierProvider);
  return subscriptionState.subscription?.status ?? SubscriptionStatus.free;
}

/// Provider to get subscription tier
@riverpod
SubscriptionTier? subscriptionTier(SubscriptionTierRef ref) {
  final subscriptionState = ref.watch(subscriptionNotifierProvider);
  return subscriptionState.subscription?.tier;
}

/// Provider to get trial days remaining
@riverpod
int? trialDaysRemaining(TrialDaysRemainingRef ref) {
  final subscriptionState = ref.watch(subscriptionNotifierProvider);
  return subscriptionState.subscription?.trialDaysRemaining;
}
