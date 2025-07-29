import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class DashboardScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const DashboardScreen({super.key, required this.cameras});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onMealTapped(int mealIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Meal ${mealIndex + 1} tapped'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: const Text('Today'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNutritionSummary(),
            const SizedBox(height: 32),
            _buildMealsSection(),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildNutritionSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNutritionBar('XXX kcal / XXX kcal', 0.6),
            const SizedBox(height: 16),
            _buildNutritionBar('XXX Proteins / XXX Proteins', 0.4),
            const SizedBox(height: 16),
            _buildNutritionBar('XXX Carbs / XXX Carbs', 0.8),
            const SizedBox(height: 16),
            _buildNutritionBar('XXX Fat / XXX Fat', 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBar(String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.softGray,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Meals',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMealCard(0, 'Meal 1 Date')),
            const SizedBox(width: 12),
            Expanded(child: _buildMealCard(1, 'Meal 2 Date')),
            const SizedBox(width: 12),
            Expanded(child: _buildMealCard(2, 'Meal 3 Date')),
          ],
        ),
      ],
    );
  }

  Widget _buildMealCard(int index, String date) {
    return GestureDetector(
      onTap: () => _onMealTapped(index),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.softGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.charcoal.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Text(
                    'Photo',
                    style: TextStyle(
                      color: AppTheme.charcoal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.charcoal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(0, Icons.settings, 'Settings'),
          _buildBottomNavItem(1, Icons.person, 'Your Profile'),
          _buildBottomNavItem(2, Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryGreen : AppTheme.charcoal.withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryGreen : AppTheme.charcoal.withOpacity(0.6),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}