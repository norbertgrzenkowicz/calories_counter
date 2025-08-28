import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:food_scanner/screens/login_screen.dart';
import 'package:food_scanner/screens/dashboard_screen.dart';
import 'package:food_scanner/services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const SplashScreen({super.key, required this.cameras});

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
    await Future.delayed(Duration.zero); // Wait for the widget to build

    try {
      final supabaseService = SupabaseService();

      // Check if user is already authenticated
      if (supabaseService.isInitialized) {
        final user = supabaseService.client.auth.currentUser;

        if (user != null) {
          // User is authenticated, go to dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(cameras: widget.cameras),
            ),
          );
          return;
        }
      }

      // User is not authenticated or service not initialized, go to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // Error checking auth status, default to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
