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
            Icons.local_fire_department,
            'Calories',
            totalCalories.toDouble(),
            targetCalories.toDouble(),
            AppTheme.neonGreen,
            isCalories: true,
          ),
          const SizedBox(height: 8),
          _buildMiniBar(
            Icons.fitness_center,
            'Protein',
            totalProteins,
            targetProteins,
            AppTheme.neonRed,
          ),
          const SizedBox(height: 8),
          _buildMiniBar(
            Icons.grain,
            'Carbs',
            totalCarbs,
            targetCarbs,
            AppTheme.neonYellow,
          ),
          const SizedBox(height: 8),
          _buildMiniBar(
            Icons.water_drop,
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
    IconData icon,
    String label,
    double current,
    double target,
    Color color, {
    bool isCalories = false,
  }) {
    final rawProgress = target > 0 ? (current / target) : 0.0;
    final progress = rawProgress.clamp(0.0, 1.0);
    final unit = isCalories ? 'kcal' : 'g';

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
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
              _AnimatedNutritionBar(
                progress: rawProgress,
                color: color,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _SparkleKind {
  add,
  remove,
  complete,
}

class _AnimatedNutritionBar extends StatefulWidget {
  final double progress;
  final Color color;

  const _AnimatedNutritionBar({
    required this.progress,
    required this.color,
  });

  @override
  State<_AnimatedNutritionBar> createState() => _AnimatedNutritionBarState();
}

class _AnimatedNutritionBarState extends State<_AnimatedNutritionBar>
    with SingleTickerProviderStateMixin {
  static const _overflowColor = Color(0xFFCC1100);
  static const _barDuration = Duration(milliseconds: 480);
  static const _barCurve = Curves.easeInOutCubic;
  static const _sparkleAddDuration = Duration(milliseconds: 430);
  static const _sparkleRemoveDuration = Duration(milliseconds: 370);
  static const _sparkleCompleteDuration = Duration(milliseconds: 560);

  late final AnimationController _sparkleController;
  late final Animation<double> _sparkleAnimation;
  late double _lastProgress;
  late double _targetProgress;
  _SparkleKind _sparkleKind = _SparkleKind.add;

  @override
  void initState() {
    super.initState();
    _lastProgress = widget.progress;
    _targetProgress = widget.progress;
    _sparkleController = AnimationController(
      vsync: this,
      duration: _sparkleAddDuration,
    );
    _sparkleAnimation = CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedNutritionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress == _targetProgress) {
      return;
    }

    final previous = _targetProgress;
    _lastProgress = previous;
    _targetProgress = widget.progress;

    if (widget.progress >= 1.0 && previous < 1.0) {
      _triggerSparkle(_SparkleKind.complete);
    } else if (widget.progress > previous) {
      _triggerSparkle(_SparkleKind.add);
    } else if (widget.progress < previous) {
      _triggerSparkle(_SparkleKind.remove);
    }

    setState(() {});
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _triggerSparkle(_SparkleKind kind) {
    _sparkleKind = kind;
    switch (kind) {
      case _SparkleKind.add:
        _sparkleController.duration = _sparkleAddDuration;
        break;
      case _SparkleKind.remove:
        _sparkleController.duration = _sparkleRemoveDuration;
        break;
      case _SparkleKind.complete:
        _sparkleController.duration = _sparkleCompleteDuration;
        break;
    }
    _sparkleController.forward(from: 0);
  }

  Color _sparkleBaseColor(Color color) {
    switch (_sparkleKind) {
      case _SparkleKind.add:
        return color.withOpacity(0.7);
      case _SparkleKind.remove:
        return color.withOpacity(0.45);
      case _SparkleKind.complete:
        return color.withOpacity(0.9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final barDuration = reduceMotion ? Duration.zero : _barDuration;

    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: _lastProgress, end: _targetProgress),
          duration: barDuration,
          curve: _barCurve,
          onEnd: () {
            _lastProgress = _targetProgress;
          },
          builder: (context, progress, child) {
            final clampedProgress = progress.clamp(0.0, 1.0);
            final fillWidth = constraints.maxWidth * clampedProgress;
            final overflowWidth =
                constraints.maxWidth * (progress - 1).clamp(0.0, 1.0);

            return Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 6,
                  width: fillWidth,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
                if (overflowWidth > 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 6,
                      width: overflowWidth,
                      decoration: BoxDecoration(
                        color: _overflowColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                if (!reduceMotion && fillWidth > 0)
                  SizedBox(
                    height: 6,
                    width: fillWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedBuilder(
                        animation: _sparkleAnimation,
                        builder: (context, child) {
                          if (_sparkleController.isDismissed) {
                            return const SizedBox.shrink();
                          }

                          final t = _sparkleAnimation.value;
                          final opacity = (1 - t) *
                              (_sparkleKind == _SparkleKind.remove ? 0.5 : 0.7);
                          final scale = 0.7 +
                              (t *
                                  (_sparkleKind == _SparkleKind.complete
                                      ? 0.45
                                      : 0.35));
                          final baseColor = _sparkleBaseColor(widget.color);

                          return Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: scale,
                              child: SizedBox(
                                width: 16,
                                height: 10,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        gradient: LinearGradient(
                                          colors: [
                                            baseColor.withOpacity(0.0),
                                            baseColor.withOpacity(0.7),
                                            baseColor.withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 1,
                                      right: 2,
                                      child: _SparkleDot(
                                        color: baseColor,
                                        size: 2.5,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 1,
                                      left: 3,
                                      child: _SparkleDot(
                                        color: baseColor,
                                        size: 2,
                                      ),
                                    ),
                                    Positioned(
                                      top: 3,
                                      left: 7,
                                      child: _SparkleDot(
                                        color: baseColor.withOpacity(0.6),
                                        size: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SparkleDot extends StatelessWidget {
  final Color color;
  final double size;

  const _SparkleDot({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
