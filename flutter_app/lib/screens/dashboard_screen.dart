import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:food_scanner/screens/login_screen.dart';
import 'package:food_scanner/services/supabase_service.dart';

import '../theme/app_theme.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';
import '../models/chat_message.dart';
import '../services/profile_service.dart';
import '../services/nutrition_calculator_service.dart';
import '../services/chat_service.dart';
import '../widgets/compact_nutrition_bars.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import 'add_meal_screen.dart';
import 'weight_tracking_screen.dart';
import 'meal_detail_screen.dart';

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
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  // Chat-related state
  final List<ChatMessage> _chatMessages = [];
  final ChatService _chatService = ChatService();
  bool _isProcessingMessage = false;
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _meals = _getMealsFromSupabase();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    try {
      final profileService = ProfileService();
      final profile = await profileService.getUserProfile();

      setState(() {
        _userProfile = profile;
        _isLoadingProfile = false;
      });

      // If no profile exists, prompt user to create one
      if (profile == null && mounted) {
        _showProfilePrompt();
      }
    } catch (e) {
      setState(() => _isLoadingProfile = false);
      // Error loading user profile, continue with default behavior
    }
  }

  void _showProfilePrompt() {
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

  void _navigateToProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );

    // Reload profile after returning from profile screen
    if (result != null || mounted) {
      _loadUserProfile();
    }
  }

  Future<List<Meal>> _getMealsFromSupabase() async {
    try {
      final supabaseService = SupabaseService();
      if (!supabaseService.isInitialized) {
        return [];
      }

      final response = await supabaseService.getAllUserMeals();
      final meals =
          response.map<Meal>((data) => Meal.fromSupabase(data)).toList();

      return meals;
    } catch (e) {
      // Error loading meals from Supabase, return empty list
      return [];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _openWeightTracking();
    } else if (index == 1) {
      _addMeal();
    } else if (index == 2) {
      _navigateToProfile();
    }
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day - 1);
      _meals = _getMealsFromSupabase();
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day + 1);
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
      // Navigate to meal detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MealDetailScreen(
                  meal: meals[mealIndex],
                  onMealUpdated: () {
                    setState(() {
                      // Refresh the data when meal is updated or deleted
                      _meals = _getMealsFromSupabase();
                    });
                  },
                )),
      );
    }
    // Remove the else block - don't show any message for empty meal slots
  }

  void _onActualMealTapped(Meal meal) {
    // Navigate directly to meal detail screen with the actual meal object
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MealDetailScreen(
                meal: meal,
                onMealUpdated: () {
                  setState(() {
                    // Refresh the data when meal is updated or deleted
                    _meals = _getMealsFromSupabase();
                  });
                },
              )),
    );
  }

  void _openCalendar() async {
    final meals = await _meals;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarScreen(meals: meals),
      ),
    );
  }

  void _openWeightTracking() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WeightTrackingScreen(),
      ),
    );

    // Reload profile after returning from weight tracking (in case weight changed)
    if (result != null || mounted) {
      _loadUserProfile();
    }
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

  void _addMealWithNutrition(Map<String, int> nutritionData) {
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

  // Chat message handlers
  void _handleSendText(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage.user(
      content: text,
      type: MessageType.text,
    );

    setState(() {
      _chatMessages.add(userMessage);
      _isProcessingMessage = true;
    });

    _scrollToBottom();

    try {
      // Call API
      final nutritionData = await _chatService.analyzeFoodFromText(text);

      // Add AI response
      final aiMessage = ChatMessage.aiResponse(
        content: 'Food analyzed successfully',
        nutritionData: nutritionData,
      );

      setState(() {
        _chatMessages.add(aiMessage);
        _isProcessingMessage = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isProcessingMessage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze food: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSendImage(File imageFile) async {
    // Add user message
    final userMessage = ChatMessage.user(
      content: imageFile.path,
      type: MessageType.image,
    );

    setState(() {
      _chatMessages.add(userMessage);
      _isProcessingMessage = true;
    });

    _scrollToBottom();

    try {
      // Call API
      final nutritionData = await _chatService.analyzeFoodFromImage(imageFile);

      // Add AI response
      final aiMessage = ChatMessage.aiResponse(
        content: 'Food analyzed from image',
        nutritionData: nutritionData,
      );

      setState(() {
        _chatMessages.add(aiMessage);
        _isProcessingMessage = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isProcessingMessage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSendAudio(File audioFile, String format) async {
    // Add user message
    final userMessage = ChatMessage.user(
      content: audioFile.path,
      type: MessageType.audio,
    );

    setState(() {
      _chatMessages.add(userMessage);
      _isProcessingMessage = true;
    });

    _scrollToBottom();

    try {
      // Call API
      final nutritionData =
          await _chatService.analyzeFoodFromAudio(audioFile, format);

      // Add AI response
      final aiMessage = ChatMessage.aiResponse(
        content: 'Food analyzed from audio',
        nutritionData: nutritionData,
      );

      setState(() {
        _chatMessages.add(aiMessage);
        _isProcessingMessage = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isProcessingMessage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
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
          IconButton(
            onPressed: _openCalendar,
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Calendar',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                _navigateToProfile();
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
            child: const Icon(Icons.settings),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: _buildChatMessages(),
          ),
          // Compact nutrition bars at bottom
          FutureBuilder<List<Meal>>(
            future: _getMealsForSelectedDate(),
            builder: (context, snapshot) {
              final meals = snapshot.data ?? [];
              return CompactNutritionBars(
                meals: meals,
                userProfile: _userProfile,
              );
            },
          ),
          // Chat input bar
          ChatInputBar(
            onSendText: _handleSendText,
            onSendImage: _handleSendImage,
            onSendAudio: _handleSendAudio,
            isProcessing: _isProcessingMessage,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildChatMessages() {
    if (_chatMessages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppTheme.neonGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Start tracking your food!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Describe what you ate, take a photo, or record audio.\nOur AI will analyze the nutrition for you.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _chatScrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        final message = _chatMessages[index];
        return ChatMessageBubble(
          message: message,
          onAddToMeals: message.nutritionData != null
              ? () => _addMealWithNutrition(message.nutritionData!)
              : null,
        );
      },
    );
  }

  Widget _buildNutritionSummary() {
    if (_isLoadingProfile) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return FutureBuilder<List<Meal>>(
      future: _getMealsForSelectedDate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text('Error loading meals')),
            ),
          );
        }

        final selectedDateMeals = snapshot.data ?? [];
        final totalCalories =
            selectedDateMeals.fold(0, (sum, meal) => sum + meal.calories);
        final totalProteins =
            selectedDateMeals.fold(0.0, (sum, meal) => sum + meal.proteins);
        final totalCarbs =
            selectedDateMeals.fold(0.0, (sum, meal) => sum + meal.carbs);
        final totalFats =
            selectedDateMeals.fold(0.0, (sum, meal) => sum + meal.fats);

        // Get dynamic targets from user profile or use defaults
        int targetCalories = 2000;
        double targetProteins = 150.0;
        double targetCarbs = 250.0;
        double targetFats = 65.0;

        if (_userProfile != null &&
            _userProfile!.hasRequiredDataForCalculations) {
          final nutritionProfile =
              NutritionCalculatorService.calculateCompleteNutritionProfile(
                  _userProfile!);
          targetCalories = (nutritionProfile['targetCalories'] as int?) ?? 2000;
          final macros =
              nutritionProfile['macros'] as Map<String, double>? ?? {};
          targetProteins = macros['protein'] ?? 150.0;
          targetCarbs = macros['carbs'] ?? 250.0;
          targetFats = macros['fat'] ?? 65.0;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Nutrition',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_userProfile == null ||
                        !_userProfile!.hasRequiredDataForCalculations) ...[
                      GestureDetector(
                        onTap: _navigateToProfile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.neonOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.neonOrange.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: AppTheme.neonOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Complete Profile',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.neonOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppTheme.neonGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Personalized',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.neonGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Nutrition bars with bright sporty colors
                _buildNutritionBar(
                  '$totalCalories kcal / ${targetCalories.round()} kcal',
                  targetCalories > 0 ? totalCalories / targetCalories : 0,
                  isCalories: true,
                  remaining: (targetCalories - totalCalories).toDouble(),
                  macroType: 'calories',
                ),
                const SizedBox(height: 16),
                _buildNutritionBar(
                  '${totalProteins.toStringAsFixed(1)}g / ${targetProteins.toStringAsFixed(0)}g Protein',
                  targetProteins > 0 ? totalProteins / targetProteins : 0,
                  remaining: targetProteins - totalProteins,
                  macroType: 'protein',
                ),
                const SizedBox(height: 16),
                _buildNutritionBar(
                  '${totalCarbs.toStringAsFixed(1)}g / ${targetCarbs.toStringAsFixed(0)}g Carbs',
                  targetCarbs > 0 ? totalCarbs / targetCarbs : 0,
                  remaining: targetCarbs - totalCarbs,
                  macroType: 'carbs',
                ),
                const SizedBox(height: 16),
                _buildNutritionBar(
                  '${totalFats.toStringAsFixed(1)}g / ${targetFats.toStringAsFixed(0)}g Fat',
                  targetFats > 0 ? totalFats / targetFats : 0,
                  remaining: targetFats - totalFats,
                  macroType: 'fat',
                ),

                // Goal information if profile exists
                if (_userProfile != null &&
                    _userProfile!.hasRequiredDataForCalculations) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag,
                          size: 16,
                          color: AppTheme.neonGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Goal: ${_userProfile!.goalDisplayName}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutritionBar(
    String label,
    double progress, {
    bool isCalories = false,
    double? remaining,
    String macroType = '',
  }) {
    // Determine progress bar color - use bright sporty colors for macros
    Color progressColor;
    if (macroType == 'protein') {
      progressColor = AppTheme.neonRed;
    } else if (macroType == 'carbs') {
      progressColor = AppTheme.neonYellow;
    } else if (macroType == 'fat') {
      progressColor = AppTheme.neonBlue;
    } else if (macroType == 'calories') {
      progressColor = AppTheme.neonGreen;
    } else {
      // Fallback
      progressColor = AppTheme.textSecondary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ),
            if (remaining != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: remaining > 0
                      ? AppTheme.borderColor
                      : AppTheme.neonOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  remaining > 0
                      ? '${remaining.toStringAsFixed(isCalories ? 0 : 1)}${isCalories ? ' kcal' : 'g'} left'
                      : '${(-remaining).toStringAsFixed(isCalories ? 0 : 1)}${isCalories ? ' kcal' : 'g'} over',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: remaining > 0
                        ? AppTheme.textSecondary
                        : AppTheme.neonOrange,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% of target',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
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
                ? _buildEmptyMealsMessage()
                : _buildMealsGrid(meals);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyMealsMessage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.fastfood_outlined,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No meals added today',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first meal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  Widget _buildActualMealCard(int index, Meal meal) {
    return GestureDetector(
      onTap: () => _onActualMealTapped(meal),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
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
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.fastfood,
                                      size: 24, color: AppTheme.textTertiary),
                                  SizedBox(height: 4),
                                  Text(
                                    'No photo',
                                    style: TextStyle(
                                      color: AppTheme.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fastfood,
                                size: 24, color: AppTheme.textTertiary),
                            SizedBox(height: 4),
                            Text(
                              'No photo',
                              style: TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
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
                      color: AppTheme.textSecondary,
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
        color: AppTheme.cardBackground,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(0, Icons.monitor_weight, 'Weight'),
          _buildAddMealNavItem(),
          _buildBottomNavItem(2, Icons.person, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildAddMealNavItem() {
    final isSelected = _selectedIndex == 1;
    return GestureDetector(
      onTap: () => _onItemTapped(1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonGreen.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: AppTheme.darkBackground,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add Meal',
            style: TextStyle(
              color: isSelected
                  ? AppTheme.neonGreen
                  : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
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
            color: isSelected
                ? AppTheme.neonGreen
                : AppTheme.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppTheme.neonGreen
                  : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
