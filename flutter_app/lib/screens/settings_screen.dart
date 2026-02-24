import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../providers/subscription_provider.dart';
import '../models/subscription.dart';
import '../utils/app_page_route.dart';
import '../utils/app_snackbar.dart';
import 'export_data_screen.dart';
import 'subscription_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final subscription = subscriptionState.subscription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      backgroundColor: AppTheme.darkBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Subscription',
            children: [
              if (subscription?.hasAccess ?? false)
                _buildSettingsTile(
                  context: context,
                  icon: Icons.star,
                  title: 'Manage Subscription',
                  subtitle: _getSubscriptionSubtitle(subscription),
                  onTap: () => _manageSubscription(context, ref),
                )
              else
                _buildSettingsTile(
                  context: context,
                  icon: Icons.star_border,
                  title: 'Upgrade to Premium',
                  subtitle: _getUpgradeSubtitle(subscription),
                  onTap: () => _navigateToSubscription(context),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Data Management',
            children: [
              _buildSettingsTile(
                context: context,
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Download your weight history and meal data',
                onTap: () => _navigateToExportData(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Account',
            children: [
              _buildSettingsTile(
                context: context,
                icon: Icons.person,
                title: 'Profile Settings',
                subtitle: 'Manage your profile information',
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingsTile(
                context: context,
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Support',
            children: [
              _buildSettingsTile(
                context: context,
                icon: Icons.help_outline,
                title: 'Help & FAQ',
                subtitle: 'Get help and find answers',
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingsTile(
                context: context,
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.neonGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _getSubscriptionSubtitle(Subscription? subscription) {
    if (subscription == null) return 'Active';

    // Check if subscription will cancel at period end
    if (subscription.willCancelSoon && subscription.subscriptionEndDate != null) {
      final endDate = subscription.subscriptionEndDate!;
      final now = DateTime.now();
      final daysRemaining = endDate.difference(now).inDays;

      if (daysRemaining > 1) {
        return 'Cancels in $daysRemaining days - ${subscription.tier?.toDisplayString() ?? "N/A"}';
      } else if (daysRemaining == 1) {
        return 'Cancels tomorrow - ${subscription.tier?.toDisplayString() ?? "N/A"}';
      } else if (daysRemaining == 0) {
        return 'Cancels today - ${subscription.tier?.toDisplayString() ?? "N/A"}';
      }
      return 'Cancels on ${endDate.month}/${endDate.day}/${endDate.year}';
    }

    if (subscription.status == SubscriptionStatus.trialing) {
      final daysRemaining = subscription.trialDaysRemaining;
      if (daysRemaining != null) {
        if (daysRemaining > 1) {
          return 'Trial - $daysRemaining days remaining';
        } else if (daysRemaining == 1) {
          return 'Trial - 1 day remaining';
        } else {
          final hoursRemaining = subscription.trialHoursRemaining;
          return 'Trial - ${hoursRemaining ?? 0} hours remaining';
        }
      }
      return 'Trial - ${subscription.tier?.toDisplayString() ?? "N/A"}';
    }

    return '${subscription.status.toDisplayString()} - ${subscription.tier?.toDisplayString() ?? "N/A"}';
  }

  String _getUpgradeSubtitle(Subscription? subscription) {
    // Check if user has ever had a trial (if trial_ends_at is set, they used it)
    if (subscription?.trialEndsAt != null) {
      // User already used their trial
      return 'Unlock unlimited features';
    }
    // User is eligible for trial
    return 'Start 7-day free trial';
  }

  void _navigateToExportData(BuildContext context) {
    Navigator.push(
      context,
      AppPageRoute(builder: (context) => const ExportDataScreen()),
    );
  }

  void _navigateToSubscription(BuildContext context) {
    Navigator.push(
      context,
      AppPageRoute(builder: (context) => const SubscriptionScreen()),
    );
  }

  Future<void> _manageSubscription(BuildContext context, WidgetRef ref) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final portalUrl = await ref
          .read(subscriptionNotifierProvider.notifier)
          .openCustomerPortal();

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (portalUrl != null) {
        // Open Customer Portal in browser
        final uri = Uri.parse(portalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (!context.mounted) return;
          AppSnackbar.error(context, 'Could not open subscription portal');
        }
      } else {
        if (!context.mounted) return;
        AppSnackbar.error(context, 'Failed to access subscription portal');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      AppSnackbar.error(context, 'Error: $e');
    }
  }

  void _showComingSoon(BuildContext context) {
    AppSnackbar.info(context, 'Coming soon!');
  }
}