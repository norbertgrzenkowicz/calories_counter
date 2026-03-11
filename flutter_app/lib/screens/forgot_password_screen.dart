import 'package:flutter/material.dart';
import 'package:food_scanner/core/app_logger.dart';
import 'package:food_scanner/core/service_locator.dart';
import 'package:food_scanner/services/supabase_service.dart';
import 'package:food_scanner/theme/app_theme.dart';
import 'package:food_scanner/utils/app_snackbar.dart';
import 'package:food_scanner/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  SupabaseService get _supabaseService => getIt<SupabaseService>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      AppSnackbar.error(context, 'Please enter your email address');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      AppSnackbar.error(context, 'Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);
    AppLogger.logUserAction('password_reset_requested');

    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
      AppLogger.info('Password reset email sent to $email');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    } on AuthException catch (e) {
      AppLogger.error('Password reset failed', e);
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, e.message);
      }
    } catch (e) {
      AppLogger.error('Unexpected error during password reset', e);
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, 'Something went wrong. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 48,
                  color: AppTheme.neonGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Reset Password',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _emailSent
                    ? 'Check your inbox for the reset link.'
                    : 'Enter your email and we\'ll send you a reset link.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 48),
              if (_emailSent) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.neonGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.mark_email_read_outlined,
                        color: AppTheme.neonGreen,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Email sent to\n${_emailController.text.trim()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Back to Login',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ] else ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: AppTheme.neonGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.neonGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Send Reset Link',
                  isLoading: _isLoading,
                  onPressed: _sendResetEmail,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
