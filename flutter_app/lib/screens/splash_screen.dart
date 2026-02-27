import 'package:flutter/material.dart';
import 'package:food_scanner/screens/dashboard_screen.dart';
import 'package:food_scanner/screens/login_screen.dart';
import 'package:food_scanner/services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_page_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future<void>.delayed(Duration.zero); // Wait for the widget to build

    if (!mounted) return;

    // Check if user is authenticated and email is verified
    final supabaseService = SupabaseService();
    final userId = supabaseService.getCurrentUserId();

    if (userId != null && supabaseService.isEmailVerified()) {
      // User is authenticated with verified email, go to dashboard
      await Navigator.of(context).pushReplacement(
        AppPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } else {
      // Sign out unverified sessions so they don't linger
      if (userId != null) {
        await supabaseService.signOut();
      }
      // User is not authenticated or not verified, go to login
      await Navigator.of(context).pushReplacement(
        AppPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant,
                size: 64,
                color: AppTheme.neonGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Japer',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
