// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'async_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AsyncState<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T? previousData) loading,
    required TResult Function(T data) success,
    required TResult Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )
    error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(T? previousData)? loading,
    TResult? Function(T data)? success,
    TResult? Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )?
    error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T? previousData)? loading,
    TResult Function(T data)? success,
    TResult Function(String message, Object? exception, StackTrace? stackTrace)?
    error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncInitial<T> value) initial,
    required TResult Function(AsyncLoading<T> value) loading,
    required TResult Function(AsyncSuccess<T> value) success,
    required TResult Function(AsyncError<T> value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncInitial<T> value)? initial,
    TResult? Function(AsyncLoading<T> value)? loading,
    TResult? Function(AsyncSuccess<T> value)? success,
    TResult? Function(AsyncError<T> value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncInitial<T> value)? initial,
    TResult Function(AsyncLoading<T> value)? loading,
    TResult Function(AsyncSuccess<T> value)? success,
    TResult Function(AsyncError<T> value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AsyncStateCopyWith<T, $Res> {
  factory $AsyncStateCopyWith(
    AsyncState<T> value,
    $Res Function(AsyncState<T>) then,
  ) = _$AsyncStateCopyWithImpl<T, $Res, AsyncState<T>>;
}

/// @nodoc
class _$AsyncStateCopyWithImpl<T, $Res, $Val extends AsyncState<T>>
    implements $AsyncStateCopyWith<T, $Res> {
  _$AsyncStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AsyncInitialImplCopyWith<T, $Res> {
  factory _$$AsyncInitialImplCopyWith(
    _$AsyncInitialImpl<T> value,
    $Res Function(_$AsyncInitialImpl<T>) then,
  ) = __$$AsyncInitialImplCopyWithImpl<T, $Res>;
}

/// @nodoc
class __$$AsyncInitialImplCopyWithImpl<T, $Res>
    extends _$AsyncStateCopyWithImpl<T, $Res, _$AsyncInitialImpl<T>>
    implements _$$AsyncInitialImplCopyWith<T, $Res> {
  __$$AsyncInitialImplCopyWithImpl(
    _$AsyncInitialImpl<T> _value,
    $Res Function(_$AsyncInitialImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AsyncInitialImpl<T> extends AsyncInitial<T> {
  const _$AsyncInitialImpl() : super._();

  @override
  String toString() {
    return 'AsyncState<$T>.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AsyncInitialImpl<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T? previousData) loading,
    required TResult Function(T data) success,
    required TResult Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )
    error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(T? previousData)? loading,
    TResult? Function(T data)? success,
    TResult? Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )?
    error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T? previousData)? loading,
    TResult Function(T data)? success,
    TResult Function(String message, Object? exception, StackTrace? stackTrace)?
    error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncInitial<T> value) initial,
    required TResult Function(AsyncLoading<T> value) loading,
    required TResult Function(AsyncSuccess<T> value) success,
    required TResult Function(AsyncError<T> value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncInitial<T> value)? initial,
    TResult? Function(AsyncLoading<T> value)? loading,
    TResult? Function(AsyncSuccess<T> value)? success,
    TResult? Function(AsyncError<T> value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncInitial<T> value)? initial,
    TResult Function(AsyncLoading<T> value)? loading,
    TResult Function(AsyncSuccess<T> value)? success,
    TResult Function(AsyncError<T> value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class AsyncInitial<T> extends AsyncState<T> {
  const factory AsyncInitial() = _$AsyncInitialImpl<T>;
  const AsyncInitial._() : super._();
}

/// @nodoc
abstract class _$$AsyncLoadingImplCopyWith<T, $Res> {
  factory _$$AsyncLoadingImplCopyWith(
    _$AsyncLoadingImpl<T> value,
    $Res Function(_$AsyncLoadingImpl<T>) then,
  ) = __$$AsyncLoadingImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T? previousData});
}

/// @nodoc
class __$$AsyncLoadingImplCopyWithImpl<T, $Res>
    extends _$AsyncStateCopyWithImpl<T, $Res, _$AsyncLoadingImpl<T>>
    implements _$$AsyncLoadingImplCopyWith<T, $Res> {
  __$$AsyncLoadingImplCopyWithImpl(
    _$AsyncLoadingImpl<T> _value,
    $Res Function(_$AsyncLoadingImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? previousData = freezed}) {
    return _then(
      _$AsyncLoadingImpl<T>(
        previousData: freezed == previousData
            ? _value.previousData
            : previousData // ignore: cast_nullable_to_non_nullable
                  as T?,
      ),
    );
  }
}

/// @nodoc

class _$AsyncLoadingImpl<T> extends AsyncLoading<T> {
  const _$AsyncLoadingImpl({this.previousData}) : super._();

  @override
  final T? previousData;

  @override
  String toString() {
    return 'AsyncState<$T>.loading(previousData: $previousData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsyncLoadingImpl<T> &&
            const DeepCollectionEquality().equals(
              other.previousData,
              previousData,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(previousData),
  );

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AsyncLoadingImplCopyWith<T, _$AsyncLoadingImpl<T>> get copyWith =>
      __$$AsyncLoadingImplCopyWithImpl<T, _$AsyncLoadingImpl<T>>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T? previousData) loading,
    required TResult Function(T data) success,
    required TResult Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )
    error,
  }) {
    return loading(previousData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(T? previousData)? loading,
    TResult? Function(T data)? success,
    TResult? Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )?
    error,
  }) {
    return loading?.call(previousData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T? previousData)? loading,
    TResult Function(T data)? success,
    TResult Function(String message, Object? exception, StackTrace? stackTrace)?
    error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(previousData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncInitial<T> value) initial,
    required TResult Function(AsyncLoading<T> value) loading,
    required TResult Function(AsyncSuccess<T> value) success,
    required TResult Function(AsyncError<T> value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncInitial<T> value)? initial,
    TResult? Function(AsyncLoading<T> value)? loading,
    TResult? Function(AsyncSuccess<T> value)? success,
    TResult? Function(AsyncError<T> value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncInitial<T> value)? initial,
    TResult Function(AsyncLoading<T> value)? loading,
    TResult Function(AsyncSuccess<T> value)? success,
    TResult Function(AsyncError<T> value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class AsyncLoading<T> extends AsyncState<T> {
  const factory AsyncLoading({final T? previousData}) = _$AsyncLoadingImpl<T>;
  const AsyncLoading._() : super._();

  T? get previousData;

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AsyncLoadingImplCopyWith<T, _$AsyncLoadingImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AsyncSuccessImplCopyWith<T, $Res> {
  factory _$$AsyncSuccessImplCopyWith(
    _$AsyncSuccessImpl<T> value,
    $Res Function(_$AsyncSuccessImpl<T>) then,
  ) = __$$AsyncSuccessImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T data});
}

/// @nodoc
class __$$AsyncSuccessImplCopyWithImpl<T, $Res>
    extends _$AsyncStateCopyWithImpl<T, $Res, _$AsyncSuccessImpl<T>>
    implements _$$AsyncSuccessImplCopyWith<T, $Res> {
  __$$AsyncSuccessImplCopyWithImpl(
    _$AsyncSuccessImpl<T> _value,
    $Res Function(_$AsyncSuccessImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = freezed}) {
    return _then(
      _$AsyncSuccessImpl<T>(
        freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as T,
      ),
    );
  }
}

/// @nodoc

class _$AsyncSuccessImpl<T> extends AsyncSuccess<T> {
  const _$AsyncSuccessImpl(this.data) : super._();

  @override
  final T data;

  @override
  String toString() {
    return 'AsyncState<$T>.success(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsyncSuccessImpl<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AsyncSuccessImplCopyWith<T, _$AsyncSuccessImpl<T>> get copyWith =>
      __$$AsyncSuccessImplCopyWithImpl<T, _$AsyncSuccessImpl<T>>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T? previousData) loading,
    required TResult Function(T data) success,
    required TResult Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )
    error,
  }) {
    return success(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(T? previousData)? loading,
    TResult? Function(T data)? success,
    TResult? Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )?
    error,
  }) {
    return success?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T? previousData)? loading,
    TResult Function(T data)? success,
    TResult Function(String message, Object? exception, StackTrace? stackTrace)?
    error,
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
    required TResult Function(AsyncInitial<T> value) initial,
    required TResult Function(AsyncLoading<T> value) loading,
    required TResult Function(AsyncSuccess<T> value) success,
    required TResult Function(AsyncError<T> value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncInitial<T> value)? initial,
    TResult? Function(AsyncLoading<T> value)? loading,
    TResult? Function(AsyncSuccess<T> value)? success,
    TResult? Function(AsyncError<T> value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncInitial<T> value)? initial,
    TResult Function(AsyncLoading<T> value)? loading,
    TResult Function(AsyncSuccess<T> value)? success,
    TResult Function(AsyncError<T> value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class AsyncSuccess<T> extends AsyncState<T> {
  const factory AsyncSuccess(final T data) = _$AsyncSuccessImpl<T>;
  const AsyncSuccess._() : super._();

  T get data;

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AsyncSuccessImplCopyWith<T, _$AsyncSuccessImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AsyncErrorImplCopyWith<T, $Res> {
  factory _$$AsyncErrorImplCopyWith(
    _$AsyncErrorImpl<T> value,
    $Res Function(_$AsyncErrorImpl<T>) then,
  ) = __$$AsyncErrorImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({String message, Object? exception, StackTrace? stackTrace});
}

/// @nodoc
class __$$AsyncErrorImplCopyWithImpl<T, $Res>
    extends _$AsyncStateCopyWithImpl<T, $Res, _$AsyncErrorImpl<T>>
    implements _$$AsyncErrorImplCopyWith<T, $Res> {
  __$$AsyncErrorImplCopyWithImpl(
    _$AsyncErrorImpl<T> _value,
    $Res Function(_$AsyncErrorImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? exception = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(
      _$AsyncErrorImpl<T>(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        freezed == exception ? _value.exception : exception,
        freezed == stackTrace
            ? _value.stackTrace
            : stackTrace // ignore: cast_nullable_to_non_nullable
                  as StackTrace?,
      ),
    );
  }
}

/// @nodoc

class _$AsyncErrorImpl<T> extends AsyncError<T> {
  const _$AsyncErrorImpl(this.message, [this.exception, this.stackTrace])
    : super._();

  @override
  final String message;
  @override
  final Object? exception;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'AsyncState<$T>.error(message: $message, exception: $exception, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsyncErrorImpl<T> &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.exception, exception) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(exception),
    stackTrace,
  );

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AsyncErrorImplCopyWith<T, _$AsyncErrorImpl<T>> get copyWith =>
      __$$AsyncErrorImplCopyWithImpl<T, _$AsyncErrorImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(T? previousData) loading,
    required TResult Function(T data) success,
    required TResult Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )
    error,
  }) {
    return error(message, exception, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(T? previousData)? loading,
    TResult? Function(T data)? success,
    TResult? Function(
      String message,
      Object? exception,
      StackTrace? stackTrace,
    )?
    error,
  }) {
    return error?.call(message, exception, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(T? previousData)? loading,
    TResult Function(T data)? success,
    TResult Function(String message, Object? exception, StackTrace? stackTrace)?
    error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, exception, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AsyncInitial<T> value) initial,
    required TResult Function(AsyncLoading<T> value) loading,
    required TResult Function(AsyncSuccess<T> value) success,
    required TResult Function(AsyncError<T> value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AsyncInitial<T> value)? initial,
    TResult? Function(AsyncLoading<T> value)? loading,
    TResult? Function(AsyncSuccess<T> value)? success,
    TResult? Function(AsyncError<T> value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AsyncInitial<T> value)? initial,
    TResult Function(AsyncLoading<T> value)? loading,
    TResult Function(AsyncSuccess<T> value)? success,
    TResult Function(AsyncError<T> value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class AsyncError<T> extends AsyncState<T> {
  const factory AsyncError(
    final String message, [
    final Object? exception,
    final StackTrace? stackTrace,
  ]) = _$AsyncErrorImpl<T>;
  const AsyncError._() : super._();

  String get message;
  Object? get exception;
  StackTrace? get stackTrace;

  /// Create a copy of AsyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AsyncErrorImplCopyWith<T, _$AsyncErrorImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
