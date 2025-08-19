// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_history_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeightHistoryFreezed _$WeightHistoryFreezedFromJson(Map<String, dynamic> json) {
  return _WeightHistoryFreezed.fromJson(json);
}

/// @nodoc
mixin _$WeightHistoryFreezed {
  /// Database ID for the weight entry
  int? get id => throw _privateConstructorUsedError;

  /// User authentication ID
  String? get uid => throw _privateConstructorUsedError; // Weight Data
  /// Weight measurement in kilograms
  double get weightKg => throw _privateConstructorUsedError;

  /// Date when weight was recorded
  DateTime get recordedDate =>
      throw _privateConstructorUsedError; // Context Information
  /// Time of day when measured
  String get measurementTime =>
      throw _privateConstructorUsedError; // 'morning', 'afternoon', 'evening'
  /// Optional notes about the measurement
  String? get notes => throw _privateConstructorUsedError; // Goal Tracking
  /// User's goal at the time of measurement
  String? get goalAtTime => throw _privateConstructorUsedError;

  /// Number of days since goal started
  int get daysSinceGoalStart =>
      throw _privateConstructorUsedError; // Calculated Fields
  /// Change from previous measurement
  double? get weightChangeKg => throw _privateConstructorUsedError;

  /// Weekly average weight
  double? get weeklyAverageKg => throw _privateConstructorUsedError;

  /// Monthly average weight
  double? get monthlyAverageKg =>
      throw _privateConstructorUsedError; // Weight Loss Phase Tracking
  /// Whether this is in the initial weight loss phase
  bool get isInitialPhase => throw _privateConstructorUsedError;

  /// Current phase of weight loss journey
  String get phase =>
      throw _privateConstructorUsedError; // 'initial' or 'steady_state'
// Timestamps
  /// Entry creation timestamp
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Entry last update timestamp
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WeightHistoryFreezed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeightHistoryFreezed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeightHistoryFreezedCopyWith<WeightHistoryFreezed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightHistoryFreezedCopyWith<$Res> {
  factory $WeightHistoryFreezedCopyWith(WeightHistoryFreezed value,
          $Res Function(WeightHistoryFreezed) then) =
      _$WeightHistoryFreezedCopyWithImpl<$Res, WeightHistoryFreezed>;
  @useResult
  $Res call(
      {int? id,
      String? uid,
      double weightKg,
      DateTime recordedDate,
      String measurementTime,
      String? notes,
      String? goalAtTime,
      int daysSinceGoalStart,
      double? weightChangeKg,
      double? weeklyAverageKg,
      double? monthlyAverageKg,
      bool isInitialPhase,
      String phase,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$WeightHistoryFreezedCopyWithImpl<$Res,
        $Val extends WeightHistoryFreezed>
    implements $WeightHistoryFreezedCopyWith<$Res> {
  _$WeightHistoryFreezedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeightHistoryFreezed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? uid = freezed,
    Object? weightKg = null,
    Object? recordedDate = null,
    Object? measurementTime = null,
    Object? notes = freezed,
    Object? goalAtTime = freezed,
    Object? daysSinceGoalStart = null,
    Object? weightChangeKg = freezed,
    Object? weeklyAverageKg = freezed,
    Object? monthlyAverageKg = freezed,
    Object? isInitialPhase = null,
    Object? phase = null,
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
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      recordedDate: null == recordedDate
          ? _value.recordedDate
          : recordedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      measurementTime: null == measurementTime
          ? _value.measurementTime
          : measurementTime // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      goalAtTime: freezed == goalAtTime
          ? _value.goalAtTime
          : goalAtTime // ignore: cast_nullable_to_non_nullable
              as String?,
      daysSinceGoalStart: null == daysSinceGoalStart
          ? _value.daysSinceGoalStart
          : daysSinceGoalStart // ignore: cast_nullable_to_non_nullable
              as int,
      weightChangeKg: freezed == weightChangeKg
          ? _value.weightChangeKg
          : weightChangeKg // ignore: cast_nullable_to_non_nullable
              as double?,
      weeklyAverageKg: freezed == weeklyAverageKg
          ? _value.weeklyAverageKg
          : weeklyAverageKg // ignore: cast_nullable_to_non_nullable
              as double?,
      monthlyAverageKg: freezed == monthlyAverageKg
          ? _value.monthlyAverageKg
          : monthlyAverageKg // ignore: cast_nullable_to_non_nullable
              as double?,
      isInitialPhase: null == isInitialPhase
          ? _value.isInitialPhase
          : isInitialPhase // ignore: cast_nullable_to_non_nullable
              as bool,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$WeightHistoryFreezedImplCopyWith<$Res>
    implements $WeightHistoryFreezedCopyWith<$Res> {
  factory _$$WeightHistoryFreezedImplCopyWith(_$WeightHistoryFreezedImpl value,
          $Res Function(_$WeightHistoryFreezedImpl) then) =
      __$$WeightHistoryFreezedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? uid,
      double weightKg,
      DateTime recordedDate,
      String measurementTime,
      String? notes,
      String? goalAtTime,
      int daysSinceGoalStart,
      double? weightChangeKg,
      double? weeklyAverageKg,
      double? monthlyAverageKg,
      bool isInitialPhase,
      String phase,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$WeightHistoryFreezedImplCopyWithImpl<$Res>
    extends _$WeightHistoryFreezedCopyWithImpl<$Res, _$WeightHistoryFreezedImpl>
    implements _$$WeightHistoryFreezedImplCopyWith<$Res> {
  __$$WeightHistoryFreezedImplCopyWithImpl(_$WeightHistoryFreezedImpl _value,
      $Res Function(_$WeightHistoryFreezedImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeightHistoryFreezed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? uid = freezed,
    Object? weightKg = null,
    Object? recordedDate = null,
    Object? measurementTime = null,
    Object? notes = freezed,
    Object? goalAtTime = freezed,
    Object? daysSinceGoalStart = null,
    Object? weightChangeKg = freezed,
    Object? weeklyAverageKg = freezed,
    Object? monthlyAverageKg = freezed,
    Object? isInitialPhase = null,
    Object? phase = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$WeightHistoryFreezedImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      recordedDate: null == recordedDate
          ? _value.recordedDate
          : recordedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      measurementTime: null == measurementTime
          ? _value.measurementTime
          : measurementTime // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      goalAtTime: freezed == goalAtTime
          ? _value.goalAtTime
          : goalAtTime // ignore: cast_nullable_to_non_nullable
              as String?,
      daysSinceGoalStart: null == daysSinceGoalStart
          ? _value.daysSinceGoalStart
          : daysSinceGoalStart // ignore: cast_nullable_to_non_nullable
              as int,
      weightChangeKg: freezed == weightChangeKg
          ? _value.weightChangeKg
          : weightChangeKg // ignore: cast_nullable_to_non_nullable
              as double?,
      weeklyAverageKg: freezed == weeklyAverageKg
          ? _value.weeklyAverageKg
          : weeklyAverageKg // ignore: cast_nullable_to_non_nullable
              as double?,
      monthlyAverageKg: freezed == monthlyAverageKg
          ? _value.monthlyAverageKg
          : monthlyAverageKg // ignore: cast_nullable_to_non_nullable
              as double?,
      isInitialPhase: null == isInitialPhase
          ? _value.isInitialPhase
          : isInitialPhase // ignore: cast_nullable_to_non_nullable
              as bool,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$WeightHistoryFreezedImpl implements _WeightHistoryFreezed {
  const _$WeightHistoryFreezedImpl(
      {this.id,
      this.uid,
      required this.weightKg,
      required this.recordedDate,
      this.measurementTime = 'morning',
      this.notes,
      this.goalAtTime,
      this.daysSinceGoalStart = 0,
      this.weightChangeKg,
      this.weeklyAverageKg,
      this.monthlyAverageKg,
      this.isInitialPhase = false,
      this.phase = 'steady_state',
      this.createdAt,
      this.updatedAt});

  factory _$WeightHistoryFreezedImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightHistoryFreezedImplFromJson(json);

  /// Database ID for the weight entry
  @override
  final int? id;

  /// User authentication ID
  @override
  final String? uid;
// Weight Data
  /// Weight measurement in kilograms
  @override
  final double weightKg;

  /// Date when weight was recorded
  @override
  final DateTime recordedDate;
// Context Information
  /// Time of day when measured
  @override
  @JsonKey()
  final String measurementTime;
// 'morning', 'afternoon', 'evening'
  /// Optional notes about the measurement
  @override
  final String? notes;
// Goal Tracking
  /// User's goal at the time of measurement
  @override
  final String? goalAtTime;

  /// Number of days since goal started
  @override
  @JsonKey()
  final int daysSinceGoalStart;
// Calculated Fields
  /// Change from previous measurement
  @override
  final double? weightChangeKg;

  /// Weekly average weight
  @override
  final double? weeklyAverageKg;

  /// Monthly average weight
  @override
  final double? monthlyAverageKg;
// Weight Loss Phase Tracking
  /// Whether this is in the initial weight loss phase
  @override
  @JsonKey()
  final bool isInitialPhase;

  /// Current phase of weight loss journey
  @override
  @JsonKey()
  final String phase;
// 'initial' or 'steady_state'
// Timestamps
  /// Entry creation timestamp
  @override
  final DateTime? createdAt;

  /// Entry last update timestamp
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'WeightHistoryFreezed(id: $id, uid: $uid, weightKg: $weightKg, recordedDate: $recordedDate, measurementTime: $measurementTime, notes: $notes, goalAtTime: $goalAtTime, daysSinceGoalStart: $daysSinceGoalStart, weightChangeKg: $weightChangeKg, weeklyAverageKg: $weeklyAverageKg, monthlyAverageKg: $monthlyAverageKg, isInitialPhase: $isInitialPhase, phase: $phase, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightHistoryFreezedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.recordedDate, recordedDate) ||
                other.recordedDate == recordedDate) &&
            (identical(other.measurementTime, measurementTime) ||
                other.measurementTime == measurementTime) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.goalAtTime, goalAtTime) ||
                other.goalAtTime == goalAtTime) &&
            (identical(other.daysSinceGoalStart, daysSinceGoalStart) ||
                other.daysSinceGoalStart == daysSinceGoalStart) &&
            (identical(other.weightChangeKg, weightChangeKg) ||
                other.weightChangeKg == weightChangeKg) &&
            (identical(other.weeklyAverageKg, weeklyAverageKg) ||
                other.weeklyAverageKg == weeklyAverageKg) &&
            (identical(other.monthlyAverageKg, monthlyAverageKg) ||
                other.monthlyAverageKg == monthlyAverageKg) &&
            (identical(other.isInitialPhase, isInitialPhase) ||
                other.isInitialPhase == isInitialPhase) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      uid,
      weightKg,
      recordedDate,
      measurementTime,
      notes,
      goalAtTime,
      daysSinceGoalStart,
      weightChangeKg,
      weeklyAverageKg,
      monthlyAverageKg,
      isInitialPhase,
      phase,
      createdAt,
      updatedAt);

  /// Create a copy of WeightHistoryFreezed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightHistoryFreezedImplCopyWith<_$WeightHistoryFreezedImpl>
      get copyWith =>
          __$$WeightHistoryFreezedImplCopyWithImpl<_$WeightHistoryFreezedImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightHistoryFreezedImplToJson(
      this,
    );
  }
}

abstract class _WeightHistoryFreezed implements WeightHistoryFreezed {
  const factory _WeightHistoryFreezed(
      {final int? id,
      final String? uid,
      required final double weightKg,
      required final DateTime recordedDate,
      final String measurementTime,
      final String? notes,
      final String? goalAtTime,
      final int daysSinceGoalStart,
      final double? weightChangeKg,
      final double? weeklyAverageKg,
      final double? monthlyAverageKg,
      final bool isInitialPhase,
      final String phase,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$WeightHistoryFreezedImpl;

  factory _WeightHistoryFreezed.fromJson(Map<String, dynamic> json) =
      _$WeightHistoryFreezedImpl.fromJson;

  /// Database ID for the weight entry
  @override
  int? get id;

  /// User authentication ID
  @override
  String? get uid; // Weight Data
  /// Weight measurement in kilograms
  @override
  double get weightKg;

  /// Date when weight was recorded
  @override
  DateTime get recordedDate; // Context Information
  /// Time of day when measured
  @override
  String get measurementTime; // 'morning', 'afternoon', 'evening'
  /// Optional notes about the measurement
  @override
  String? get notes; // Goal Tracking
  /// User's goal at the time of measurement
  @override
  String? get goalAtTime;

  /// Number of days since goal started
  @override
  int get daysSinceGoalStart; // Calculated Fields
  /// Change from previous measurement
  @override
  double? get weightChangeKg;

  /// Weekly average weight
  @override
  double? get weeklyAverageKg;

  /// Monthly average weight
  @override
  double? get monthlyAverageKg; // Weight Loss Phase Tracking
  /// Whether this is in the initial weight loss phase
  @override
  bool get isInitialPhase;

  /// Current phase of weight loss journey
  @override
  String get phase; // 'initial' or 'steady_state'
// Timestamps
  /// Entry creation timestamp
  @override
  DateTime? get createdAt;

  /// Entry last update timestamp
  @override
  DateTime? get updatedAt;

  /// Create a copy of WeightHistoryFreezed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeightHistoryFreezedImplCopyWith<_$WeightHistoryFreezedImpl>
      get copyWith => throw _privateConstructorUsedError;
}
