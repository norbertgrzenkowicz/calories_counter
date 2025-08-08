import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    // Camera initialization failed, continue without camera
  }

  try {
    final supabaseService = SupabaseService();
    await supabaseService.initialize();
  } catch (e) {
    // Supabase initialization failed, continue with local storage only
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
