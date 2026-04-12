// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserState {
  AuthStatus get authStatus => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  int get pendingBindingCount => throw _privateConstructorUsedError;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStateCopyWith<UserState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStateCopyWith<$Res> {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) then) =
      _$UserStateCopyWithImpl<$Res, UserState>;
  @useResult
  $Res call({
    AuthStatus authStatus,
    String? userId,
    String? phoneNumber,
    bool isLoading,
    String? errorMessage,
    int pendingBindingCount,
  });
}

/// @nodoc
class _$UserStateCopyWithImpl<$Res, $Val extends UserState>
    implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authStatus = null,
    Object? userId = freezed,
    Object? phoneNumber = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? pendingBindingCount = null,
  }) {
    return _then(
      _value.copyWith(
            authStatus: null == authStatus
                ? _value.authStatus
                : authStatus // ignore: cast_nullable_to_non_nullable
                      as AuthStatus,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            pendingBindingCount: null == pendingBindingCount
                ? _value.pendingBindingCount
                : pendingBindingCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserStateImplCopyWith<$Res>
    implements $UserStateCopyWith<$Res> {
  factory _$$UserStateImplCopyWith(
    _$UserStateImpl value,
    $Res Function(_$UserStateImpl) then,
  ) = __$$UserStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AuthStatus authStatus,
    String? userId,
    String? phoneNumber,
    bool isLoading,
    String? errorMessage,
    int pendingBindingCount,
  });
}

/// @nodoc
class __$$UserStateImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UserStateImpl>
    implements _$$UserStateImplCopyWith<$Res> {
  __$$UserStateImplCopyWithImpl(
    _$UserStateImpl _value,
    $Res Function(_$UserStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authStatus = null,
    Object? userId = freezed,
    Object? phoneNumber = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? pendingBindingCount = null,
  }) {
    return _then(
      _$UserStateImpl(
        authStatus: null == authStatus
            ? _value.authStatus
            : authStatus // ignore: cast_nullable_to_non_nullable
                  as AuthStatus,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        pendingBindingCount: null == pendingBindingCount
            ? _value.pendingBindingCount
            : pendingBindingCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$UserStateImpl extends _UserState {
  const _$UserStateImpl({
    this.authStatus = AuthStatus.unknown,
    this.userId,
    this.phoneNumber,
    this.isLoading = false,
    this.errorMessage,
    this.pendingBindingCount = 0,
  }) : super._();

  @override
  @JsonKey()
  final AuthStatus authStatus;
  @override
  final String? userId;
  @override
  final String? phoneNumber;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final int pendingBindingCount;

  @override
  String toString() {
    return 'UserState(authStatus: $authStatus, userId: $userId, phoneNumber: $phoneNumber, isLoading: $isLoading, errorMessage: $errorMessage, pendingBindingCount: $pendingBindingCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStateImpl &&
            (identical(other.authStatus, authStatus) ||
                other.authStatus == authStatus) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.pendingBindingCount, pendingBindingCount) ||
                other.pendingBindingCount == pendingBindingCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    authStatus,
    userId,
    phoneNumber,
    isLoading,
    errorMessage,
    pendingBindingCount,
  );

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStateImplCopyWith<_$UserStateImpl> get copyWith =>
      __$$UserStateImplCopyWithImpl<_$UserStateImpl>(this, _$identity);
}

abstract class _UserState extends UserState {
  const factory _UserState({
    final AuthStatus authStatus,
    final String? userId,
    final String? phoneNumber,
    final bool isLoading,
    final String? errorMessage,
    final int pendingBindingCount,
  }) = _$UserStateImpl;
  const _UserState._() : super._();

  @override
  AuthStatus get authStatus;
  @override
  String? get userId;
  @override
  String? get phoneNumber;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  int get pendingBindingCount;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStateImplCopyWith<_$UserStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
