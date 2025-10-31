// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionServiceHash() =>
    r'ba116c362c7775f517fbaf0becbcd5055772ba18';

/// Subscription service provider
///
/// Copied from [subscriptionService].
@ProviderFor(subscriptionService)
final subscriptionServiceProvider =
    AutoDisposeProvider<SubscriptionService>.internal(
  subscriptionService,
  name: r'subscriptionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionServiceRef = AutoDisposeProviderRef<SubscriptionService>;
String _$hasActiveSubscriptionHash() =>
    r'df11e8cb6fb588e63257c6c0c74cf96fd2f23c56';

/// Provider to check if user has active subscription
///
/// Copied from [hasActiveSubscription].
@ProviderFor(hasActiveSubscription)
final hasActiveSubscriptionProvider = AutoDisposeProvider<bool>.internal(
  hasActiveSubscription,
  name: r'hasActiveSubscriptionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasActiveSubscriptionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasActiveSubscriptionRef = AutoDisposeProviderRef<bool>;
String _$subscriptionStatusHash() =>
    r'13bb14040dda0f1fbff50497049adccf0c0aeefd';

/// Provider to get subscription status
///
/// Copied from [subscriptionStatus].
@ProviderFor(subscriptionStatus)
final subscriptionStatusProvider =
    AutoDisposeProvider<SubscriptionStatus>.internal(
  subscriptionStatus,
  name: r'subscriptionStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionStatusRef = AutoDisposeProviderRef<SubscriptionStatus>;
String _$subscriptionTierHash() => r'30dea885b5a6f618d2409c0eb390ef9767d13a60';

/// Provider to get subscription tier
///
/// Copied from [subscriptionTier].
@ProviderFor(subscriptionTier)
final subscriptionTierProvider =
    AutoDisposeProvider<SubscriptionTier?>.internal(
  subscriptionTier,
  name: r'subscriptionTierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionTierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionTierRef = AutoDisposeProviderRef<SubscriptionTier?>;
String _$trialDaysRemainingHash() =>
    r'4e0dcd9e33fd9452d9a2d90a00eb3ce2aa0a58f4';

/// Provider to get trial days remaining
///
/// Copied from [trialDaysRemaining].
@ProviderFor(trialDaysRemaining)
final trialDaysRemainingProvider = AutoDisposeProvider<int?>.internal(
  trialDaysRemaining,
  name: r'trialDaysRemainingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trialDaysRemainingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrialDaysRemainingRef = AutoDisposeProviderRef<int?>;
String _$subscriptionNotifierHash() =>
    r'04377ac7ea956530e628e49b2d1125d952635c11';

/// Subscription state notifier
///
/// Copied from [SubscriptionNotifier].
@ProviderFor(SubscriptionNotifier)
final subscriptionNotifierProvider = AutoDisposeNotifierProvider<
    SubscriptionNotifier, SubscriptionState>.internal(
  SubscriptionNotifier.new,
  name: r'subscriptionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SubscriptionNotifier = AutoDisposeNotifier<SubscriptionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
