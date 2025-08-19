// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileFreezedImpl _$$UserProfileFreezedImplFromJson(
        Map<String, dynamic> json) =>
    _$UserProfileFreezedImpl(
      id: (json['id'] as num?)?.toInt(),
      uid: json['uid'] as String?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String? ?? 'male',
      heightCm: (json['heightCm'] as num).toDouble(),
      currentWeightKg: (json['currentWeightKg'] as num).toDouble(),
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
      goal: json['goal'] as String? ?? 'maintaining',
      activityLevel: (json['activityLevel'] as num?)?.toDouble() ?? 1.2,
      bmrCalories: (json['bmrCalories'] as num?)?.toInt(),
      tdeeCalories: (json['tdeeCalories'] as num?)?.toInt(),
      targetCalories: (json['targetCalories'] as num?)?.toInt(),
      targetProteinG: (json['targetProteinG'] as num?)?.toDouble(),
      targetCarbsG: (json['targetCarbsG'] as num?)?.toDouble(),
      targetFatsG: (json['targetFatsG'] as num?)?.toDouble(),
      weightLossStartDate: json['weightLossStartDate'] == null
          ? null
          : DateTime.parse(json['weightLossStartDate'] as String),
      initialWeightKg: (json['initialWeightKg'] as num?)?.toDouble(),
      weeklyWeightLossTarget:
          (json['weeklyWeightLossTarget'] as num?)?.toDouble() ?? 0.5,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserProfileFreezedImplToJson(
        _$UserProfileFreezedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'fullName': instance.fullName,
      'email': instance.email,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'heightCm': instance.heightCm,
      'currentWeightKg': instance.currentWeightKg,
      'targetWeightKg': instance.targetWeightKg,
      'goal': instance.goal,
      'activityLevel': instance.activityLevel,
      'bmrCalories': instance.bmrCalories,
      'tdeeCalories': instance.tdeeCalories,
      'targetCalories': instance.targetCalories,
      'targetProteinG': instance.targetProteinG,
      'targetCarbsG': instance.targetCarbsG,
      'targetFatsG': instance.targetFatsG,
      'weightLossStartDate': instance.weightLossStartDate?.toIso8601String(),
      'initialWeightKg': instance.initialWeightKg,
      'weeklyWeightLossTarget': instance.weeklyWeightLossTarget,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
