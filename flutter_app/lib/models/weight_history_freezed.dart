import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_history_freezed.freezed.dart';
part 'weight_history_freezed.g.dart';

/// Immutable data model for weight history tracking using Freezed
///
/// Provides comprehensive weight tracking with context information,
/// goal tracking, and calculated fields for progress analysis.
@freezed
class WeightHistoryFreezed with _$WeightHistoryFreezed {
  /// Creates a new weight history entry
  const factory WeightHistoryFreezed({
    /// Database ID for the weight entry
    int? id,

    /// User authentication ID
    String? uid,

    // Weight Data
    /// Weight measurement in kilograms
    required double weightKg,

    /// Date when weight was recorded
    required DateTime recordedDate,

    // Context Information
    /// Time of day when measured
    @Default('morning')
    String measurementTime, // 'morning', 'afternoon', 'evening'

    /// Optional notes about the measurement
    String? notes,

    // Goal Tracking
    /// User's goal at the time of measurement
    String? goalAtTime,

    /// Number of days since goal started
    @Default(0) int daysSinceGoalStart,

    // Calculated Fields
    /// Change from previous measurement
    double? weightChangeKg,

    /// Weekly average weight
    double? weeklyAverageKg,

    /// Monthly average weight
    double? monthlyAverageKg,

    // Weight Loss Phase Tracking
    /// Whether this is in the initial weight loss phase
    @Default(false) bool isInitialPhase,

    /// Current phase of weight loss journey
    @Default('steady_state') String phase, // 'initial' or 'steady_state'

    // Timestamps
    /// Entry creation timestamp
    DateTime? createdAt,

    /// Entry last update timestamp
    DateTime? updatedAt,
  }) = _WeightHistoryFreezed;

  /// Creates a WeightHistoryFreezed instance from JSON data
  factory WeightHistoryFreezed.fromJson(Map<String, dynamic> json) =>
      _$WeightHistoryFreezedFromJson(json);

  /// Creates a WeightHistoryFreezed instance from Supabase response data
  factory WeightHistoryFreezed.fromSupabase(Map<String, dynamic> data) {
    return WeightHistoryFreezed(
      id: data['id'] as int?,
      uid: data['uid'] as String?,
      weightKg: _safeParseDouble(data['weight_kg']),
      recordedDate: _parseDate(data['recorded_date']) ?? DateTime.now(),
      measurementTime: data['measurement_time'] as String? ?? 'morning',
      notes: data['notes'] as String?,
      goalAtTime: data['goal_at_time'] as String?,
      daysSinceGoalStart: data['days_since_goal_start'] as int? ?? 0,
      weightChangeKg: data['weight_change_kg'] != null
          ? _safeParseDouble(data['weight_change_kg'])
          : null,
      weeklyAverageKg: data['weekly_average_kg'] != null
          ? _safeParseDouble(data['weekly_average_kg'])
          : null,
      monthlyAverageKg: data['monthly_average_kg'] != null
          ? _safeParseDouble(data['monthly_average_kg'])
          : null,
      isInitialPhase: data['is_initial_phase'] as bool? ?? false,
      phase: data['phase'] as String? ?? 'steady_state',
      createdAt: _parseDate(data['created_at']),
      updatedAt: _parseDate(data['updated_at']),
    );
  }
}

/// Extension methods for WeightHistoryFreezed
extension WeightHistoryFreezedExtension on WeightHistoryFreezed {
  /// Converts to Supabase-compatible map for database operations
  Map<String, dynamic> toSupabase() {
    return {
      'uid': uid,
      'weight_kg': weightKg,
      'recorded_date': recordedDate.toIso8601String(),
      'measurement_time': measurementTime,
      'notes': notes,
      'goal_at_time': goalAtTime,
      'days_since_goal_start': daysSinceGoalStart,
      'weight_change_kg': weightChangeKg,
      'weekly_average_kg': weeklyAverageKg,
      'monthly_average_kg': monthlyAverageKg,
      'is_initial_phase': isInitialPhase,
      'phase': phase,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Gets display name for measurement time
  String get measurementTimeDisplayName {
    switch (measurementTime.toLowerCase()) {
      case 'morning':
        return 'Morning';
      case 'afternoon':
        return 'Afternoon';
      case 'evening':
        return 'Evening';
      default:
        return measurementTime.replaceFirst(
            measurementTime[0], measurementTime[0].toUpperCase());
    }
  }

  /// Gets weight change description for UI
  String get weightChangeDescription {
    if (weightChangeKg == null || weightChangeKg == 0) return 'No change';

    final change = weightChangeKg!;
    final absChange = change.abs();

    if (change > 0) {
      return '+${absChange.toStringAsFixed(1)}kg';
    } else {
      return '-${absChange.toStringAsFixed(1)}kg';
    }
  }

  /// Gets weight change color category for UI
  String get weightChangeColor {
    if (weightChangeKg == null || weightChangeKg == 0) return 'neutral';

    return weightChangeKg! < 0 ? 'negative' : 'positive';
  }

  /// Gets formatted date string
  String get formattedDate =>
      '${recordedDate.day}/${recordedDate.month}/${recordedDate.year}';

  /// Checks if this entry is from today
  bool get isToday {
    final now = DateTime.now();
    return recordedDate.year == now.year &&
        recordedDate.month == now.month &&
        recordedDate.day == now.day;
  }

  /// Checks if this entry is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return recordedDate.isAfter(startOfWeek.subtract(const Duration(days: 1)));
  }

  /// Gets days since this measurement
  int get daysSinceMeasurement =>
      DateTime.now().difference(recordedDate).inDays;
}

// Helper functions for safe parsing
double _safeParseDouble(dynamic value) {
  if (value == null) return 0.0;

  if (value is double) {
    return value.isFinite ? value : 0.0;
  }

  if (value is int) {
    return value.toDouble();
  }

  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed?.isFinite == true ? parsed! : 0.0;
  }

  if (value is num) {
    final asDouble = value.toDouble();
    return asDouble.isFinite ? asDouble : 0.0;
  }

  return 0.0;
}

DateTime? _parseDate(dynamic dateValue) {
  if (dateValue == null) return null;

  if (dateValue is DateTime) return dateValue;

  if (dateValue is String) {
    try {
      return DateTime.parse(dateValue);
    } catch (e) {
      return null;
    }
  }

  return null;
}
