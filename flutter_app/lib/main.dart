import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'core/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection container
  try {
    await configureDependencies();
  } catch (e) {
    // Service initialization failed, continue with reduced functionality
    debugPrint('Service initialization error: $e');
  }

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    // Camera initialization failed, continue without camera
  }

  runApp(FoodScannerApp(cameras: cameras));
}

class FoodScannerApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const FoodScannerApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Scanner',
      theme: AppTheme.theme,
      home: SplashScreen(cameras: cameras),
    );
  }
}
