import 'package:flutter/material.dart';
import 'package:food_scanner/theme/app_theme.dart';
import 'package:food_scanner/widgets/custom_button.dart';
import 'package:food_scanner/services/supabase_service.dart';
import 'package:food_scanner/core/app_logger.dart';
import 'package:food_scanner/core/service_locator.dart';
import 'package:food_scanner/utils/app_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  SupabaseService get _supabaseService => getIt<SupabaseService>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerWithSupabase() async {
    final email = _emailController.text.trim();
    AppLogger.logUserAction('user_registration_attempt');

    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: _passwordController.text,
      );

      if (response.user != null) {
        AppLogger.logUserAction('user_registration_successful');

        if (!mounted) return;
        AppSnackbar.success(context, 'Registration successful! Check your email to verify your account.');
        Navigator.of(context).pop();
      } else {
        AppLogger.error('Registration failed: No user returned');
        if (!mounted) return;
        AppSnackbar.error(context, 'Registration failed: No user created');
      }
    } on AuthException catch (e) {
      AppLogger.error('Registration failed - AuthException', e);

      if (!mounted) return;
      AppSnackbar.error(context, 'Registration failed: ${e.message}');
    } catch (e) {
      AppLogger.error('Registration failed - Unexpected error', e);

      if (!mounted) return;
      AppSnackbar.error(context, 'An error occurred: $e');
    }
  }

  bool _validateForm() {
    if (_emailController.text.trim().isEmpty) {
      AppSnackbar.warning(context, 'Please enter an email address');
      return false;
    }

    if (!_emailController.text.contains('@')) {
      AppSnackbar.warning(context, 'Please enter a valid email address');
      return false;
    }

    if (_passwordController.text.length < 6) {
      AppSnackbar.warning(context, 'Password must be at least 6 characters long');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      AppSnackbar.warning(context, 'Passwords do not match');
      return false;
    }

    return true;
  }

  Future<void> _register() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _registerWithSupabase();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
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
                  Icons.restaurant,
                  size: 48,
                  color: AppTheme.neonGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your journey with us today.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 48),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Register',
                isLoading: _isLoading,
                onPressed: _register,
              ),
              const SizedBox(height: 16),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: AppTheme.neonGreen),
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
          borderSide: const BorderSide(color: AppTheme.neonGreen, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Log In',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
