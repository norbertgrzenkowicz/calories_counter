// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MealFreezed _$MealFreezedFromJson(Map<String, dynamic> json) {
  return _MealFreezed.fromJson(json);
}

/// @nodoc
mixin _$MealFreezed {
  /// Unique identifier for the meal (from database)
  int? get id => throw _privateConstructorUsedError;

  /// Name of the meal
  String get name => throw _privateConstructorUsedError;

  /// User ID who created this meal
  String? get uid => throw _privateConstructorUsedError;

  /// Total calories in the meal
  int get calories => throw _privateConstructorUsedError;

  /// Protein content in grams
  double get proteins => throw _privateConstructorUsedError;

  /// Fat content in grams
  double get fats => throw _privateConstructorUsedError;

  /// Carbohydrate content in grams
  double get carbs => throw _privateConstructorUsedError;

  /// URL to the meal photo (if any)
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Date when the meal was consumed
  DateTime get date => throw _privateConstructorUsedError;

  /// Timestamp when the meal record was created
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MealFreezed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealFreezed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealFreezedCopyWith<MealFreezed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealFreezedCopyWith<$Res> {
  factory $MealFreezedCopyWith(
          MealFreezed value, $Res Function(MealFreezed) then) =
      _$MealFreezedCopyWithImpl<$Res, MealFreezed>;
  @useResult
  $Res call(
      {int? id,
      String name,
      String? uid,
      int calories,
      double proteins,
      double fats,
      double carbs,
      String? photoUrl,
      DateTime date,
      DateTime? createdAt});
}

/// @nodoc
class _$MealFreezedCopyWithImpl<$Res, $Val extends MealFreezed>
    implements $MealFreezedCopyWith<$Res> {
  _$MealFreezedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealFreezed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? uid = freezed,
    Object? calories = null,
    Object? proteins = null,
    Object? fats = null,
    Object? carbs = null,
    Object? photoUrl = freezed,
    Object? date = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteins: null == proteins
          ? _value.proteins
          : proteins // ignore: cast_nullable_to_non_nullable
              as double,
      fats: null == fats
          ? _value.fats
          : fats // ignore: cast_nullable_to_non_nullable
              as double,
      carbs: null == carbs
          ? _value.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as double,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MealFreezedImplCopyWith<$Res>
    implements $MealFreezedCopyWith<$Res> {
  factory _$$MealFreezedImplCopyWith(
          _$MealFreezedImpl value, $Res Function(_$MealFreezedImpl) then) =
      __$$MealFreezedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String name,
      String? uid,
      int calories,
      double proteins,
      double fats,
      double carbs,
      String? photoUrl,
      DateTime date,
      DateTime? createdAt});
}

/// @nodoc
class __$$MealFreezedImplCopyWithImpl<$Res>
    extends _$MealFreezedCopyWithImpl<$Res, _$MealFreezedImpl>
    implements _$$MealFreezedImplCopyWith<$Res> {
  __$$MealFreezedImplCopyWithImpl(
      _$MealFreezedImpl _value, $Res Function(_$MealFreezedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MealFreezed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? uid = freezed,
    Object? calories = null,
    Object? proteins = null,
    Object? fats = null,
    Object? carbs = null,
    Object? photoUrl = freezed,
    Object? date = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$MealFreezedImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteins: null == proteins
          ? _value.proteins
          : proteins // ignore: cast_nullable_to_non_nullable
              as double,
      fats: null == fats
          ? _value.fats
          : fats // ignore: cast_nullable_to_non_nullable
              as double,
      carbs: null == carbs
          ? _value.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as double,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MealFreezedImpl implements _MealFreezed {
  const _$MealFreezedImpl(
      {this.id,
      required this.name,
      this.uid,
      required this.calories,
      required this.proteins,
      required this.fats,
      required this.carbs,
      this.photoUrl,
      required this.date,
      this.createdAt});

  factory _$MealFreezedImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealFreezedImplFromJson(json);

  /// Unique identifier for the meal (from database)
  @override
  final int? id;

  /// Name of the meal
  @override
  final String name;

  /// User ID who created this meal
  @override
  final String? uid;

  /// Total calories in the meal
  @override
  final int calories;

  /// Protein content in grams
  @override
  final double proteins;

  /// Fat content in grams
  @override
  final double fats;

  /// Carbohydrate content in grams
  @override
  final double carbs;

  /// URL to the meal photo (if any)
  @override
  final String? photoUrl;

  /// Date when the meal was consumed
  @override
  final DateTime date;

  /// Timestamp when the meal record was created
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MealFreezed(id: $id, name: $name, uid: $uid, calories: $calories, proteins: $proteins, fats: $fats, carbs: $carbs, photoUrl: $photoUrl, date: $date, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealFreezedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteins, proteins) ||
                other.proteins == proteins) &&
            (identical(other.fats, fats) || other.fats == fats) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, uid, calories,
      proteins, fats, carbs, photoUrl, date, createdAt);

  /// Create a copy of MealFreezed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealFreezedImplCopyWith<_$MealFreezedImpl> get copyWith =>
      __$$MealFreezedImplCopyWithImpl<_$MealFreezedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealFreezedImplToJson(
      this,
    );
  }
}

abstract class _MealFreezed implements MealFreezed {
  const factory _MealFreezed(
      {final int? id,
      required final String name,
      final String? uid,
      required final int calories,
      required final double proteins,
      required final double fats,
      required final double carbs,
      final String? photoUrl,
      required final DateTime date,
      final DateTime? createdAt}) = _$MealFreezedImpl;

  factory _MealFreezed.fromJson(Map<String, dynamic> json) =
      _$MealFreezedImpl.fromJson;

  /// Unique identifier for the meal (from database)
  @override
  int? get id;

  /// Name of the meal
  @override
  String get name;

  /// User ID who created this meal
  @override
  String? get uid;

  /// Total calories in the meal
  @override
  int get calories;

  /// Protein content in grams
  @override
  double get proteins;

  /// Fat content in grams
  @override
  double get fats;

  /// Carbohydrate content in grams
  @override
  double get carbs;

  /// URL to the meal photo (if any)
  @override
  String? get photoUrl;

  /// Date when the meal was consumed
  @override
  DateTime get date;

  /// Timestamp when the meal record was created
  @override
  DateTime? get createdAt;

  /// Create a copy of MealFreezed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealFreezedImplCopyWith<_$MealFreezedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
