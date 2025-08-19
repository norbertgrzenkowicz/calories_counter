// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfileFreezed _$UserProfileFreezedFromJson(Map<String, dynamic> json) {
  return _UserProfileFreezed.fromJson(json);
}

/// @nodoc
mixin _$UserProfileFreezed {
  /// Database ID for the profile
  int? get id => throw _privateConstructorUsedError;

  /// User authentication ID
  String? get uid =>
      throw _privateConstructorUsedError; // Basic Profile Information
  /// User's full name
  String? get fullName => throw _privateConstructorUsedError;

  /// User's email address
  String? get email => throw _privateConstructorUsedError;

  /// User's date of birth
  DateTime? get dateOfBirth =>
      throw _privateConstructorUsedError; // Physical Characteristics (required for BMR calculations)
  /// Biological sex ('male' or 'female')
  String get gender => throw _privateConstructorUsedError;

  /// Height in centimeters
  double get heightCm => throw _privateConstructorUsedError;

  /// Current weight in kilograms
  double get currentWeightKg => throw _privateConstructorUsedError;

  /// Target weight in kilograms (optional)
  double? get targetWeightKg =>
      throw _privateConstructorUsedError; // Goals and Activity
  /// Primary fitness goal
  String get goal =>
      throw _privateConstructorUsedError; // 'weight_loss', 'weight_gain', 'maintaining', 'hypertrophy'
  /// Physical Activity Level (PAL) value
  double get activityLevel =>
      throw _privateConstructorUsedError; // PAL value (1.2-2.4)
// Calculated Values
  /// Basal Metabolic Rate in calories
  int? get bmrCalories => throw _privateConstructorUsedError;

  /// Total Daily Energy Expenditure in calories
  int? get tdeeCalories => throw _privateConstructorUsedError;

  /// Target daily calories for goal achievement
  int? get targetCalories => throw _privateConstructorUsedError;

  /// Target protein intake in grams
  double? get targetProteinG => throw _privateConstructorUsedError;

  /// Target carbohydrate intake in grams
  double? get targetCarbsG => throw _privateConstructorUsedError;

  /// Target fat intake in grams
  double? get targetFatsG =>
      throw _privateConstructorUsedError; // Weight Loss Tracking
  /// Date when weight loss journey started
  DateTime? get weightLossStartDate => throw _privateConstructorUsedError;

  /// Initial weight when starting weight loss
  double? get initialWeightKg => throw _privateConstructorUsedError;

  /// Weekly weight loss target in kg/week
  double get weeklyWeightLossTarget =>
      throw _privateConstructorUsedError; // Timestamps
  /// Profile creation timestamp
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Profile last update timestamp
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserProfileFreezed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileFreezed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileFreezedCopyWith<UserProfileFreezed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileFreezedCopyWith<$Res> {
  factory $UserProfileFreezedCopyWith(
          UserProfileFreezed value, $Res Function(UserProfileFreezed) then) =
      _$UserProfileFreezedCopyWithImpl<$Res, UserProfileFreezed>;
  @useResult
  $Res call(
      {int? id,
      String? uid,
      String? fullName,
      String? email,
      DateTime? dateOfBirth,
      String gender,
      double heightCm,
      double currentWeightKg,
      double? targetWeightKg,
      String goal,
      double activityLevel,
      int? bmrCalories,
      int? tdeeCalories,
      int? targetCalories,
      double? targetProteinG,
      double? targetCarbsG,
      double? targetFatsG,
      DateTime? weightLossStartDate,
      double? initialWeightKg,
      double weeklyWeightLossTarget,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$UserProfileFreezedCopyWithImpl<$Res, $Val extends UserProfileFreezed>
    implements $UserProfileFreezedCopyWith<$Res> {
  _$UserProfileFreezedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileFreezed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? uid = freezed,
    Object? fullName = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = null,
    Object? heightCm = null,
    Object? currentWeightKg = null,
    Object? targetWeightKg = freezed,
    Object? goal = null,
    Object? activityLevel = null,
    Object? bmrCalories = freezed,
    Object? tdeeCalories = freezed,
    Object? targetCalories = freezed,
    Object? targetProteinG = freezed,
    Object? targetCarbsG = freezed,
    Object? targetFatsG = freezed,
    Object? weightLossStartDate = freezed,
    Object? initialWeightKg = freezed,
    Object? weeklyWeightLossTarget = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      currentWeightKg: null == currentWeightKg
          ? _value.currentWeightKg
          : currentWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeightKg: freezed == targetWeightKg
          ? _value.targetWeightKg
          : targetWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as String,
      activityLevel: null == activityLevel
          ? _value.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as double,
      bmrCalories: freezed == bmrCalories
          ? _value.bmrCalories
          : bmrCalories // ignore: cast_nullable_to_non_nullable
              as int?,
      tdeeCalories: freezed == tdeeCalories
          ? _value.tdeeCalories
          : tdeeCalories // ignore: cast_nullable_to_non_nullable
              as int?,
      targetCalories: freezed == targetCalories
          ? _value.targetCalories
          : targetCalories // ignore: cast_nullable_to_non_nullable
              as int?,
      targetProteinG: freezed == targetProteinG
          ? _value.targetProteinG
          : targetProteinG // ignore: cast_nullable_to_non_nullable
              as double?,
      targetCarbsG: freezed == targetCarbsG
          ? _value.targetCarbsG
          : targetCarbsG // ignore: cast_nullable_to_non_nullable
              as double?,
      targetFatsG: freezed == targetFatsG
          ? _value.targetFatsG
          : targetFatsG // ignore: cast_nullable_to_non_nullable
              as double?,
      weightLossStartDate: freezed == weightLossStartDate
          ? _value.weightLossStartDate
          : weightLossStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      initialWeightKg: freezed == initialWeightKg
          ? _value.initialWeightKg
          : initialWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      weeklyWeightLossTarget: null == weeklyWeightLossTarget
          ? _value.weeklyWeightLossTarget
          : weeklyWeightLossTarget // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileFreezedImplCopyWith<$Res>
    implements $UserProfileFreezedCopyWith<$Res> {
  factory _$$UserProfileFreezedImplCopyWith(_$UserProfileFreezedImpl value,
          $Res Function(_$UserProfileFreezedImpl) then) =
      __$$UserProfileFreezedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? uid,
      String? fullName,
      String? email,
      DateTime? dateOfBirth,
      String gender,
      double heightCm,
      double currentWeightKg,
      double? targetWeightKg,
      String goal,
      double activityLevel,
      int? bmrCalories,
      int? tdeeCalories,
      int? targetCalories,
      double? targetProteinG,
      double? targetCarbsG,
      double? targetFatsG,
      DateTime? weightLossStartDate,
      double? initialWeightKg,
      double weeklyWeightLossTarget,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$UserProfileFreezedImplCopyWithImpl<$Res>
    extends _$UserProfileFreezedCopyWithImpl<$Res, _$UserProfileFreezedImpl>
    implements _$$UserProfileFreezedImplCopyWith<$Res> {
  __$$UserProfileFreezedImplCopyWithImpl(_$UserProfileFreezedImpl _value,
      $Res Function(_$UserProfileFreezedImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfileFreezed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? uid = freezed,
    Object? fullName = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = null,
    Object? heightCm = null,
    Object? currentWeightKg = null,
    Object? targetWeightKg = freezed,
    Object? goal = null,
    Object? activityLevel = null,
    Object? bmrCalories = freezed,
    Object? tdeeCalories = freezed,
    Object? targetCalories = freezed,
    Object? targetProteinG = freezed,
    Object? targetCarbsG = freezed,
    Object? targetFatsG = freezed,
    Object? weightLossStartDate = freezed,
    Object? initialWeightKg = freezed,
    Object? weeklyWeightLossTarget = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserProfileFreezedImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      currentWeightKg: null == currentWeightKg
          ? _value.currentWeightKg
          : currentWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeightKg: freezed == targetWeightKg
          ? _value.targetWeightKg
          : targetWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as String,
      activityLevel: null == activityLevel
          ? _value.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as double,
      bmrCalories: freezed == bmrCalories
          ? _value.bmrCalories
          : bmrCalories // ignore: cast_nullable_to_non_nullable
              as int?,
      tdeeCalories: freezed == tdeeCalories
          ? _value.tdeeCalories
          : tdeeCalories // ignore: cast_nullable_to_non_nullable
              as int?,
      targetCalories: freezed == targetCalories
          ? _value.targetCalories
          : targetCalories // ignore: cast_nullable_to_non_nullable
              as int?,
      targetProteinG: freezed == targetProteinG
          ? _value.targetProteinG
          : targetProteinG // ignore: cast_nullable_to_non_nullable
              as double?,
      targetCarbsG: freezed == targetCarbsG
          ? _value.targetCarbsG
          : targetCarbsG // ignore: cast_nullable_to_non_nullable
              as double?,
      targetFatsG: freezed == targetFatsG
          ? _value.targetFatsG
          : targetFatsG // ignore: cast_nullable_to_non_nullable
              as double?,
      weightLossStartDate: freezed == weightLossStartDate
          ? _value.weightLossStartDate
          : weightLossStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      initialWeightKg: freezed == initialWeightKg
          ? _value.initialWeightKg
          : initialWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      weeklyWeightLossTarget: null == weeklyWeightLossTarget
          ? _value.weeklyWeightLossTarget
          : weeklyWeightLossTarget // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileFreezedImpl implements _UserProfileFreezed {
  const _$UserProfileFreezedImpl(
      {this.id,
      this.uid,
      this.fullName,
      this.email,
      this.dateOfBirth,
      this.gender = 'male',
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
      this.updatedAt});

  factory _$UserProfileFreezedImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileFreezedImplFromJson(json);

  /// Database ID for the profile
  @override
  final int? id;

  /// User authentication ID
  @override
  final String? uid;
// Basic Profile Information
  /// User's full name
  @override
  final String? fullName;

  /// User's email address
  @override
  final String? email;

  /// User's date of birth
  @override
  final DateTime? dateOfBirth;
// Physical Characteristics (required for BMR calculations)
  /// Biological sex ('male' or 'female')
  @override
  @JsonKey()
  final String gender;

  /// Height in centimeters
  @override
  final double heightCm;

  /// Current weight in kilograms
  @override
  final double currentWeightKg;

  /// Target weight in kilograms (optional)
  @override
  final double? targetWeightKg;
// Goals and Activity
  /// Primary fitness goal
  @override
  @JsonKey()
  final String goal;
// 'weight_loss', 'weight_gain', 'maintaining', 'hypertrophy'
  /// Physical Activity Level (PAL) value
  @override
  @JsonKey()
  final double activityLevel;
// PAL value (1.2-2.4)
// Calculated Values
  /// Basal Metabolic Rate in calories
  @override
  final int? bmrCalories;

  /// Total Daily Energy Expenditure in calories
  @override
  final int? tdeeCalories;

  /// Target daily calories for goal achievement
  @override
  final int? targetCalories;

  /// Target protein intake in grams
  @override
  final double? targetProteinG;

  /// Target carbohydrate intake in grams
  @override
  final double? targetCarbsG;

  /// Target fat intake in grams
  @override
  final double? targetFatsG;
// Weight Loss Tracking
  /// Date when weight loss journey started
  @override
  final DateTime? weightLossStartDate;

  /// Initial weight when starting weight loss
  @override
  final double? initialWeightKg;

  /// Weekly weight loss target in kg/week
  @override
  @JsonKey()
  final double weeklyWeightLossTarget;
// Timestamps
  /// Profile creation timestamp
  @override
  final DateTime? createdAt;

  /// Profile last update timestamp
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserProfileFreezed(id: $id, uid: $uid, fullName: $fullName, email: $email, dateOfBirth: $dateOfBirth, gender: $gender, heightCm: $heightCm, currentWeightKg: $currentWeightKg, targetWeightKg: $targetWeightKg, goal: $goal, activityLevel: $activityLevel, bmrCalories: $bmrCalories, tdeeCalories: $tdeeCalories, targetCalories: $targetCalories, targetProteinG: $targetProteinG, targetCarbsG: $targetCarbsG, targetFatsG: $targetFatsG, weightLossStartDate: $weightLossStartDate, initialWeightKg: $initialWeightKg, weeklyWeightLossTarget: $weeklyWeightLossTarget, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileFreezedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.currentWeightKg, currentWeightKg) ||
                other.currentWeightKg == currentWeightKg) &&
            (identical(other.targetWeightKg, targetWeightKg) ||
                other.targetWeightKg == targetWeightKg) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.bmrCalories, bmrCalories) ||
                other.bmrCalories == bmrCalories) &&
            (identical(other.tdeeCalories, tdeeCalories) ||
                other.tdeeCalories == tdeeCalories) &&
            (identical(other.targetCalories, targetCalories) ||
                other.targetCalories == targetCalories) &&
            (identical(other.targetProteinG, targetProteinG) ||
                other.targetProteinG == targetProteinG) &&
            (identical(other.targetCarbsG, targetCarbsG) ||
                other.targetCarbsG == targetCarbsG) &&
            (identical(other.targetFatsG, targetFatsG) ||
                other.targetFatsG == targetFatsG) &&
            (identical(other.weightLossStartDate, weightLossStartDate) ||
                other.weightLossStartDate == weightLossStartDate) &&
            (identical(other.initialWeightKg, initialWeightKg) ||
                other.initialWeightKg == initialWeightKg) &&
            (identical(other.weeklyWeightLossTarget, weeklyWeightLossTarget) ||
                other.weeklyWeightLossTarget == weeklyWeightLossTarget) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        uid,
        fullName,
        email,
        dateOfBirth,
        gender,
        heightCm,
        currentWeightKg,
        targetWeightKg,
        goal,
        activityLevel,
        bmrCalories,
        tdeeCalories,
        targetCalories,
        targetProteinG,
        targetCarbsG,
        targetFatsG,
        weightLossStartDate,
        initialWeightKg,
        weeklyWeightLossTarget,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of UserProfileFreezed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileFreezedImplCopyWith<_$UserProfileFreezedImpl> get copyWith =>
      __$$UserProfileFreezedImplCopyWithImpl<_$UserProfileFreezedImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileFreezedImplToJson(
      this,
    );
  }
}

abstract class _UserProfileFreezed implements UserProfileFreezed {
  const factory _UserProfileFreezed(
      {final int? id,
      final String? uid,
      final String? fullName,
      final String? email,
      final DateTime? dateOfBirth,
      final String gender,
      required final double heightCm,
      required final double currentWeightKg,
      final double? targetWeightKg,
      final String goal,
      final double activityLevel,
      final int? bmrCalories,
      final int? tdeeCalories,
      final int? targetCalories,
      final double? targetProteinG,
      final double? targetCarbsG,
      final double? targetFatsG,
      final DateTime? weightLossStartDate,
      final double? initialWeightKg,
      final double weeklyWeightLossTarget,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$UserProfileFreezedImpl;

  factory _UserProfileFreezed.fromJson(Map<String, dynamic> json) =
      _$UserProfileFreezedImpl.fromJson;

  /// Database ID for the profile
  @override
  int? get id;

  /// User authentication ID
  @override
  String? get uid; // Basic Profile Information
  /// User's full name
  @override
  String? get fullName;

  /// User's email address
  @override
  String? get email;

  /// User's date of birth
  @override
  DateTime?
      get dateOfBirth; // Physical Characteristics (required for BMR calculations)
  /// Biological sex ('male' or 'female')
  @override
  String get gender;

  /// Height in centimeters
  @override
  double get heightCm;

  /// Current weight in kilograms
  @override
  double get currentWeightKg;

  /// Target weight in kilograms (optional)
  @override
  double? get targetWeightKg; // Goals and Activity
  /// Primary fitness goal
  @override
  String get goal; // 'weight_loss', 'weight_gain', 'maintaining', 'hypertrophy'
  /// Physical Activity Level (PAL) value
  @override
  double get activityLevel; // PAL value (1.2-2.4)
// Calculated Values
  /// Basal Metabolic Rate in calories
  @override
  int? get bmrCalories;

  /// Total Daily Energy Expenditure in calories
  @override
  int? get tdeeCalories;

  /// Target daily calories for goal achievement
  @override
  int? get targetCalories;

  /// Target protein intake in grams
  @override
  double? get targetProteinG;

  /// Target carbohydrate intake in grams
  @override
  double? get targetCarbsG;

  /// Target fat intake in grams
  @override
  double? get targetFatsG; // Weight Loss Tracking
  /// Date when weight loss journey started
  @override
  DateTime? get weightLossStartDate;

  /// Initial weight when starting weight loss
  @override
  double? get initialWeightKg;

  /// Weekly weight loss target in kg/week
  @override
  double get weeklyWeightLossTarget; // Timestamps
  /// Profile creation timestamp
  @override
  DateTime? get createdAt;

  /// Profile last update timestamp
  @override
  DateTime? get updatedAt;

  /// Create a copy of UserProfileFreezed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileFreezedImplCopyWith<_$UserProfileFreezedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
