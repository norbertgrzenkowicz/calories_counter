import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Use the FFI factory for web.
    databaseFactory = databaseFactoryFfiWeb;
  }

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Camera error: $e');
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
      home: DashboardScreen(cameras: cameras),
    );
  }
}
