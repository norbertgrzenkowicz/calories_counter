// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_history_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeightHistoryFreezedImpl _$$WeightHistoryFreezedImplFromJson(
        Map<String, dynamic> json) =>
    _$WeightHistoryFreezedImpl(
      id: (json['id'] as num?)?.toInt(),
      uid: json['uid'] as String?,
      weightKg: (json['weightKg'] as num).toDouble(),
      recordedDate: DateTime.parse(json['recordedDate'] as String),
      measurementTime: json['measurementTime'] as String? ?? 'morning',
      notes: json['notes'] as String?,
      goalAtTime: json['goalAtTime'] as String?,
      daysSinceGoalStart: (json['daysSinceGoalStart'] as num?)?.toInt() ?? 0,
      weightChangeKg: (json['weightChangeKg'] as num?)?.toDouble(),
      weeklyAverageKg: (json['weeklyAverageKg'] as num?)?.toDouble(),
      monthlyAverageKg: (json['monthlyAverageKg'] as num?)?.toDouble(),
      isInitialPhase: json['isInitialPhase'] as bool? ?? false,
      phase: json['phase'] as String? ?? 'steady_state',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WeightHistoryFreezedImplToJson(
        _$WeightHistoryFreezedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'weightKg': instance.weightKg,
      'recordedDate': instance.recordedDate.toIso8601String(),
      'measurementTime': instance.measurementTime,
      'notes': instance.notes,
      'goalAtTime': instance.goalAtTime,
      'daysSinceGoalStart': instance.daysSinceGoalStart,
      'weightChangeKg': instance.weightChangeKg,
      'weeklyAverageKg': instance.weeklyAverageKg,
      'monthlyAverageKg': instance.monthlyAverageKg,
      'isInitialPhase': instance.isInitialPhase,
      'phase': instance.phase,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
