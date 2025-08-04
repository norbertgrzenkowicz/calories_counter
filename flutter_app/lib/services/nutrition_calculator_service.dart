import '../models/user_profile.dart';
import '../models/weight_history.dart';

class NutritionCalculatorService {
  static final NutritionCalculatorService _instance = NutritionCalculatorService._internal();
  factory NutritionCalculatorService() => _instance;
  NutritionCalculatorService._internal();

  // Physical Activity Level (PAL) mapping based on scientific research
  static const Map<String, double> activityLevels = {
    'sedentary': 1.2,           // Little/no exercise
    'lightly_active': 1.375,    // Light exercise 1-3 days/week
    'moderately_active': 1.55,  // Moderate exercise 3-5 days/week
    'very_active': 1.725,       // Hard exercise 6-7 days/week
    'extremely_active': 1.9,    // Very hard exercise, physical job + training
  };

  // Activity level descriptions for UI
  static const Map<String, String> activityDescriptions = {
    'sedentary': 'Sedentary (little/no exercise)',
    'lightly_active': 'Light (light exercise 1-3 days/week)',
    'moderately_active': 'Moderate (moderate exercise 3-5 days/week)',
    'very_active': 'Active (hard exercise 6-7 days/week)',
    'extremely_active': 'Very Active (very hard exercise, physical job)',
  };

  // Get PAL value from activity key
  static double getPALValue(String activityKey) {
    return activityLevels[activityKey] ?? 1.2;
  }

  // Get activity description from PAL value
  static String getActivityDescription(double palValue) {
    if (palValue <= 1.2) return activityDescriptions['sedentary']!;
    if (palValue <= 1.375) return activityDescriptions['lightly_active']!;
    if (palValue <= 1.55) return activityDescriptions['moderately_active']!;
    if (palValue <= 1.725) return activityDescriptions['very_active']!;
    return activityDescriptions['extremely_active']!;
  }

  // Get activity key from PAL value
  static String getActivityKey(double palValue) {
    if (palValue <= 1.2) return 'sedentary';
    if (palValue <= 1.375) return 'lightly_active';
    if (palValue <= 1.55) return 'moderately_active';
    if (palValue <= 1.725) return 'very_active';
    return 'extremely_active';
  }

  // Calculate BMR using Mifflin-St Jeor equation
  static int calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    // BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + s
    // where s = +5 for males, -161 for females
    final genderFactor = gender.toLowerCase() == 'male' ? 5 : -161;
    final bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + genderFactor;
    
    return bmr.round();
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  static int calculateTDEE({
    required int bmr,
    required double activityLevel,
  }) {
    return (bmr * activityLevel).round();
  }

  // Calculate target calories based on goal
  static int calculateTargetCalories({
    required int tdee,
    required String goal,
    required double weeklyWeightChangeTarget,
  }) {
    switch (goal) {
      case 'weight_loss':
        // Create deficit based on weekly target (1 kg/week = ~7700 kcal deficit = ~500 kcal/day)
        final dailyDeficit = (weeklyWeightChangeTarget * 7700 / 7).round();
        return (tdee - dailyDeficit).clamp(1200, tdee); // Don't go below 1200 kcal
      
      case 'weight_gain':
        // Create surplus for weight gain
        final dailySurplus = (weeklyWeightChangeTarget * 7700 / 7).round();
        return tdee + dailySurplus;
      
      case 'hypertrophy':
        // Slight surplus for muscle building
        return tdee + 200;
      
      case 'maintaining':
      default:
        return tdee;
    }
  }

  // Calculate target macros
  static Map<String, double> calculateTargetMacros({
    required int targetCalories,
    required double weightKg,
    required String goal,
  }) {
    // Protein: 1.6-2.2g per kg body weight (higher for weight loss/hypertrophy)
    double proteinPerKg;
    switch (goal) {
      case 'weight_loss':
      case 'hypertrophy':
        proteinPerKg = 2.0;
        break;
      case 'weight_gain':
        proteinPerKg = 1.8;
        break;
      default:
        proteinPerKg = 1.6;
    }
    
    final protein = (weightKg * proteinPerKg);
    final proteinCalories = protein * 4; // 4 kcal per gram
    
    // Fat: 25-35% of total calories depending on goal
    final fatPercentage = goal == 'weight_loss' ? 0.25 : 0.30;
    final fatCalories = targetCalories * fatPercentage;
    final fat = fatCalories / 9; // 9 kcal per gram
    
    // Carbs: remainder of calories
    final remainingCalories = targetCalories - proteinCalories - fatCalories;
    final carbs = remainingCalories / 4; // 4 kcal per gram
    
    return {
      'protein': protein,
      'fat': fat,
      'carbs': carbs.clamp(0, double.infinity), // Ensure non-negative
    };
  }

  // Calculate complete nutrition profile from UserProfile
  static Map<String, dynamic> calculateCompleteNutritionProfile(UserProfile profile) {
    if (!profile.hasRequiredDataForCalculations) {
      return {
        'error': 'Insufficient profile data for calculations',
        'bmr': 0,
        'tdee': 0,
        'targetCalories': 0,
        'macros': {'protein': 0.0, 'fat': 0.0, 'carbs': 0.0},
      };
    }

    final bmr = calculateBMR(
      weightKg: profile.currentWeightKg,
      heightCm: profile.heightCm,
      age: profile.age!,
      gender: profile.gender,
    );

    final tdee = calculateTDEE(
      bmr: bmr,
      activityLevel: profile.activityLevel,
    );

    final targetCalories = calculateTargetCalories(
      tdee: tdee,
      goal: profile.goal,
      weeklyWeightChangeTarget: profile.weeklyWeightLossTarget,
    );

    final macros = calculateTargetMacros(
      targetCalories: targetCalories,
      weightKg: profile.currentWeightKg,
      goal: profile.goal,
    );

    return {
      'bmr': bmr,
      'tdee': tdee,
      'targetCalories': targetCalories,
      'macros': macros,
      'activityDescription': getActivityDescription(profile.activityLevel),
      'goalDescription': profile.goalDisplayName,
    };
  }

  // Calculate expected weight change based on calorie deficit/surplus
  static double calculateExpectedWeightChange({
    required int calorieDeficit, // Negative for deficit, positive for surplus
    required int days,
    required bool isInitialPhase,
  }) {
    // Two-phase weight loss kinetics
    final energyContentPerKg = isInitialPhase ? 4858.0 : 7700.0; // kcal/kg
    final totalEnergyChange = calorieDeficit * days;
    return totalEnergyChange / energyContentPerKg;
  }

  // Analyze weight progress vs expected progress
  static Map<String, dynamic> analyzeWeightProgress({
    required List<WeightHistory> weightHistory,
    required int dailyCalorieDeficit,
  }) {
    if (weightHistory.length < 2) {
      return {
        'error': 'Insufficient weight data for analysis',
        'hasProgress': false,
      };
    }

    // Sort by date (oldest first)
    final sortedHistory = weightHistory.toList()
      ..sort((a, b) => a.recordedDate.compareTo(b.recordedDate));

    final firstEntry = sortedHistory.first;
    final lastEntry = sortedHistory.last;
    final daysBetween = lastEntry.recordedDate.difference(firstEntry.recordedDate).inDays;

    if (daysBetween <= 0) {
      return {
        'error': 'Invalid date range',
        'hasProgress': false,
      };
    }

    final actualWeightChange = lastEntry.weightKg - firstEntry.weightKg;
    
    // Determine if we're in initial phase (first 28 days of weight loss)
    final isInitialPhase = daysBetween <= 28;
    
    final expectedWeightChange = calculateExpectedWeightChange(
      calorieDeficit: -dailyCalorieDeficit, // Negative because we want weight loss
      days: daysBetween,
      isInitialPhase: isInitialPhase,
    );

    final progressPercentage = expectedWeightChange != 0 
        ? (actualWeightChange / expectedWeightChange) * 100
        : 0.0;

    String progressStatus;
    String recommendation;

    if (progressPercentage > 120) {
      progressStatus = 'exceeding';
      recommendation = 'Weight loss is faster than expected. Consider increasing calorie intake slightly to ensure sustainable progress.';
    } else if (progressPercentage > 80) {
      progressStatus = 'on_track';
      recommendation = 'Excellent progress! Continue with current plan.';
    } else if (progressPercentage > 50) {
      progressStatus = 'slow_progress';
      recommendation = 'Progress is slower than expected. Consider increasing activity or reducing calorie intake slightly.';
    } else {
      progressStatus = 'minimal_progress';
      recommendation = 'Very slow progress. Review your calorie tracking accuracy and consider adjusting your plan.';
    }

    return {
      'hasProgress': true,
      'actualWeightChange': actualWeightChange,
      'expectedWeightChange': expectedWeightChange,
      'progressPercentage': progressPercentage,
      'progressStatus': progressStatus,
      'recommendation': recommendation,
      'daysBetween': daysBetween,
      'isInitialPhase': isInitialPhase,
      'weeklyActualChange': (actualWeightChange / daysBetween) * 7,
      'weeklyExpectedChange': (expectedWeightChange / daysBetween) * 7,
    };
  }

  // Get recommended calorie adjustment based on progress
  static int getRecommendedCalorieAdjustment({
    required String progressStatus,
    required int currentTargetCalories,
  }) {
    switch (progressStatus) {
      case 'exceeding':
        return 100; // Increase by 100 kcal
      case 'on_track':
        return 0; // No change needed
      case 'slow_progress':
        return -100; // Decrease by 100 kcal
      case 'minimal_progress':
        return -200; // Decrease by 200 kcal
      default:
        return 0;
    }
  }

  // Validate nutrition targets are realistic
  static Map<String, dynamic> validateNutritionTargets({
    required int targetCalories,
    required Map<String, double> macros,
    required double weightKg,
    required String gender,
  }) {
    final warnings = <String>[];
    bool isValid = true;

    // Check minimum calorie intake
    final minCalories = gender.toLowerCase() == 'male' ? 1500 : 1200;
    if (targetCalories < minCalories) {
      warnings.add('Target calories ($targetCalories) below recommended minimum ($minCalories)');
      isValid = false;
    }

    // Check protein intake
    final proteinPerKg = macros['protein']! / weightKg;
    if (proteinPerKg < 0.8) {
      warnings.add('Protein intake too low (${proteinPerKg.toStringAsFixed(1)}g/kg). Minimum 0.8g/kg recommended.');
      isValid = false;
    } else if (proteinPerKg > 3.0) {
      warnings.add('Protein intake very high (${proteinPerKg.toStringAsFixed(1)}g/kg). Consider reducing.');
    }

    // Check fat intake
    final fatCalories = macros['fat']! * 9;
    final fatPercentage = (fatCalories / targetCalories) * 100;
    if (fatPercentage < 20) {
      warnings.add('Fat intake too low (${fatPercentage.toStringAsFixed(1)}%). Minimum 20% recommended.');
      isValid = false;
    } else if (fatPercentage > 40) {
      warnings.add('Fat intake very high (${fatPercentage.toStringAsFixed(1)}%). Consider reducing.');
    }

    return {
      'isValid': isValid,
      'warnings': warnings,
      'proteinPerKg': proteinPerKg,
      'fatPercentage': fatPercentage,
    };
  }
}