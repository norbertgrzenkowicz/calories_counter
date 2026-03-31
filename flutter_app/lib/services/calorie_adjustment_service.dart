import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/weight_history.dart';
import '../services/nutrition_calculator_service.dart';
import '../services/profile_service.dart';

const String _kLastShownKey = 'calorie_adjustment_last_shown';
const String _kSnoozedUntilKey = 'calorie_adjustment_snoozed_until';

class CalorieAdjustmentSuggestion {
  final int currentCalories;
  final int suggestedCalories;
  final int adjustmentAmount;
  final String reasonText;
  final double weeklyActualChange;

  const CalorieAdjustmentSuggestion({
    required this.currentCalories,
    required this.suggestedCalories,
    required this.adjustmentAmount,
    required this.reasonText,
    required this.weeklyActualChange,
  });
}

class CalorieAdjustmentService {
  static final CalorieAdjustmentService _instance =
      CalorieAdjustmentService._internal();
  factory CalorieAdjustmentService() => _instance;
  CalorieAdjustmentService._internal();

  final ProfileService _profileService = ProfileService();

  /// Primary entry point. Returns null when no popup should be shown.
  Future<CalorieAdjustmentSuggestion?> evaluateAdjustment({
    required UserProfile profile,
    required SharedPreferences prefs,
  }) async {
    // Gate 1: need a calorie target to adjust
    if (profile.targetCalories == null || profile.targetCalories! <= 0) {
      return null;
    }
    // Gate 2: cooldown
    if (_isCooldownActive(prefs)) return null;
    // Gate 3: snooze
    if (_isSnoozed(prefs)) return null;

    // Gate 4: need at least 3 data points in the past 7 days
    final startDate = DateTime.now().subtract(const Duration(days: 7));
    List<WeightHistory> history;
    try {
      history = await _profileService.getWeightHistory(
        startDate: startDate,
        limit: 20,
      );
    } catch (_) {
      return null;
    }
    if (history.length < 3) return null;

    return _computeSuggestion(profile: profile, history: history);
  }

  Future<CalorieAdjustmentSuggestion?> _computeSuggestion({
    required UserProfile profile,
    required List<WeightHistory> history,
  }) async {
    // Sort oldest first
    final sorted = history.toList()
      ..sort((a, b) => a.recordedDate.compareTo(b.recordedDate));

    final first = sorted.first;
    final last = sorted.last;
    final daysBetween = last.recordedDate.difference(first.recordedDate).inDays;
    if (daysBetween <= 0) return null;

    final weeklyActualChange =
        ((last.weightKg - first.weightKg) / daysBetween) * 7;

    final goal = profile.goal;

    // Gate 5: initial phase check
    if (goal == 'weight_loss' || goal == 'weight_gain') {
      final tdee = profile.calculateTDEE();
      final target = profile.targetCalories!;
      final dailyDeficit = (goal == 'weight_loss') ? tdee - target : target - tdee;
      final analysis = NutritionCalculatorService.analyzeWeightProgress(
        weightHistory: history,
        dailyCalorieDeficit: dailyDeficit.abs(),
      );
      if (analysis['isInitialPhase'] == true) return null;

      final progressStatus = analysis['progressStatus'] as String? ?? '';
      if (goal == 'weight_loss') {
        return _evaluateWeightLoss(
          weeklyActualChange: weeklyActualChange,
          progressStatus: progressStatus,
          currentCalories: profile.targetCalories!,
        );
      } else {
        return _evaluateWeightGain(
          weeklyActualChange: weeklyActualChange,
          weeklyExpectedChange: profile.weeklyWeightLossTarget,
          currentCalories: profile.targetCalories!,
        );
      }
    }

    // For maintaining/hypertrophy: use weightLossStartDate for initial phase
    if (profile.weightLossStartDate != null) {
      final daysSinceStart =
          DateTime.now().difference(profile.weightLossStartDate!).inDays;
      if (daysSinceStart <= 28) return null;
    }

    if (goal == 'maintaining') {
      return _evaluateMaintaining(
        weeklyActualChange: weeklyActualChange,
        currentCalories: profile.targetCalories!,
      );
    }

    if (goal == 'hypertrophy') {
      return _evaluateHypertrophy(
        weeklyActualChange: weeklyActualChange,
        currentCalories: profile.targetCalories!,
      );
    }

    return null;
  }

  CalorieAdjustmentSuggestion? _evaluateWeightLoss({
    required double weeklyActualChange,
    required String progressStatus,
    required int currentCalories,
  }) {
    // Special case: gaining weight while on a loss plan
    if (weeklyActualChange > 0.05) {
      return _make(currentCalories, -250, weeklyActualChange,
          "You're gaining weight on a loss plan");
    }
    switch (progressStatus) {
      case 'exceeding':
        return _make(currentCalories, 100, weeklyActualChange,
            "You're losing faster than planned — protect muscle");
      case 'on_track':
        return null;
      case 'slow_progress':
        return _make(currentCalories, -100, weeklyActualChange,
            "Progress is slower than expected");
      case 'minimal_progress':
        return _make(currentCalories, -200, weeklyActualChange,
            "Very little progress — try a bigger deficit");
      default:
        return null;
    }
  }

  CalorieAdjustmentSuggestion? _evaluateWeightGain({
    required double weeklyActualChange,
    required double weeklyExpectedChange,
    required int currentCalories,
  }) {
    if (weeklyActualChange < -0.05) {
      return _make(currentCalories, 300, weeklyActualChange,
          "You're losing weight on a gain plan");
    }
    if (weeklyExpectedChange <= 0) return null;

    final ratio = weeklyActualChange / weeklyExpectedChange;
    if (ratio > 1.2) {
      return _make(currentCalories, -100, weeklyActualChange,
          "Gaining faster than planned — may be excess fat");
    }
    if (ratio >= 0.8) return null;
    if (ratio >= 0.5) {
      return _make(currentCalories, 100, weeklyActualChange,
          "Gaining slower than expected");
    }
    return _make(currentCalories, 200, weeklyActualChange,
        "Very little gain — increase your surplus");
  }

  CalorieAdjustmentSuggestion? _evaluateMaintaining({
    required double weeklyActualChange,
    required int currentCalories,
  }) {
    if (weeklyActualChange < -0.3) {
      return _make(currentCalories, 150, weeklyActualChange,
          "Your weight is dropping — adjust to maintain");
    }
    if (weeklyActualChange > 0.3) {
      return _make(currentCalories, -150, weeklyActualChange,
          "Your weight is creeping up — trim slightly");
    }
    return null;
  }

  CalorieAdjustmentSuggestion? _evaluateHypertrophy({
    required double weeklyActualChange,
    required int currentCalories,
  }) {
    if (weeklyActualChange < 0) {
      return _make(currentCalories, 200, weeklyActualChange,
          "You're losing weight — increase calories for muscle");
    }
    if (weeklyActualChange < 0.1) {
      return _make(currentCalories, 100, weeklyActualChange,
          "Lean bulk stalled — a bit more fuel needed");
    }
    if (weeklyActualChange <= 0.5) return null;
    return _make(currentCalories, -100, weeklyActualChange,
        "Gaining too fast for lean bulk — reduce surplus");
  }

  CalorieAdjustmentSuggestion _make(
    int currentCalories,
    int adjustment,
    double weeklyActualChange,
    String reason,
  ) {
    final newCalories = (currentCalories + adjustment).clamp(1200, 9999);
    final actualAdjustment = newCalories - currentCalories;
    return CalorieAdjustmentSuggestion(
      currentCalories: currentCalories,
      suggestedCalories: newCalories,
      adjustmentAmount: actualAdjustment,
      reasonText: reason,
      weeklyActualChange: weeklyActualChange,
    );
  }

  /// Persist the new calorie target with proportionally scaled macros.
  Future<UserProfile> applyAdjustment({
    required UserProfile profile,
    required int adjustmentAmount,
  }) async {
    final newCalories =
        (profile.targetCalories! + adjustmentAmount).clamp(1200, 9999);

    double? newProtein = profile.targetProteinG;
    double? newCarbs = profile.targetCarbsG;
    double? newFats = profile.targetFatsG;

    final oldCalories = profile.targetCalories!;
    if (oldCalories > 0 &&
        newProtein != null &&
        newCarbs != null &&
        newFats != null) {
      final scale = newCalories / oldCalories;
      newProtein = double.parse((newProtein * scale).toStringAsFixed(1));
      newCarbs = double.parse((newCarbs * scale).toStringAsFixed(1));
      newFats = double.parse((newFats * scale).toStringAsFixed(1));
    }

    final updated = profile.copyWith(
      targetCalories: newCalories,
      targetProteinG: newProtein,
      targetCarbsG: newCarbs,
      targetFatsG: newFats,
    );

    return _profileService.saveUserProfile(updated);
  }

  Future<void> recordShown(SharedPreferences prefs) async {
    await prefs.setString(
      _kLastShownKey,
      DateTime.now().toIso8601String().split('T')[0],
    );
  }

  Future<void> recordSnooze(SharedPreferences prefs) async {
    final until = DateTime.now().add(const Duration(days: 14));
    await prefs.setString(
      _kSnoozedUntilKey,
      until.toIso8601String().split('T')[0],
    );
  }

  bool _isCooldownActive(SharedPreferences prefs) {
    final raw = prefs.getString(_kLastShownKey);
    if (raw == null) return false;
    final last = DateTime.tryParse(raw);
    if (last == null) return false;
    return DateTime.now().difference(last).inDays < 7;
  }

  bool _isSnoozed(SharedPreferences prefs) {
    final raw = prefs.getString(_kSnoozedUntilKey);
    if (raw == null) return false;
    final until = DateTime.tryParse(raw);
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }
}
