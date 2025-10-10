import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';
import '../services/nutrition_calculator_service.dart';

class CompactNutritionBars extends StatelessWidget {
  final List<Meal> meals;
  final UserProfile? userProfile;

  const CompactNutritionBars({
    super.key,
    required this.meals,
    this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate totals from meals
    final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);
    final totalProteins = meals.fold(0.0, (sum, meal) => sum + meal.proteins);
    final totalCarbs = meals.fold(0.0, (sum, meal) => sum + meal.carbs);
    final totalFats = meals.fold(0.0, (sum, meal) => sum + meal.fats);

    // Get targets from user profile or use defaults
    int targetCalories = 2000;
    double targetProteins = 150.0;
    double targetCarbs = 250.0;
    double targetFats = 65.0;

    if (userProfile != null && userProfile!.hasRequiredDataForCalculations) {
      final nutritionProfile =
          NutritionCalculatorService.calculateCompleteNutritionProfile(
              userProfile!);
      targetCalories = (nutritionProfile['targetCalories'] as int?) ?? 2000;
      final macros = nutritionProfile['macros'] as Map<String, double>? ?? {};
      targetProteins = macros['protein'] ?? 150.0;
      targetCarbs = macros['carbs'] ?? 250.0;
      targetFats = macros['fat'] ?? 65.0;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniBar(
            '🍎',
            'Calories',
            totalCalories.toDouble(),
            targetCalories.toDouble(),
            AppTheme.neonGreen,
            isCalories: true,
          ),
          const SizedBox(height: 8),
          _buildMiniBar(
            '🥩',
            'Protein',
            totalProteins,
            targetProteins,
            AppTheme.neonRed,
          ),
          const SizedBox(height: 8),
          _buildMiniBar(
            '🍞',
            'Carbs',
            totalCarbs,
            targetCarbs,
            AppTheme.neonYellow,
          ),
          const SizedBox(height: 8),
          _buildMiniBar(
            '🥑',
            'Fat',
            totalFats,
            targetFats,
            AppTheme.neonBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBar(
    String emoji,
    String label,
    double current,
    double target,
    Color color, {
    bool isCalories = false,
  }) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final unit = isCalories ? 'kcal' : 'g';

    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${isCalories ? current.toInt() : current.toStringAsFixed(0)}/${isCalories ? target.toInt() : target.toStringAsFixed(0)}$unit',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
