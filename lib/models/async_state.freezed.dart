// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'async_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AsyncState<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AsyncState<$T>()';
}


}

/// @nodoc
class $AsyncStateCopyWith<T,$Res>  {
$AsyncStateCopyWith(AsyncState<T> _, $Res Function(AsyncState<T>) __);
}


/// Adds pattern-matching-related methods to [AsyncState].
extension AsyncStatePatterns<T> on AsyncState<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AsyncInitial<T> value)?  initial,TResult Function( AsyncLoading<T> value)?  loading,TResult Function( AsyncSuccess<T> value)?  success,TResult Function( AsyncError<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AsyncInitial() when initial != null:
return initial(_that);case AsyncLoading() when loading != null:
return loading(_that);case AsyncSuccess() when success != null:
return success(_that);case AsyncError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AsyncInitial<T> value)  initial,required TResult Function( AsyncLoading<T> value)  loading,required TResult Function( AsyncSuccess<T> value)  success,required TResult Function( AsyncError<T> value)  error,}){
final _that = this;
switch (_that) {
case AsyncInitial():
return initial(_that);case AsyncLoading():
return loading(_that);case AsyncSuccess():
return success(_that);case AsyncError():
return error(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AsyncInitial<T> value)?  initial,TResult? Function( AsyncLoading<T> value)?  loading,TResult? Function( AsyncSuccess<T> value)?  success,TResult? Function( AsyncError<T> value)?  error,}){
final _that = this;
switch (_that) {
case AsyncInitial() when initial != null:
return initial(_that);case AsyncLoading() when loading != null:
return loading(_that);case AsyncSuccess() when success != null:
return success(_that);case AsyncError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( T? previousData)?  loading,TResult Function( T data)?  success,TResult Function( String message,  Object? exception,  StackTrace? stackTrace)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AsyncInitial() when initial != null:
return initial();case AsyncLoading() when loading != null:
return loading(_that.previousData);case AsyncSuccess() when success != null:
return success(_that.data);case AsyncError() when error != null:
return error(_that.message,_that.exception,_that.stackTrace);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( T? previousData)  loading,required TResult Function( T data)  success,required TResult Function( String message,  Object? exception,  StackTrace? stackTrace)  error,}) {final _that = this;
switch (_that) {
case AsyncInitial():
return initial();case AsyncLoading():
return loading(_that.previousData);case AsyncSuccess():
return success(_that.data);case AsyncError():
return error(_that.message,_that.exception,_that.stackTrace);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( T? previousData)?  loading,TResult? Function( T data)?  success,TResult? Function( String message,  Object? exception,  StackTrace? stackTrace)?  error,}) {final _that = this;
switch (_that) {
case AsyncInitial() when initial != null:
return initial();case AsyncLoading() when loading != null:
return loading(_that.previousData);case AsyncSuccess() when success != null:
return success(_that.data);case AsyncError() when error != null:
return error(_that.message,_that.exception,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncInitial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AsyncState<$T>.initial()';
}


}




/// @nodoc


class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading({this.previousData}): super._();
  

 final  T? previousData;

/// Create a copy of AsyncState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsyncLoadingCopyWith<T, AsyncLoading<T>> get copyWith => _$AsyncLoadingCopyWithImpl<T, AsyncLoading<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncLoading<T>&&const DeepCollectionEquality().equals(other.previousData, previousData));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(previousData));

@override
String toString() {
  return 'AsyncState<$T>.loading(previousData: $previousData)';
}


}

/// @nodoc
abstract mixin class $AsyncLoadingCopyWith<T,$Res> implements $AsyncStateCopyWith<T, $Res> {
  factory $AsyncLoadingCopyWith(AsyncLoading<T> value, $Res Function(AsyncLoading<T>) _then) = _$AsyncLoadingCopyWithImpl;
@useResult
$Res call({
 T? previousData
});




}
/// @nodoc
class _$AsyncLoadingCopyWithImpl<T,$Res>
    implements $AsyncLoadingCopyWith<T, $Res> {
  _$AsyncLoadingCopyWithImpl(this._self, this._then);

  final AsyncLoading<T> _self;
  final $Res Function(AsyncLoading<T>) _then;

/// Create a copy of AsyncState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? previousData = freezed,}) {
  return _then(AsyncLoading<T>(
previousData: freezed == previousData ? _self.previousData : previousData // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}

/// @nodoc


class AsyncSuccess<T> extends AsyncState<T> {
  const AsyncSuccess(this.data): super._();
  

 final  T data;

/// Create a copy of AsyncState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsyncSuccessCopyWith<T, AsyncSuccess<T>> get copyWith => _$AsyncSuccessCopyWithImpl<T, AsyncSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncSuccess<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AsyncState<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $AsyncSuccessCopyWith<T,$Res> implements $AsyncStateCopyWith<T, $Res> {
  factory $AsyncSuccessCopyWith(AsyncSuccess<T> value, $Res Function(AsyncSuccess<T>) _then) = _$AsyncSuccessCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$AsyncSuccessCopyWithImpl<T,$Res>
    implements $AsyncSuccessCopyWith<T, $Res> {
  _$AsyncSuccessCopyWithImpl(this._self, this._then);

  final AsyncSuccess<T> _self;
  final $Res Function(AsyncSuccess<T>) _then;

/// Create a copy of AsyncState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(AsyncSuccess<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class AsyncError<T> extends AsyncState<T> {
  const AsyncError(this.message, [this.exception, this.stackTrace]): super._();
  

 final  String message;
 final  Object? exception;
 final  StackTrace? stackTrace;

/// Create a copy of AsyncState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsyncErrorCopyWith<T, AsyncError<T>> get copyWith => _$AsyncErrorCopyWithImpl<T, AsyncError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncError<T>&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.exception, exception)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(exception),stackTrace);

@override
String toString() {
  return 'AsyncState<$T>.error(message: $message, exception: $exception, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $AsyncErrorCopyWith<T,$Res> implements $AsyncStateCopyWith<T, $Res> {
  factory $AsyncErrorCopyWith(AsyncError<T> value, $Res Function(AsyncError<T>) _then) = _$AsyncErrorCopyWithImpl;
@useResult
$Res call({
 String message, Object? exception, StackTrace? stackTrace
});




}
/// @nodoc
class _$AsyncErrorCopyWithImpl<T,$Res>
    implements $AsyncErrorCopyWith<T, $Res> {
  _$AsyncErrorCopyWithImpl(this._self, this._then);

  final AsyncError<T> _self;
  final $Res Function(AsyncError<T>) _then;

/// Create a copy of AsyncState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? exception = freezed,Object? stackTrace = freezed,}) {
  return _then(AsyncError<T>(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,freezed == exception ? _self.exception : exception ,freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
