/// Subscription status enum
enum SubscriptionStatus {
  free,
  trialing,
  active,
  pastDue,
  canceled;

  static SubscriptionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'free':
        return SubscriptionStatus.free;
      case 'trialing':
        return SubscriptionStatus.trialing;
      case 'active':
        return SubscriptionStatus.active;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      case 'canceled':
        return SubscriptionStatus.canceled;
      default:
        return SubscriptionStatus.free;
    }
  }

  String toDisplayString() {
    switch (this) {
      case SubscriptionStatus.free:
        return 'Free';
      case SubscriptionStatus.trialing:
        return 'Trial';
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.pastDue:
        return 'Past Due';
      case SubscriptionStatus.canceled:
        return 'Canceled';
    }
  }

  bool get hasAccess =>
      this == SubscriptionStatus.active || this == SubscriptionStatus.trialing;
}

/// Subscription tier enum
enum SubscriptionTier {
  monthly,
  yearly;

  static SubscriptionTier? fromString(String? tier) {
    if (tier == null) return null;

    switch (tier.toLowerCase()) {
      case 'monthly':
        return SubscriptionTier.monthly;
      case 'yearly':
        return SubscriptionTier.yearly;
      default:
        return null;
    }
  }

  String toDisplayString() {
    switch (this) {
      case SubscriptionTier.monthly:
        return 'Monthly';
      case SubscriptionTier.yearly:
        return 'Yearly';
    }
  }

  String get price {
    switch (this) {
      case SubscriptionTier.monthly:
        return '\$5';
      case SubscriptionTier.yearly:
        return '\$30';
    }
  }

  String get pricePerMonth {
    switch (this) {
      case SubscriptionTier.monthly:
        return '\$5/month';
      case SubscriptionTier.yearly:
        return '\$2.50/month';
    }
  }

  String get billingPeriod {
    switch (this) {
      case SubscriptionTier.monthly:
        return 'per month';
      case SubscriptionTier.yearly:
        return 'per year';
    }
  }
}

/// Subscription model
class Subscription {
  final SubscriptionStatus status;
  final SubscriptionTier? tier;
  final DateTime? trialEndsAt;
  final DateTime? subscriptionEndDate;
  final bool cancelAtPeriodEnd;
  final bool hasAccess;

  const Subscription({
    required this.status,
    this.tier,
    this.trialEndsAt,
    this.subscriptionEndDate,
    this.cancelAtPeriodEnd = false,
    required this.hasAccess,
  });

  /// Create from API response
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      status: SubscriptionStatus.fromString(json['status'] as String? ?? 'free'),
      tier: SubscriptionTier.fromString(json['tier'] as String?),
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'] as String)
          : null,
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.parse(json['subscription_end_date'] as String)
          : null,
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      hasAccess: json['has_access'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'tier': tier?.name,
      'trial_ends_at': trialEndsAt?.toIso8601String(),
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'cancel_at_period_end': cancelAtPeriodEnd,
      'has_access': hasAccess,
    };
  }

  /// Check if trial is active
  bool get isInTrial =>
      status == SubscriptionStatus.trialing &&
      trialEndsAt != null &&
      DateTime.now().isBefore(trialEndsAt!);

  /// Get days remaining in trial
  int? get trialDaysRemaining {
    if (!isInTrial || trialEndsAt == null) return null;

    final now = DateTime.now();
    final difference = trialEndsAt!.difference(now);
    return difference.inDays;
  }

  /// Get hours remaining in trial (for last day)
  int? get trialHoursRemaining {
    if (!isInTrial || trialEndsAt == null) return null;

    final now = DateTime.now();
    final difference = trialEndsAt!.difference(now);
    return difference.inHours;
  }

  /// Check if subscription will cancel soon (active but cancelling at period end)
  bool get willCancelSoon => cancelAtPeriodEnd && hasAccess;

  /// Copy with
  Subscription copyWith({
    SubscriptionStatus? status,
    SubscriptionTier? tier,
    DateTime? trialEndsAt,
    DateTime? subscriptionEndDate,
    bool? cancelAtPeriodEnd,
    bool? hasAccess,
  }) {
    return Subscription(
      status: status ?? this.status,
      tier: tier ?? this.tier,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      cancelAtPeriodEnd: cancelAtPeriodEnd ?? this.cancelAtPeriodEnd,
      hasAccess: hasAccess ?? this.hasAccess,
    );
  }

  @override
  String toString() {
    return 'Subscription(status: ${status.name}, tier: ${tier?.name}, cancelAtPeriodEnd: $cancelAtPeriodEnd, hasAccess: $hasAccess)';
  }
}
