class UserProfile {
  final int? id;
  final String? uid;
  
  // Basic Profile Information
  final String? fullName;
  final String? email;
  final DateTime? dateOfBirth;
  
  // Physical Characteristics (required for BMR calculations)
  final String gender; // 'male' or 'female'
  final double heightCm;
  final double currentWeightKg;
  final double? targetWeightKg;
  
  // Goals and Activity
  final String goal; // 'weight_loss', 'weight_gain', 'maintaining', 'hypertrophy'
  final double activityLevel; // PAL value (1.2-2.4)
  
  // Calculated Values
  final int? bmrCalories;
  final int? tdeeCalories;
  final int? targetCalories;
  final double? targetProteinG;
  final double? targetCarbsG;
  final double? targetFatsG;
  
  // Weight Loss Tracking
  final DateTime? weightLossStartDate;
  final double? initialWeightKg;
  final double weeklyWeightLossTarget;
  
  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    this.id,
    this.uid,
    this.fullName,
    this.email,
    this.dateOfBirth,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    this.targetWeightKg,
    this.goal = 'maintaining',
    this.activityLevel = 1.2,
    this.bmrCalories,
    this.tdeeCalories,
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatsG,
    this.weightLossStartDate,
    this.initialWeightKg,
    this.weeklyWeightLossTarget = 0.5,
    this.createdAt,
    this.updatedAt,
  });

  // Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Check if profile has minimum required data for calculations
  bool get hasRequiredDataForCalculations {
    return gender.isNotEmpty && 
           heightCm > 0 && 
           currentWeightKg > 0 && 
           age != null && 
           age! > 0;
  }

  // Get goal display name
  String get goalDisplayName {
    switch (goal) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'weight_gain':
        return 'Weight Gain';
      case 'maintaining':
        return 'Maintaining';
      case 'hypertrophy':
        return 'Hypertrophy';
      default:
        return 'Maintaining';
    }
  }

  // Get activity level description
  String get activityLevelDescription {
    if (activityLevel <= 1.2) return 'Sedentary (little/no exercise)';
    if (activityLevel <= 1.375) return 'Light (light exercise 1-3 days/week)';
    if (activityLevel <= 1.55) return 'Moderate (moderate exercise 3-5 days/week)';
    if (activityLevel <= 1.725) return 'Active (hard exercise 6-7 days/week)';
    if (activityLevel <= 1.9) return 'Very Active (very hard exercise, physical job)';
    return 'Extremely Active (very hard exercise, physical job + training)';
  }

  // Calculate BMR using Mifflin-St Jeor equation
  int calculateBMR() {
    if (!hasRequiredDataForCalculations) return 0;
    
    // BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + s
    // where s = +5 for males, -161 for females
    final genderFactor = gender.toLowerCase() == 'male' ? 5 : -161;
    final bmr = (10 * currentWeightKg) + (6.25 * heightCm) - (5 * age!) + genderFactor;
    
    return bmr.round();
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  int calculateTDEE() {
    final bmr = calculateBMR();
    return (bmr * activityLevel).round();
  }

  // Calculate target calories based on goal
  int calculateTargetCalories() {
    final tdee = calculateTDEE();
    
    switch (goal) {
      case 'weight_loss':
        // Create deficit based on weekly target (1 kg/week = ~7700 kcal deficit = ~500 kcal/day)
        final dailyDeficit = (weeklyWeightLossTarget * 7700 / 7).round();
        return (tdee - dailyDeficit).clamp(1200, tdee); // Don't go below 1200 kcal
      
      case 'weight_gain':
        // Create surplus for weight gain (0.5 kg/week = ~250 kcal/day surplus)
        final dailySurplus = (weeklyWeightLossTarget * 7700 / 7).round();
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
  Map<String, double> calculateTargetMacros() {
    final targetCals = calculateTargetCalories();
    
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
    
    final protein = (currentWeightKg * proteinPerKg);
    final proteinCalories = protein * 4; // 4 kcal per gram
    
    // Fat: 0.8-1.2g per kg body weight (25-35% of total calories)
    final fatPercentage = goal == 'weight_loss' ? 0.25 : 0.30;
    final fatCalories = targetCals * fatPercentage;
    final fat = fatCalories / 9; // 9 kcal per gram
    
    // Carbs: remainder of calories
    final remainingCalories = targetCals - proteinCalories - fatCalories;
    final carbs = remainingCalories / 4; // 4 kcal per gram
    
    return {
      'protein': protein,
      'fat': fat,
      'carbs': carbs.clamp(0, double.infinity), // Ensure non-negative
    };
  }

  // Create copy with updated fields
  UserProfile copyWith({
    int? id,
    String? uid,
    String? fullName,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? goal,
    double? activityLevel,
    int? bmrCalories,
    int? tdeeCalories,
    int? targetCalories,
    double? targetProteinG,
    double? targetCarbsG,
    double? targetFatsG,
    DateTime? weightLossStartDate,
    double? initialWeightKg,
    double? weeklyWeightLossTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      bmrCalories: bmrCalories ?? this.bmrCalories,
      tdeeCalories: tdeeCalories ?? this.tdeeCalories,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      targetCarbsG: targetCarbsG ?? this.targetCarbsG,
      targetFatsG: targetFatsG ?? this.targetFatsG,
      weightLossStartDate: weightLossStartDate ?? this.weightLossStartDate,
      initialWeightKg: initialWeightKg ?? this.initialWeightKg,
      weeklyWeightLossTarget: weeklyWeightLossTarget ?? this.weeklyWeightLossTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to map for database storage
  Map<String, dynamic> toSupabase() {
    // Only calculate macros if we have the required data
    Map<String, double> macros = {'protein': 0.0, 'carbs': 0.0, 'fat': 0.0};
    int bmrCalories = 0;
    int tdeeCalories = 0;
    int targetCalories = 0;
    
    if (hasRequiredDataForCalculations) {
      try {
        macros = calculateTargetMacros();
        bmrCalories = calculateBMR();
        tdeeCalories = calculateTDEE();
        targetCalories = calculateTargetCalories();
      } catch (e) {
        print('Error calculating nutrition values: $e');
        // Use defaults if calculation fails
      }
    }
    
    return {
      'uid': uid,
      'full_name': fullName?.isNotEmpty == true ? fullName : null,
      'email': email?.isNotEmpty == true ? email : null,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0], // Date only
      'gender': gender,
      'height_cm': heightCm,
      'current_weight_kg': currentWeightKg,
      'target_weight_kg': targetWeightKg,
      'goal': goal,
      'activity_level': activityLevel,
      'bmr_calories': bmrCalories,
      'tdee_calories': tdeeCalories,
      'target_calories': targetCalories,
      'target_protein_g': macros['protein'],
      'target_carbs_g': macros['carbs'],
      'target_fats_g': macros['fat'],
      'weight_loss_start_date': weightLossStartDate?.toIso8601String().split('T')[0],
      'initial_weight_kg': initialWeightKg,
      'weekly_weight_loss_target': weeklyWeightLossTarget,
    };
  }

  // Create from Supabase data
  static UserProfile fromSupabase(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'],
      uid: data['uid'],
      fullName: data['full_name'],
      email: data['email'],
      dateOfBirth: data['date_of_birth'] != null 
          ? DateTime.parse(data['date_of_birth'])
          : null,
      gender: data['gender'] ?? 'male',
      heightCm: (data['height_cm'] ?? 0.0).toDouble(),
      currentWeightKg: (data['current_weight_kg'] ?? 0.0).toDouble(),
      targetWeightKg: data['target_weight_kg']?.toDouble(),
      goal: data['goal'] ?? 'maintaining',
      activityLevel: (data['activity_level'] ?? 1.2).toDouble(),
      bmrCalories: data['bmr_calories']?.toInt(),
      tdeeCalories: data['tdee_calories']?.toInt(),
      targetCalories: data['target_calories']?.toInt(),
      targetProteinG: data['target_protein_g']?.toDouble(),
      targetCarbsG: data['target_carbs_g']?.toDouble(),
      targetFatsG: data['target_fats_g']?.toDouble(),
      weightLossStartDate: data['weight_loss_start_date'] != null
          ? DateTime.parse(data['weight_loss_start_date'])
          : null,
      initialWeightKg: data['initial_weight_kg']?.toDouble(),
      weeklyWeightLossTarget: (data['weekly_weight_loss_target'] ?? 0.5).toDouble(),
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at'])
          : null,
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at'])
          : null,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, gender: $gender, age: $age, height: ${heightCm}cm, weight: ${currentWeightKg}kg, goal: $goal)';
  }
}