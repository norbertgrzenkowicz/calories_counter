// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Result<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(AppError error) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? success,
    TResult? Function(AppError error)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(AppError error)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<T> value) success,
    required TResult Function(Failure<T> value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<T> value)? success,
    TResult? Function(Failure<T> value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<T> value)? success,
    TResult Function(Failure<T> value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultCopyWith<T, $Res> {
  factory $ResultCopyWith(Result<T> value, $Res Function(Result<T>) then) =
      _$ResultCopyWithImpl<T, $Res, Result<T>>;
}

/// @nodoc
class _$ResultCopyWithImpl<T, $Res, $Val extends Result<T>>
    implements $ResultCopyWith<T, $Res> {
  _$ResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<T, $Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl<T> value, $Res Function(_$SuccessImpl<T>) then) =
      __$$SuccessImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T data});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<T, $Res>
    extends _$ResultCopyWithImpl<T, $Res, _$SuccessImpl<T>>
    implements _$$SuccessImplCopyWith<T, $Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl<T> _value, $Res Function(_$SuccessImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_$SuccessImpl<T>(
      freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$SuccessImpl<T> implements Success<T> {
  const _$SuccessImpl(this.data);

  @override
  final T data;

  @override
  String toString() {
    return 'Result<$T>.success(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<T, _$SuccessImpl<T>> get copyWith =>
      __$$SuccessImplCopyWithImpl<T, _$SuccessImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(AppError error) failure,
  }) {
    return success(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? success,
    TResult? Function(AppError error)? failure,
  }) {
    return success?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(AppError error)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<T> value) success,
    required TResult Function(Failure<T> value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<T> value)? success,
    TResult? Function(Failure<T> value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<T> value)? success,
    TResult Function(Failure<T> value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class Success<T> implements Result<T> {
  const factory Success(final T data) = _$SuccessImpl<T>;

  T get data;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<T, _$SuccessImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailureImplCopyWith<T, $Res> {
  factory _$$FailureImplCopyWith(
          _$FailureImpl<T> value, $Res Function(_$FailureImpl<T>) then) =
      __$$FailureImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({AppError error});

  $AppErrorCopyWith<$Res> get error;
}

/// @nodoc
class __$$FailureImplCopyWithImpl<T, $Res>
    extends _$ResultCopyWithImpl<T, $Res, _$FailureImpl<T>>
    implements _$$FailureImplCopyWith<T, $Res> {
  __$$FailureImplCopyWithImpl(
      _$FailureImpl<T> _value, $Res Function(_$FailureImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$FailureImpl<T>(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppError,
    ));
  }

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppErrorCopyWith<$Res> get error {
    return $AppErrorCopyWith<$Res>(_value.error, (value) {
      return _then(_value.copyWith(error: value));
    });
  }
}

/// @nodoc

class _$FailureImpl<T> implements Failure<T> {
  const _$FailureImpl(this.error);

  @override
  final AppError error;

  @override
  String toString() {
    return 'Result<$T>.failure(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailureImpl<T> &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FailureImplCopyWith<T, _$FailureImpl<T>> get copyWith =>
      __$$FailureImplCopyWithImpl<T, _$FailureImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(AppError error) failure,
  }) {
    return failure(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? success,
    TResult? Function(AppError error)? failure,
  }) {
    return failure?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(AppError error)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<T> value) success,
    required TResult Function(Failure<T> value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<T> value)? success,
    TResult? Function(Failure<T> value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<T> value)? success,
    TResult Function(Failure<T> value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class Failure<T> implements Result<T> {
  const factory Failure(final AppError error) = _$FailureImpl<T>;

  AppError get error;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FailureImplCopyWith<T, _$FailureImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AppError {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message, Map<String, String>? fieldErrors)
        validation,
    required TResult Function(String message) notFound,
    required TResult Function(String message) conflict,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message, Object? exception) unknown,
    required TResult Function(String message) staleData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? conflict,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message, Object? exception)? unknown,
    TResult? Function(String message)? staleData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult Function(String message)? notFound,
    TResult Function(String message)? conflict,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message, Object? exception)? unknown,
    TResult Function(String message)? staleData,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(ValidationError value) validation,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ConflictError value) conflict,
    required TResult Function(ServerError value) server,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(StaleDataError value) staleData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ConflictError value)? conflict,
    TResult? Function(ServerError value)? server,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(StaleDataError value)? staleData,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(ValidationError value)? validation,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ConflictError value)? conflict,
    TResult Function(ServerError value)? server,
    TResult Function(UnknownError value)? unknown,
    TResult Function(StaleDataError value)? staleData,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppErrorCopyWith<AppError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppErrorCopyWith<$Res> {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) then) =
      _$AppErrorCopyWithImpl<$Res, AppError>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AppErrorCopyWithImpl<$Res, $Val extends AppError>
    implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$NetworkErrorImplCopyWith(
          _$NetworkErrorImpl value, $Res Function(_$NetworkErrorImpl) then) =
      __$$NetworkErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode});
}

/// @nodoc
class __$$NetworkErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$NetworkErrorImpl>
    implements _$$NetworkErrorImplCopyWith<$Res> {
  __$$NetworkErrorImplCopyWithImpl(
      _$NetworkErrorImpl _value, $Res Function(_$NetworkErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
  }) {
    return _then(_$NetworkErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$NetworkErrorImpl implements NetworkError {
  const _$NetworkErrorImpl(this.message, {this.statusCode});

  @override
  final String message;
  @override
  final int? statusCode;

  @override
  String toString() {
    return 'AppError.network(message: $message, statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      __$$NetworkErrorImplCopyWithImpl<_$NetworkErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message, Map<String, String>? fieldErrors)
        validation,
    required TResult Function(String message) notFound,
    required TResult Function(String message) conflict,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message, Object? exception) unknown,
    required TResult Function(String message) staleData,
  }) {
    return network(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? conflict,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message, Object? exception)? unknown,
    TResult? Function(String message)? staleData,
  }) {
    return network?.call(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult Function(String message)? notFound,
    TResult Function(String message)? conflict,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message, Object? exception)? unknown,
    TResult Function(String message)? staleData,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, statusCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(ValidationError value) validation,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ConflictError value) conflict,
    required TResult Function(ServerError value) server,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(StaleDataError value) staleData,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ConflictError value)? conflict,
    TResult? Function(ServerError value)? server,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(StaleDataError value)? staleData,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(ValidationError value)? validation,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ConflictError value)? conflict,
    TResult Function(ServerError value)? server,
    TResult Function(UnknownError value)? unknown,
    TResult Function(StaleDataError value)? staleData,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkError implements AppError {
  const factory NetworkError(final String message, {final int? statusCode}) =
      _$NetworkErrorImpl;

  @override
  String get message;
  int? get statusCode;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthenticationErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$AuthenticationErrorImplCopyWith(_$AuthenticationErrorImpl value,
          $Res Function(_$AuthenticationErrorImpl) then) =
      __$$AuthenticationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$AuthenticationErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$AuthenticationErrorImpl>
    implements _$$AuthenticationErrorImplCopyWith<$Res> {
  __$$AuthenticationErrorImplCopyWithImpl(_$AuthenticationErrorImpl _value,
      $Res Function(_$AuthenticationErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$AuthenticationErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AuthenticationErrorImpl implements AuthenticationError {
  const _$AuthenticationErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AppError.authentication(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticationErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticationErrorImplCopyWith<_$AuthenticationErrorImpl> get copyWith =>
      __$$AuthenticationErrorImplCopyWithImpl<_$AuthenticationErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message, Map<String, String>? fieldErrors)
        validation,
    required TResult Function(String message) notFound,
    required TResult Function(String message) conflict,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message, Object? exception) unknown,
    required TResult Function(String message) staleData,
  }) {
    return authentication(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? conflict,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message, Object? exception)? unknown,
    TResult? Function(String message)? staleData,
  }) {
    return authentication?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult Function(String message)? notFound,
    TResult Function(String message)? conflict,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message, Object? exception)? unknown,
    TResult Function(String message)? staleData,
    required TResult orElse(),
  }) {
    if (authentication != null) {
      return authentication(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(ValidationError value) validation,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ConflictError value) conflict,
    required TResult Function(ServerError value) server,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(StaleDataError value) staleData,
  }) {
    return authentication(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ConflictError value)? conflict,
    TResult? Function(ServerError value)? server,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(StaleDataError value)? staleData,
  }) {
    return authentication?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(ValidationError value)? validation,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ConflictError value)? conflict,
    TResult Function(ServerError value)? server,
    TResult Function(UnknownError value)? unknown,
    TResult Function(StaleDataError value)? staleData,
    required TResult orElse(),
  }) {
    if (authentication != null) {
      return authentication(this);
    }
    return orElse();
  }
}

abstract class AuthenticationError implements AppError {
  const factory AuthenticationError(final String message) =
      _$AuthenticationErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthenticationErrorImplCopyWith<_$AuthenticationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(_$ValidationErrorImpl value,
          $Res Function(_$ValidationErrorImpl) then) =
      __$$ValidationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Map<String, String>? fieldErrors});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
      _$ValidationErrorImpl _value, $Res Function(_$ValidationErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? fieldErrors = freezed,
  }) {
    return _then(_$ValidationErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      fieldErrors: freezed == fieldErrors
          ? _value._fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc

class _$ValidationErrorImpl implements ValidationError {
  const _$ValidationErrorImpl(this.message,
      {final Map<String, String>? fieldErrors})
      : _fieldErrors = fieldErrors;

  @override
  final String message;
  final Map<String, String>? _fieldErrors;
  @override
  Map<String, String>? get fieldErrors {
    final value = _fieldErrors;
    if (value == null) return null;
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppError.validation(message: $message, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._fieldErrors, _fieldErrors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, const DeepCollectionEquality().hash(_fieldErrors));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message, Map<String, String>? fieldErrors)
        validation,
    required TResult Function(String message) notFound,
    required TResult Function(String message) conflict,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message, Object? exception) unknown,
    required TResult Function(String message) staleData,
  }) {
    return validation(message, fieldErrors);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? conflict,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message, Object? exception)? unknown,
    TResult? Function(String message)? staleData,
  }) {
    return validation?.call(message, fieldErrors);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult Function(String message)? notFound,
    TResult Function(String message)? conflict,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message, Object? exception)? unknown,
    TResult Function(String message)? staleData,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, fieldErrors);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(ValidationError value) validation,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ConflictError value) conflict,
    required TResult Function(ServerError value) server,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(StaleDataError value) staleData,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ConflictError value)? conflict,
    TResult? Function(ServerError value)? server,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(StaleDataError value)? staleData,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(ValidationError value)? validation,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ConflictError value)? conflict,
    TResult Function(ServerError value)? server,
    TResult Function(UnknownError value)? unknown,
    TResult Function(StaleDataError value)? staleData,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationError implements AppError {
  const factory ValidationError(final String message,
      {final Map<String, String>? fieldErrors}) = _$ValidationErrorImpl;

  @override
  String get message;
  Map<String, String>? get fieldErrors;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$NotFoundErrorImplCopyWith(
          _$NotFoundErrorImpl value, $Res Function(_$NotFoundErrorImpl) then) =
      __$$NotFoundErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NotFoundErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$NotFoundErrorImpl>
    implements _$$NotFoundErrorImplCopyWith<$Res> {
  __$$NotFoundErrorImplCopyWithImpl(
      _$NotFoundErrorImpl _value, $Res Function(_$NotFoundErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$NotFoundErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$NotFoundErrorImpl implements NotFoundError {
  const _$NotFoundErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AppError.notFound(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      __$$NotFoundErrorImplCopyWithImpl<_$NotFoundErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message, Map<String, String>? fieldErrors)
        validation,
    required TResult Function(String message) notFound,
    required TResult Function(String message) conflict,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message, Object? exception) unknown,
    required TResult Function(String message) staleData,
  }) {
    return notFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? conflict,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message, Object? exception)? unknown,
    TResult? Function(String message)? staleData,
  }) {
    return notFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult Function(String message)? notFound,
    TResult Function(String message)? conflict,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message, Object? exception)? unknown,
    TResult Function(String message)? staleData,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(ValidationError value) validation,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ConflictError value) conflict,
    required TResult Function(ServerError value) server,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(StaleDataError value) staleData,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ConflictError value)? conflict,
    TResult? Function(ServerError value)? server,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(StaleDataError value)? staleData,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(ValidationError value)? validation,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ConflictError value)? conflict,
    TResult Function(ServerError value)? server,
    TResult Function(UnknownError value)? unknown,
    TResult Function(StaleDataError value)? staleData,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundError implements AppError {
  const factory NotFoundError(final String message) = _$NotFoundErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConflictErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$ConflictErrorImplCopyWith(
          _$ConflictErrorImpl value, $Res Function(_$ConflictErrorImpl) then) =
      __$$ConflictErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ConflictErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$ConflictErrorImpl>
    implements _$$ConflictErrorImplCopyWith<$Res> {
  __$$ConflictErrorImplCopyWithImpl(
      _$ConflictErrorImpl _value, $Res Function(_$ConflictErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ConflictErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ConflictErrorImpl implements ConflictError {
  const _$ConflictErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AppError.conflict(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConflictErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConflictErrorImplCopyWith<_$ConflictErrorImpl> get copyWith =>
      __$$ConflictErrorImplCopyWithImpl<_$ConflictErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message, Map<String, String>? fieldErrors)
        validation,
    required TResult Function(String message) notFound,
    required TResult Function(String message) conflict,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message, Object? exception) unknown,
    required TResult Function(String message) staleData,
  }) {
    return conflict(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? conflict,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message, Object? exception)? unknown,
    TResult? Function(String message)? staleData,
  }) {
    return conflict?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult Function(String message)? notFound,
    TResult Function(String message)? conflict,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message, Object? exception)? unknown,
    TResult Function(String message)? staleData,
    required TResult orElse(),
  }) {
    if (conflict != null) {
      return conflict(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(ValidationError value) validation,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ConflictError value) conflict,
    required TResult Function(ServerError value) server,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(StaleDataError value) staleData,
  }) {
    return conflict(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ConflictError value)? conflict,
    TResult? Function(ServerError value)? server,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(StaleDataError value)? staleData,
  }) {
    return conflict?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(ValidationError value)? validation,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ConflictError value)? conflict,
    TResult Function(ServerError value)? server,
    TResult Function(UnknownError value)? unknown,
    TResult Function(StaleDataError value)? staleData,
    required TResult orElse(),
  }) {
    if (conflict != null) {
      return conflict(this);
    }
    return orElse();
  }
}

abstract class ConflictError implements AppError {
  const factory ConflictError(final String message) = _$ConflictErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConflictErrorImplCopyWith<_$ConflictErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$ServerErrorImplCopyWith(
          _$ServerErrorImpl value, $Res Function(_$ServerErrorImpl) then) =
      __$$ServerErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode});
}

/// @nodoc
class __$$ServerErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$ServerErrorImpl>
    implements _$$ServerErrorImplCopyWith<$Res> {
  __$$ServerErrorImplCopyWithImpl(
      _$ServerErrorImpl _value, $Res Function(_$ServerErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
  }) {
    return _then(_$ServerErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$ServerErrorImpl implements ServerError {
  const _$ServerErrorImpl(this.message, {this.statusCode});

  @override
  final String message;
  @override
  final int? statusCode;

  @override
  String toString() {
    return 'AppError.server(message: $message, statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerErrorImplCopyWith<_$ServerErrorImpl> get copyWith =>
      __$$ServerErrorImplCopyWithImpl<_$ServerErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message, Map<String, String>? fieldErrors)
        validation,
    required TResult Function(String message) notFound,
    required TResult Function(String message) conflict,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message, Object? exception) unknown,
    required TResult Function(String message) staleData,
  }) {
    return server(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? conflict,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message, Object? exception)? unknown,
    TResult? Function(String message)? staleData,
  }) {
    return server?.call(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult Function(String message)? notFound,
    TResult Function(String message)? conflict,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message, Object? exception)? unknown,
    TResult Function(String message)? staleData,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(message, statusCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(ValidationError value) validation,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ConflictError value) conflict,
    required TResult Function(ServerError value) server,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(StaleDataError value) staleData,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ConflictError value)? conflict,
    TResult? Function(ServerError value)? server,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(StaleDataError value)? staleData,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(ValidationError value)? validation,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ConflictError value)? conflict,
    TResult Function(ServerError value)? server,
    TResult Function(UnknownError value)? unknown,
    TResult Function(StaleDataError value)? staleData,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerError implements AppError {
  const factory ServerError(final String message, {final int? statusCode}) =
      _$ServerErrorImpl;

  @override
  String get message;
  int? get statusCode;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerErrorImplCopyWith<_$ServerErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$UnknownErrorImplCopyWith(
          _$UnknownErrorImpl value, $Res Function(_$UnknownErrorImpl) then) =
      __$$UnknownErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? exception});
}

/// @nodoc
class __$$UnknownErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$UnknownErrorImpl>
    implements _$$UnknownErrorImplCopyWith<$Res> {
  __$$UnknownErrorImplCopyWithImpl(
      _$UnknownErrorImpl _value, $Res Function(_$UnknownErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? exception = freezed,
  }) {
    return _then(_$UnknownErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      exception: freezed == exception ? _value.exception : exception,
    ));
  }
}

/// @nodoc

class _$UnknownErrorImpl implements UnknownError {
  const _$UnknownErrorImpl(this.message, {this.exception});

  @override
  final String message;
  @override
  final Object? exception;

  @override
  String toString() {
    return 'AppError.unknown(message: $message, exception: $exception)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.exception, exception));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, const DeepCollectionEquality().hash(exception));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      __$$UnknownErrorImplCopyWithImpl<_$UnknownErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message, Map<String, String>? fieldErrors)
        validation,
    required TResult Function(String message) notFound,
    required TResult Function(String message) conflict,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message, Object? exception) unknown,
    required TResult Function(String message) staleData,
  }) {
    return unknown(message, exception);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? conflict,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message, Object? exception)? unknown,
    TResult? Function(String message)? staleData,
  }) {
    return unknown?.call(message, exception);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult Function(String message)? notFound,
    TResult Function(String message)? conflict,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message, Object? exception)? unknown,
    TResult Function(String message)? staleData,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, exception);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(ValidationError value) validation,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ConflictError value) conflict,
    required TResult Function(ServerError value) server,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(StaleDataError value) staleData,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ConflictError value)? conflict,
    TResult? Function(ServerError value)? server,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(StaleDataError value)? staleData,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(ValidationError value)? validation,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ConflictError value)? conflict,
    TResult Function(ServerError value)? server,
    TResult Function(UnknownError value)? unknown,
    TResult Function(StaleDataError value)? staleData,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownError implements AppError {
  const factory UnknownError(final String message, {final Object? exception}) =
      _$UnknownErrorImpl;

  @override
  String get message;
  Object? get exception;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StaleDataErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$StaleDataErrorImplCopyWith(_$StaleDataErrorImpl value,
          $Res Function(_$StaleDataErrorImpl) then) =
      __$$StaleDataErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$StaleDataErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$StaleDataErrorImpl>
    implements _$$StaleDataErrorImplCopyWith<$Res> {
  __$$StaleDataErrorImplCopyWithImpl(
      _$StaleDataErrorImpl _value, $Res Function(_$StaleDataErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$StaleDataErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$StaleDataErrorImpl implements StaleDataError {
  const _$StaleDataErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AppError.staleData(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StaleDataErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StaleDataErrorImplCopyWith<_$StaleDataErrorImpl> get copyWith =>
      __$$StaleDataErrorImplCopyWithImpl<_$StaleDataErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message, Map<String, String>? fieldErrors)
        validation,
    required TResult Function(String message) notFound,
    required TResult Function(String message) conflict,
    required TResult Function(String message, int? statusCode) server,
    required TResult Function(String message, Object? exception) unknown,
    required TResult Function(String message) staleData,
  }) {
    return staleData(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? conflict,
    TResult? Function(String message, int? statusCode)? server,
    TResult? Function(String message, Object? exception)? unknown,
    TResult? Function(String message)? staleData,
  }) {
    return staleData?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message, Map<String, String>? fieldErrors)?
        validation,
    TResult Function(String message)? notFound,
    TResult Function(String message)? conflict,
    TResult Function(String message, int? statusCode)? server,
    TResult Function(String message, Object? exception)? unknown,
    TResult Function(String message)? staleData,
    required TResult orElse(),
  }) {
    if (staleData != null) {
      return staleData(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(ValidationError value) validation,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ConflictError value) conflict,
    required TResult Function(ServerError value) server,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(StaleDataError value) staleData,
  }) {
    return staleData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ConflictError value)? conflict,
    TResult? Function(ServerError value)? server,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(StaleDataError value)? staleData,
  }) {
    return staleData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(ValidationError value)? validation,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ConflictError value)? conflict,
    TResult Function(ServerError value)? server,
    TResult Function(UnknownError value)? unknown,
    TResult Function(StaleDataError value)? staleData,
    required TResult orElse(),
  }) {
    if (staleData != null) {
      return staleData(this);
    }
    return orElse();
  }
}

abstract class StaleDataError implements AppError {
  const factory StaleDataError(final String message) = _$StaleDataErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StaleDataErrorImplCopyWith<_$StaleDataErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
