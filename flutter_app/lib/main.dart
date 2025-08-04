import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'services/supabase_service.dart';
import 'services/supabase_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Camera error: $e');
  }

  print('🔧 Initializing Supabase...');
  try {
    final supabaseService = SupabaseService();
    await supabaseService.initialize();
    
    print('🧪 Running Supabase connection test...');
    await SupabaseTest.runConnectionTest();
  } catch (e) {
    print('⚠️ Supabase initialization failed: $e');
    print('📱 App will continue with local storage only');
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
      home: LoginScreen(),
    );
  }
}
