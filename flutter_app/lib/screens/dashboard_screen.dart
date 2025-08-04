import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:food_scanner/screens/login_screen.dart';
import 'package:food_scanner/services/supabase_service.dart';

import '../theme/app_theme.dart';
import '../models/meal.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import 'add_meal_screen.dart';

class DashboardScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const DashboardScreen({super.key, required this.cameras});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late Future<List<Meal>> _meals;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _meals = _getMealsFromSupabase();
  }

  Future<List<Meal>> _getMealsFromSupabase() async {
    try {
      final supabaseService = SupabaseService();
      if (!supabaseService.isInitialized) {
        return [];
      }
      
      final response = await supabaseService.getAllUserMeals();
      return response.map<Meal>((data) => Meal.fromSupabase(data)).toList();
    } catch (e) {
      print('Error loading meals from Supabase: $e');
      return [];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day - 1);
      _meals = _getMealsFromSupabase();
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day + 1);
      _meals = _getMealsFromSupabase();
    });
  }

  bool _isToday() {
    final today = DateTime.now();
    return _selectedDate.year == today.year && 
           _selectedDate.month == today.month && 
           _selectedDate.day == today.day;
  }

  String _getFormattedDate() {
    if (_isToday()) {
      return 'Today';
    }
    return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  Future<List<Meal>> _getMealsForSelectedDate() async {
    final meals = await _meals;
    return meals.where((meal) {
      return meal.date.year == _selectedDate.year &&
             meal.date.month == _selectedDate.month &&
             meal.date.day == _selectedDate.day;
    }).toList();
  }

  void _onMealTapped(int mealIndex) async {
    final meals = await _getMealsForSelectedDate();
    if (mealIndex < meals.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${meals[mealIndex].name} was clicked'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meal ${mealIndex + 1} was clicked'))
      );
    }
  }

  void _openCalendar() async {
    final meals = await _meals;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarScreen(meals: meals),
      ),
    );
  }

  void _addMeal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMealScreen(
          selectedDate: _selectedDate,
          onMealAdded: () {
            setState(() {
              _meals = _getMealsFromSupabase();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _goToPreviousDay,
          icon: const Icon(Icons.arrow_back_ios),
          tooltip: 'Previous Day',
        ),
        title: Text(_getFormattedDate()),
        centerTitle: true,
        actions: [
          if (!_isToday())
            IconButton(
              onPressed: _goToNextDay,
              icon: const Icon(Icons.arrow_forward_ios),
              tooltip: 'Next Day',
            ),
          Row(
            children: [
              IconButton(
                onPressed: _openCalendar,
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Calendar',
              ),
              IconButton(
                onPressed: _addMeal,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Meal',
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'profile') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  } else if (value == 'logout') {
                    await SupabaseService().signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Text('My Profile'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
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
    return FutureBuilder<List<Meal>>(
      future: _getMealsForSelectedDate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading meals'));
        }
        final selectedDateMeals = snapshot.data ?? [];
        final totalCalories = selectedDateMeals.fold(0, (sum, meal) => sum + meal.calories);
        final totalProteins = selectedDateMeals.fold(0.0, (sum, meal) => sum + meal.proteins);
        final totalCarbs = selectedDateMeals.fold(0.0, (sum, meal) => sum + meal.carbs);
        final totalFats = selectedDateMeals.fold(0.0, (sum, meal) => sum + meal.fats);
        
        const targetCalories = 2000;
        const targetProteins = 150.0;
        const targetCarbs = 250.0;
        const targetFats = 65.0;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNutritionBar('$totalCalories kcal / $targetCalories kcal', totalCalories / targetCalories),
                const SizedBox(height: 16),
                _buildNutritionBar('${totalProteins.toStringAsFixed(1)}g Proteins / ${targetProteins.toStringAsFixed(0)}g Proteins', totalProteins / targetProteins),
                const SizedBox(height: 16),
                _buildNutritionBar('${totalCarbs.toStringAsFixed(1)}g Carbs / ${targetCarbs.toStringAsFixed(0)}g Carbs', totalCarbs / targetCarbs),
                const SizedBox(height: 16),
                _buildNutritionBar('${totalFats.toStringAsFixed(1)}g Fat / ${targetFats.toStringAsFixed(0)}g Fat', totalFats / targetFats),
              ],
            ),
          ),
        );
      },
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
        FutureBuilder<List<Meal>>(
          future: _getMealsForSelectedDate(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading meals'));
            }
            final meals = snapshot.data ?? [];
            return meals.isEmpty
                ? _buildEmptyMealsRow()
                : _buildMealsGrid(meals);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyMealsRow() {
    return Row(
      children: [
        Expanded(child: _buildMealCard(0, 'Meal 1 Date')),
        const SizedBox(width: 12),
        Expanded(child: _buildMealCard(1, 'Meal 2 Date')),
        const SizedBox(width: 12),
        Expanded(child: _buildMealCard(2, 'Meal 3 Date')),
      ],
    );
  }

  Widget _buildMealsGrid(List<Meal> meals) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: meals.asMap().entries.map((entry) {
        int index = entry.key;
        Meal meal = entry.value;
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 56) / 3,
          child: _buildActualMealCard(index, meal),
        );
      }).toList(),
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

  Widget _buildActualMealCard(int index, Meal meal) {
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
                child: meal.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          meal.photoUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                'Photo',
                                style: TextStyle(
                                  color: AppTheme.charcoal,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      )
                    : const Center(
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
                meal.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${meal.calories} cal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.charcoal.withOpacity(0.7),
                    ),
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