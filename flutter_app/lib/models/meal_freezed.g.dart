// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealFreezedImpl _$$MealFreezedImplFromJson(Map<String, dynamic> json) =>
    _$MealFreezedImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      uid: json['uid'] as String?,
      calories: (json['calories'] as num).toInt(),
      proteins: (json['proteins'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      photoUrl: json['photoUrl'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MealFreezedImplToJson(_$MealFreezedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'uid': instance.uid,
      'calories': instance.calories,
      'proteins': instance.proteins,
      'fats': instance.fats,
      'carbs': instance.carbs,
      'photoUrl': instance.photoUrl,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
