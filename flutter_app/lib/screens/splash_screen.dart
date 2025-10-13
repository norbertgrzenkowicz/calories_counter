import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:food_scanner/screens/dashboard_screen.dart';
import 'package:food_scanner/screens/login_screen.dart';
import 'package:food_scanner/services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.cameras});

  final List<CameraDescription> cameras;

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

    // Check if user is authenticated
    final supabaseService = SupabaseService();
    final userId = supabaseService.getCurrentUserId();

    if (userId != null) {
      // User is authenticated, go to dashboard
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => DashboardScreen(cameras: widget.cameras),
        ),
      );
    } else {
      // User is not authenticated, go to login
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => const LoginScreen(),
        ),
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
