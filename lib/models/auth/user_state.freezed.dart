// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserState {

 AuthStatus get authStatus; String? get userId; String? get phoneNumber; bool get isLoading; String? get errorMessage; int get pendingBindingCount;
/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStateCopyWith<UserState> get copyWith => _$UserStateCopyWithImpl<UserState>(this as UserState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserState&&(identical(other.authStatus, authStatus) || other.authStatus == authStatus)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.pendingBindingCount, pendingBindingCount) || other.pendingBindingCount == pendingBindingCount));
}


@override
int get hashCode => Object.hash(runtimeType,authStatus,userId,phoneNumber,isLoading,errorMessage,pendingBindingCount);

@override
String toString() {
  return 'UserState(authStatus: $authStatus, userId: $userId, phoneNumber: $phoneNumber, isLoading: $isLoading, errorMessage: $errorMessage, pendingBindingCount: $pendingBindingCount)';
}


}

/// @nodoc
abstract mixin class $UserStateCopyWith<$Res>  {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) _then) = _$UserStateCopyWithImpl;
@useResult
$Res call({
 AuthStatus authStatus, String? userId, String? phoneNumber, bool isLoading, String? errorMessage, int pendingBindingCount
});




}
/// @nodoc
class _$UserStateCopyWithImpl<$Res>
    implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._self, this._then);

  final UserState _self;
  final $Res Function(UserState) _then;

/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authStatus = null,Object? userId = freezed,Object? phoneNumber = freezed,Object? isLoading = null,Object? errorMessage = freezed,Object? pendingBindingCount = null,}) {
  return _then(_self.copyWith(
authStatus: null == authStatus ? _self.authStatus : authStatus // ignore: cast_nullable_to_non_nullable
as AuthStatus,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,pendingBindingCount: null == pendingBindingCount ? _self.pendingBindingCount : pendingBindingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserState].
extension UserStatePatterns on UserState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserState value)  $default,){
final _that = this;
switch (_that) {
case _UserState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserState value)?  $default,){
final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthStatus authStatus,  String? userId,  String? phoneNumber,  bool isLoading,  String? errorMessage,  int pendingBindingCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that.authStatus,_that.userId,_that.phoneNumber,_that.isLoading,_that.errorMessage,_that.pendingBindingCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthStatus authStatus,  String? userId,  String? phoneNumber,  bool isLoading,  String? errorMessage,  int pendingBindingCount)  $default,) {final _that = this;
switch (_that) {
case _UserState():
return $default(_that.authStatus,_that.userId,_that.phoneNumber,_that.isLoading,_that.errorMessage,_that.pendingBindingCount);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthStatus authStatus,  String? userId,  String? phoneNumber,  bool isLoading,  String? errorMessage,  int pendingBindingCount)?  $default,) {final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that.authStatus,_that.userId,_that.phoneNumber,_that.isLoading,_that.errorMessage,_that.pendingBindingCount);case _:
  return null;

}
}

}

/// @nodoc


class _UserState extends UserState {
  const _UserState({this.authStatus = AuthStatus.unknown, this.userId, this.phoneNumber, this.isLoading = false, this.errorMessage, this.pendingBindingCount = 0}): super._();
  

@override@JsonKey() final  AuthStatus authStatus;
@override final  String? userId;
@override final  String? phoneNumber;
@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
@override@JsonKey() final  int pendingBindingCount;

/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStateCopyWith<_UserState> get copyWith => __$UserStateCopyWithImpl<_UserState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserState&&(identical(other.authStatus, authStatus) || other.authStatus == authStatus)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.pendingBindingCount, pendingBindingCount) || other.pendingBindingCount == pendingBindingCount));
}


@override
int get hashCode => Object.hash(runtimeType,authStatus,userId,phoneNumber,isLoading,errorMessage,pendingBindingCount);

@override
String toString() {
  return 'UserState(authStatus: $authStatus, userId: $userId, phoneNumber: $phoneNumber, isLoading: $isLoading, errorMessage: $errorMessage, pendingBindingCount: $pendingBindingCount)';
}


}

/// @nodoc
abstract mixin class _$UserStateCopyWith<$Res> implements $UserStateCopyWith<$Res> {
  factory _$UserStateCopyWith(_UserState value, $Res Function(_UserState) _then) = __$UserStateCopyWithImpl;
@override @useResult
$Res call({
 AuthStatus authStatus, String? userId, String? phoneNumber, bool isLoading, String? errorMessage, int pendingBindingCount
});




}
/// @nodoc
class __$UserStateCopyWithImpl<$Res>
    implements _$UserStateCopyWith<$Res> {
  __$UserStateCopyWithImpl(this._self, this._then);

  final _UserState _self;
  final $Res Function(_UserState) _then;

/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authStatus = null,Object? userId = freezed,Object? phoneNumber = freezed,Object? isLoading = null,Object? errorMessage = freezed,Object? pendingBindingCount = null,}) {
  return _then(_UserState(
authStatus: null == authStatus ? _self.authStatus : authStatus // ignore: cast_nullable_to_non_nullable
as AuthStatus,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,pendingBindingCount: null == pendingBindingCount ? _self.pendingBindingCount : pendingBindingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
