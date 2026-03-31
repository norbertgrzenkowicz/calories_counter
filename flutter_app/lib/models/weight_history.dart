class WeightHistory {
  final int? id;
  final String? uid;

  // Weight Data
  final double weightKg;
  final DateTime recordedDate;

  // Context Information
  final String measurementTime; // 'morning', 'afternoon', 'evening'
  final String? notes;

  // Goal Tracking
  final String? goalAtTime;

  // Computed client-side after fetch (not stored in DB)
  final double? weightChangeKg;
  final double? weeklyAverageKg;
  final double? monthlyAverageKg;

  // Weight Loss Phase Tracking
  final String phase; // 'initial' or 'steady_state'

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WeightHistory({
    this.id,
    this.uid,
    required this.weightKg,
    DateTime? recordedDate,
    this.measurementTime = 'morning',
    this.notes,
    this.goalAtTime,
    this.weightChangeKg,
    this.weeklyAverageKg,
    this.monthlyAverageKg,
    this.phase = 'initial',
    this.createdAt,
    this.updatedAt,
  }) : recordedDate = recordedDate ?? DateTime.now();

  // Get measurement time display name
  String get measurementTimeDisplayName {
    switch (measurementTime) {
      case 'morning':
        return 'Morning';
      case 'afternoon':
        return 'Afternoon';
      case 'evening':
        return 'Evening';
      default:
        return 'Morning';
    }
  }

  // Get phase display name
  String get phaseDisplayName {
    switch (phase) {
      case 'initial':
        return 'Initial Phase (Higher Loss Rate)';
      case 'steady_state':
        return 'Steady State (Normal Loss Rate)';
      default:
        return 'Initial Phase';
    }
  }

  // Get goal display name
  String get goalDisplayName {
    switch (goalAtTime) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'weight_gain':
        return 'Weight Gain';
      case 'maintaining':
        return 'Maintaining';
      case 'hypertrophy':
        return 'Hypertrophy';
      default:
        return 'Unknown';
    }
  }

  // Get weight change description
  String get weightChangeDescription {
    if (weightChangeKg == null) return 'First entry';
    if (weightChangeKg! > 0) return '↑ ${weightChangeKg!.toStringAsFixed(1)} kg';
    if (weightChangeKg! < 0) return '↓ ${weightChangeKg!.abs().toStringAsFixed(1)} kg';
    return 'No change';
  }

  // Get weight change color (for UI)
  String get weightChangeColor {
    if (weightChangeKg == null) return 'neutral';
    if (goalAtTime == 'weight_loss') {
      return weightChangeKg! < 0 ? 'positive' : 'negative';
    } else if (goalAtTime == 'weight_gain') {
      return weightChangeKg! > 0 ? 'positive' : 'negative';
    }
    return 'neutral';
  }

  // Determine which energy content factor to use based on phase
  double get energyContentPerKg {
    // Two-phase weight loss kinetics
    switch (phase) {
      case 'initial':
        return 4858; // kcal/kg for first 4 weeks
      case 'steady_state':
        return 7700; // kcal/kg for steady state (classic Wishnofsky rule)
      default:
        return 7700;
    }
  }

  // Calculate expected weekly weight loss based on calorie deficit
  double calculateExpectedWeeklyLoss(int dailyCalorieDeficit) {
    final weeklyDeficit = dailyCalorieDeficit * 7;
    return weeklyDeficit / energyContentPerKg;
  }

  // Create copy with updated fields
  WeightHistory copyWith({
    int? id,
    String? uid,
    double? weightKg,
    DateTime? recordedDate,
    String? measurementTime,
    String? notes,
    String? goalAtTime,
    double? weightChangeKg,
    double? weeklyAverageKg,
    double? monthlyAverageKg,
    String? phase,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightHistory(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      weightKg: weightKg ?? this.weightKg,
      recordedDate: recordedDate ?? this.recordedDate,
      measurementTime: measurementTime ?? this.measurementTime,
      notes: notes ?? this.notes,
      goalAtTime: goalAtTime ?? this.goalAtTime,
      weightChangeKg: weightChangeKg ?? this.weightChangeKg,
      weeklyAverageKg: weeklyAverageKg ?? this.weeklyAverageKg,
      monthlyAverageKg: monthlyAverageKg ?? this.monthlyAverageKg,
      phase: phase ?? this.phase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to map for database storage
  Map<String, dynamic> toSupabase() {
    return {
      'uid': uid,
      'weight_kg': weightKg,
      'recorded_date': recordedDate.toIso8601String().split('T')[0],
      'measurement_time': measurementTime,
      'notes': notes,
      'goal_at_time': goalAtTime,
      'phase': phase,
    };
  }

  // Create from Supabase data
  static WeightHistory fromSupabase(Map<String, dynamic> data) {
    return WeightHistory(
      id: data['id'] as int?,
      uid: data['uid'] as String?,
      weightKg: ((data['weight_kg'] ?? 0.0) as num).toDouble(),
      recordedDate: DateTime.parse(
          (data['recorded_date'] as String?) ?? DateTime.now().toIso8601String()),
      measurementTime: (data['measurement_time'] as String?) ?? 'morning',
      notes: data['notes'] as String?,
      goalAtTime: data['goal_at_time'] as String?,
      phase: (data['phase'] as String?) ?? 'initial',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'WeightHistory(id: $id, weight: ${weightKg}kg, date: ${recordedDate.toIso8601String().split('T')[0]}, change: $weightChangeDescription)';
  }
}
