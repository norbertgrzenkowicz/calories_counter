import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../core/app_logger.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/meals_provider.dart';
import '../providers/profile_provider.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'add_meal_screen.dart';
import 'weight_tracking_screen.dart';
import 'settings_screen.dart';

class DashboardScreenRiverpod extends ConsumerStatefulWidget {
  final List<CameraDescription> cameras;

  const DashboardScreenRiverpod({super.key, required this.cameras});

  @override
  ConsumerState<DashboardScreenRiverpod> createState() =>
      _DashboardScreenRiverpodState();
}

class _DashboardScreenRiverpodState
    extends ConsumerState<DashboardScreenRiverpod> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _openWeightTracking();
        break;
      case 1:
        _addMeal();
        break;
      case 2:
        _navigateToProfile();
        break;
    }
  }

  void _openWeightTracking() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const WeightTrackingScreen()),
    );
  }

  void _addMeal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMealScreen(
          selectedDate: _selectedDate,
          onMealAdded: () {
            // Refresh meals when returning from add meal screen
            ref.invalidate(mealsNotifierProvider(_selectedDate));
          },
        ),
      ),
    );
  }

  void _navigateToProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );

    // Refresh profile when returning from profile screen
    if (result != null && mounted) {
      ref.invalidate(profileNotifierProvider);
    }
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day - 1);
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day + 1);
    });
  }

  bool _isToday() {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  void _signOut() async {
    try {
      await ref.read(authNotifierProvider.notifier).signOut();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final mealsAsync = ref.watch(mealsNotifierProvider(_selectedDate));
    final profileAsync = ref.watch(profileNotifierProvider);
    final dailyNutrition =
        ref.watch(dailyNutritionTotalsProvider(_selectedDate));
    final hasProfile = ref.watch(hasProfileProvider);
    final calorieTarget = ref.watch(dailyCalorieTargetProvider);

    // Redirect to login if not authenticated
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show profile prompt if user doesn't have profile
    if (!hasProfile && profileAsync.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfilePrompt();
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title:
            const Text('Yapper', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.neonGreen,
        foregroundColor: AppTheme.darkBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildNutritionSummary(dailyNutrition, calorieTarget),
          Expanded(child: _buildMealsList(mealsAsync)),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeal,
        backgroundColor: AppTheme.neonGreen,
        child: const Icon(Icons.add, color: AppTheme.darkBackground),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _goToPreviousDay,
            icon: const Icon(Icons.chevron_left, size: 30),
          ),
          Text(
            _isToday() ? 'Today' : _selectedDate.toString().substring(0, 10),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: _isToday() ? null : _goToNextDay,
            icon: Icon(
              Icons.chevron_right,
              size: 30,
              color: _isToday() ? Colors.grey : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(Map<String, num> nutrition, int calorieTarget) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutritionItem(
              'Calories', nutrition['calories'].toString(), '$calorieTarget'),
          _buildNutritionItem('Protein',
              '${nutrition['proteins']?.toStringAsFixed(1) ?? '0.0'}g', ''),
          _buildNutritionItem('Carbs',
              '${nutrition['carbs']?.toStringAsFixed(1) ?? '0.0'}g', ''),
          _buildNutritionItem(
              'Fat', '${nutrition['fats']?.toStringAsFixed(1) ?? '0.0'}g', ''),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String target) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.neonGreen,
          ),
        ),
        if (target.isNotEmpty)
          Text(
            'of $target',
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
          ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMealsList(AsyncValue<List<Map<String, dynamic>>> mealsAsync) {
    return mealsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading meals: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(mealsNotifierProvider(_selectedDate)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (meals) {
        if (meals.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No meals logged today',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to add your first meal',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return _buildMealCard(meal);
          },
        );
      },
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: meal['photo_url'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal['photo_url'] as String,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.restaurant, size: 50),
                ),
              )
            : const Icon(Icons.restaurant, size: 50),
        title: Text((meal['name'] as String?) ?? 'Unknown Meal'),
        subtitle: Text(
          '${meal['calories'] ?? 0} cal • P:${meal['proteins'] ?? 0}g C:${meal['carbs'] ?? 0}g F:${meal['fats'] ?? 0}g',
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _deleteMeal(meal['id'] as int?);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.monitor_weight),
          label: 'Weight',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add Meal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: AppTheme.neonGreen,
      onTap: _onItemTapped,
    );
  }

  void _showProfilePrompt() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Complete Your Profile'),
        content: const Text(
          'To get personalized calorie and nutrition targets, please complete your profile with your basic information.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToProfile();
            },
            child: const Text('Complete Profile'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Skip for Now'),
          ),
        ],
      ),
    );
  }

  void _deleteMeal(int? mealId) async {
    if (mealId == null) return;

    try {
      await ref
          .read(mealsNotifierProvider(_selectedDate).notifier)
          .deleteMeal(mealId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal deleted successfully'),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to delete meal', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.neonGreen,
            ),
            child: const Text(
              'Yapper',
              style: TextStyle(
                color: AppTheme.darkBackground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _navigateToSettings();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              _signOut();
            },
          ),
        ],
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const SettingsScreen()),
    );
  }
}
