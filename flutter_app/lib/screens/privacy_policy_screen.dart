import 'package:flutter/material.dart';
import 'package:food_scanner/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: _PrivacyPolicyContent(),
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(context, 'Privacy Policy'),
        _body('Last updated: March 11, 2026'),
        const SizedBox(height: 24),
        _body(
          'Yapper ("we", "our", or "us") operates the Yapper mobile application. '
          'This policy explains what data we collect, how we use it, and your rights.',
        ),
        const SizedBox(height: 24),
        _section(context, '1. Data We Collect', [
          _bullet('Account data: email address and password (stored securely via Supabase Auth).'),
          _bullet('Profile data: name, dietary goals, and preferences you provide.'),
          _bullet('Meal data: food descriptions, photos, and nutrition entries you log.'),
          _bullet('Weight data: weight measurements you record.'),
          _bullet('Payment data: subscription status managed via Stripe. We do not store card details.'),
          _bullet('Usage data: app interactions and crash reports for improving the service.'),
        ]),
        const SizedBox(height: 24),
        _section(context, '2. How We Use Your Data', [
          _bullet('To provide and operate the food tracking service.'),
          _bullet("To analyze food photos via OpenAI's API for nutrition estimates."),
          _bullet('To process subscription payments via Stripe.'),
          _bullet('To sync your data across devices via Supabase.'),
          _bullet('To improve app performance and fix bugs.'),
        ]),
        const SizedBox(height: 24),
        _section(context, '3. Third-Party Services', [
          _bullet('Supabase — database, authentication, and file storage.'),
          _bullet('OpenAI — AI-powered food analysis (food photos and descriptions are sent to OpenAI\'s API).'),
          _bullet('Stripe — payment processing and subscription management.'),
        ]),
        const SizedBox(height: 24),
        _section(context, '4. Data Storage & Security', [
          _bullet('Your data is stored on Supabase servers with row-level security enabled.'),
          _bullet('Passwords are never stored in plaintext.'),
          _bullet('All data is transmitted over HTTPS.'),
          _bullet("Food photos sent for analysis are not permanently stored by OpenAI."),
        ]),
        const SizedBox(height: 24),
        _section(context, '5. Your Rights', [
          _bullet('Access: you can export all your data from the Settings screen.'),
          _bullet('Deletion: contact us to have your account and data permanently deleted.'),
          _bullet('Correction: update your profile information at any time in the app.'),
        ]),
        const SizedBox(height: 24),
        _section(context, '6. Data Retention', [
          _bullet('We retain your data for as long as your account is active.'),
          _bullet('Upon account deletion, all personal data is removed within 30 days.'),
        ]),
        const SizedBox(height: 24),
        _section(context, "7. Children's Privacy", [
          _bullet('Yapper is not directed at children under 13. We do not knowingly collect data from children.'),
        ]),
        const SizedBox(height: 24),
        _section(context, '8. Changes to This Policy', [
          _bullet('We may update this policy. Continued use of the app after changes constitutes acceptance.'),
          _bullet('Significant changes will be communicated via in-app notification.'),
        ]),
        const SizedBox(height: 24),
        _section(context, '9. Contact', [
          _bullet('Questions? Email us at privacy@yapper.app'),
        ]),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _heading(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.neonGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _body(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
