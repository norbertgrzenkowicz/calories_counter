import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  runApp(
    const ProviderScope(
      child: FoodScannerApp(),
    ),
  );
}

class FoodScannerApp extends StatelessWidget {
  const FoodScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Scanner',
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
