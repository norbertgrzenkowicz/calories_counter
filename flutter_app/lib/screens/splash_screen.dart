import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:food_scanner/screens/dashboard_screen.dart';

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

    // Go directly to dashboard, bypassing authentication
    if (mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => DashboardScreen(cameras: widget.cameras),
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
