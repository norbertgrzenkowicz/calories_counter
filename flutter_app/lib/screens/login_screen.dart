import '../core/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_scanner/screens/register_screen.dart';
import 'package:food_scanner/screens/dashboard_screen.dart';
import 'package:food_scanner/theme/app_theme.dart';
import 'package:food_scanner/widgets/custom_button.dart';
import 'package:food_scanner/providers/auth_provider.dart';
import 'package:food_scanner/utils/app_page_route.dart';
import 'package:food_scanner/utils/app_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error(context, 'Please enter both email and password');
      return;
    }

    AppLogger.logUserAction('login_attempt');

    try {
      await ref.read(authNotifierProvider.notifier).signIn(email, password);

      // Check if login was successful
      final authState = ref.read(authNotifierProvider);
      if (authState.isAuthenticated && mounted) {
        AppLogger.logUserAction('login_successful');
        Navigator.of(context).pushReplacement(
          AppPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      AppLogger.error('Login failed', e);
    }
  }

  void _goToRegisterScreen() {
    Navigator.of(context).push(
      AppPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Listen for auth state changes and show errors
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.error != null) {
        AppSnackbar.error(context, next.error!);
      }
    });
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
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log in to continue your journey.',
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
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Log In',
                isLoading: authState.isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: 16),
              _buildRegisterLink(),
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        TextButton(
          onPressed: _goToRegisterScreen,
          child: const Text(
            'Register',
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
