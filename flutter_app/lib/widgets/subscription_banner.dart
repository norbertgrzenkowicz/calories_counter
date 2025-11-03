import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../screens/subscription_screen.dart';
import '../theme/app_theme.dart';

class SubscriptionBanner extends ConsumerWidget {
  const SubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final subscription = subscriptionState.subscription;

    // Don't show banner if user has active paid subscription
    if (subscription == null ||
        subscription.status == SubscriptionStatus.active) {
      return const SizedBox.shrink();
    }

    // Show trial banner
    if (subscription.status == SubscriptionStatus.trialing &&
        subscription.trialDaysRemaining != null) {
      return _buildTrialBanner(context, subscription);
    }

    // Show upgrade banner for free users
    if (subscription.status == SubscriptionStatus.free) {
      return _buildUpgradeBanner(context, subscription);
    }

    // Show past due banner
    if (subscription.status == SubscriptionStatus.pastDue) {
      return _buildPastDueBanner(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildTrialBanner(BuildContext context, Subscription subscription) {
    final daysRemaining = subscription.trialDaysRemaining!;
    final hoursRemaining = subscription.trialHoursRemaining!;

    String message;
    Color backgroundColor;

    if (daysRemaining > 3) {
      message = '$daysRemaining days left in your free trial';
      backgroundColor = Colors.blue.shade50;
    } else if (daysRemaining >= 1) {
      message = '$daysRemaining days left in your free trial!';
      backgroundColor = Colors.orange.shade50;
    } else {
      message = '$hoursRemaining hours left in your free trial!';
      backgroundColor = Colors.red.shade50;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: daysRemaining <= 3 ? Colors.orange : Colors.blue,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: daysRemaining <= 3 ? Colors.orange : Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Subscribe to continue unlimited access',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.neonGreen,
              foregroundColor: AppTheme.darkBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context, Subscription subscription) {
    // Check if user is eligible for trial (no trial_ends_at means never trialed)
    final isEligibleForTrial = subscription.trialEndsAt == null;
    final subtitleText = isEligibleForTrial
        ? 'Start 7-day free trial'
        : 'Unlock unlimited features';
    final buttonText = isEligibleForTrial ? 'Try Free' : 'Upgrade';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withOpacity(0.8),
            AppTheme.neonGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.darkBackground,
              foregroundColor: AppTheme.neonGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildPastDueBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please update your payment method',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
