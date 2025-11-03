import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  SubscriptionTier? _selectedTier;

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final subscription = subscriptionState.subscription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: AppTheme.neonGreen,
        foregroundColor: AppTheme.darkBackground,
      ),
      body: subscriptionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Text(
                    'Unlock Premium Features',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getHeaderSubtitle(subscription),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Features list
                  _buildFeatureItem('Unlimited food scanning'),
                  _buildFeatureItem('AI-powered nutrition analysis'),
                  _buildFeatureItem('Advanced meal tracking'),
                  _buildFeatureItem('Personalized recommendations'),
                  _buildFeatureItem('Export your data'),
                  _buildFeatureItem('Priority support'),
                  const SizedBox(height: 30),

                  // Subscription tier cards
                  _buildTierCard(
                    tier: SubscriptionTier.yearly,
                    isPopular: true,
                  ),
                  const SizedBox(height: 15),
                  _buildTierCard(
                    tier: SubscriptionTier.monthly,
                    isPopular: false,
                  ),
                  const SizedBox(height: 30),

                  // Subscribe button
                  ElevatedButton(
                    onPressed: _selectedTier == null
                        ? null
                        : () => _startCheckout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen,
                      foregroundColor: AppTheme.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _getButtonText(subscription),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Terms
                  Text(
                    _getTermsText(subscription),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Current subscription info
                  if (subscription != null &&
                      subscription.status != SubscriptionStatus.free) ...[
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Current Status: ${subscription.status.toDisplayString()}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (subscription.tier != null)
                            Text('Tier: ${subscription.tier!.toDisplayString()}'),
                          if (subscription.trialEndsAt != null)
                            Text(
                              'Trial ends: ${_formatDate(subscription.trialEndsAt!)}',
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.neonGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required SubscriptionTier tier,
    required bool isPopular,
  }) {
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTier = tier;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonGreen.withOpacity(0.1) : AppTheme.cardBackground,
          border: Border.all(
            color: isSelected ? AppTheme.neonGreen : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.neonGreen.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tier.toDisplayString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'BEST VALUE',
                      style: TextStyle(
                        color: AppTheme.darkBackground,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.neonGreen,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tier.price,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    tier.billingPeriod,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            if (tier == SubscriptionTier.yearly) ...[
              const SizedBox(height: 8),
              Text(
                'Just ${tier.pricePerMonth}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildTrialBadge(),
          ],
        ),
      ),
    );
  }

  Future<void> _startCheckout(BuildContext context) async {
    if (_selectedTier == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final checkoutUrl =
          await ref.read(subscriptionNotifierProvider.notifier).startCheckout(
                _selectedTier!,
              );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (checkoutUrl != null) {
        // Open Stripe Checkout in WebView or browser
        await _openCheckout(context, checkoutUrl);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start checkout')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _openCheckout(BuildContext context, String checkoutUrl) async {
    // Option 1: Open in external browser (simpler, recommended for mobile)
    final uri = Uri.parse(checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!context.mounted) return;
      // Show message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Opening Stripe Checkout... Return to the app after completing purchase.',
          ),
          duration: Duration(seconds: 5),
        ),
      );

      // Refresh subscription status after a delay (user might return)
      Future.delayed(const Duration(seconds: 10), () {
        ref.read(subscriptionNotifierProvider.notifier).fetchSubscriptionStatus();
      });
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open checkout')),
      );
    }

    // Option 2: Open in WebView (more integrated, but more complex)
    // Uncomment if you prefer in-app experience:
    /*
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _CheckoutWebView(checkoutUrl: checkoutUrl),
      ),
    );
    */
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getHeaderSubtitle(Subscription? subscription) {
    // Check if user is eligible for trial (no trial_ends_at means never trialed)
    if (subscription?.trialEndsAt == null) {
      return 'Start your 7-day free trial';
    }
    return 'Choose your plan';
  }

  String _getButtonText(Subscription? subscription) {
    // Check if user is eligible for trial
    if (subscription?.trialEndsAt == null) {
      return 'Start Free Trial';
    }
    return 'Subscribe Now';
  }

  String _getTermsText(Subscription? subscription) {
    // Check if user is eligible for trial
    if (subscription?.trialEndsAt == null) {
      return 'Cancel anytime. You won\'t be charged until the trial ends.';
    }
    return 'Cancel anytime. Billed monthly or annually.';
  }

  Widget _buildTrialBadge() {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final subscription = subscriptionState.subscription;

    // Check if user is eligible for trial
    final isEligibleForTrial = subscription?.trialEndsAt == null;

    if (!isEligibleForTrial) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.celebration,
            size: 16,
            color: Colors.green,
          ),
          SizedBox(width: 6),
          Text(
            '7-day free trial',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Optional: In-app WebView for Stripe Checkout
class _CheckoutWebView extends StatefulWidget {
  final String checkoutUrl;

  const _CheckoutWebView({required this.checkoutUrl});

  @override
  State<_CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<_CheckoutWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Handle success/cancel redirects
            if (request.url.startsWith('foodscanner://subscription/success')) {
              // Checkout successful
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            } else if (request.url
                .startsWith('foodscanner://subscription/cancel')) {
              // Checkout canceled
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Purchase'),
        backgroundColor: AppTheme.neonGreen,
        foregroundColor: AppTheme.darkBackground,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
