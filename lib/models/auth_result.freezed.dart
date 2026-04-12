// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthResult {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  int get accessTokenExpiresIn => throw _privateConstructorUsedError;
  int get refreshTokenExpiresIn => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  int get pendingCount => throw _privateConstructorUsedError;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResultCopyWith<AuthResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResultCopyWith<$Res> {
  factory $AuthResultCopyWith(
    AuthResult value,
    $Res Function(AuthResult) then,
  ) = _$AuthResultCopyWithImpl<$Res, AuthResult>;
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    int accessTokenExpiresIn,
    int refreshTokenExpiresIn,
    String uid,
    int pendingCount,
  });
}

/// @nodoc
class _$AuthResultCopyWithImpl<$Res, $Val extends AuthResult>
    implements $AuthResultCopyWith<$Res> {
  _$AuthResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? accessTokenExpiresIn = null,
    Object? refreshTokenExpiresIn = null,
    Object? uid = null,
    Object? pendingCount = null,
  }) {
    return _then(
      _value.copyWith(
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
            accessTokenExpiresIn: null == accessTokenExpiresIn
                ? _value.accessTokenExpiresIn
                : accessTokenExpiresIn // ignore: cast_nullable_to_non_nullable
                      as int,
            refreshTokenExpiresIn: null == refreshTokenExpiresIn
                ? _value.refreshTokenExpiresIn
                : refreshTokenExpiresIn // ignore: cast_nullable_to_non_nullable
                      as int,
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            pendingCount: null == pendingCount
                ? _value.pendingCount
                : pendingCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthResultImplCopyWith<$Res>
    implements $AuthResultCopyWith<$Res> {
  factory _$$AuthResultImplCopyWith(
    _$AuthResultImpl value,
    $Res Function(_$AuthResultImpl) then,
  ) = __$$AuthResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    int accessTokenExpiresIn,
    int refreshTokenExpiresIn,
    String uid,
    int pendingCount,
  });
}

/// @nodoc
class __$$AuthResultImplCopyWithImpl<$Res>
    extends _$AuthResultCopyWithImpl<$Res, _$AuthResultImpl>
    implements _$$AuthResultImplCopyWith<$Res> {
  __$$AuthResultImplCopyWithImpl(
    _$AuthResultImpl _value,
    $Res Function(_$AuthResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? accessTokenExpiresIn = null,
    Object? refreshTokenExpiresIn = null,
    Object? uid = null,
    Object? pendingCount = null,
  }) {
    return _then(
      _$AuthResultImpl(
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
        accessTokenExpiresIn: null == accessTokenExpiresIn
            ? _value.accessTokenExpiresIn
            : accessTokenExpiresIn // ignore: cast_nullable_to_non_nullable
                  as int,
        refreshTokenExpiresIn: null == refreshTokenExpiresIn
            ? _value.refreshTokenExpiresIn
            : refreshTokenExpiresIn // ignore: cast_nullable_to_non_nullable
                  as int,
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        pendingCount: null == pendingCount
            ? _value.pendingCount
            : pendingCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$AuthResultImpl extends _AuthResult {
  const _$AuthResultImpl({
    this.accessToken = '',
    this.refreshToken = '',
    this.accessTokenExpiresIn = 0,
    this.refreshTokenExpiresIn = 0,
    this.uid = '',
    this.pendingCount = 0,
  }) : super._();

  @override
  @JsonKey()
  final String accessToken;
  @override
  @JsonKey()
  final String refreshToken;
  @override
  @JsonKey()
  final int accessTokenExpiresIn;
  @override
  @JsonKey()
  final int refreshTokenExpiresIn;
  @override
  @JsonKey()
  final String uid;
  @override
  @JsonKey()
  final int pendingCount;

  @override
  String toString() {
    return 'AuthResult(accessToken: $accessToken, refreshToken: $refreshToken, accessTokenExpiresIn: $accessTokenExpiresIn, refreshTokenExpiresIn: $refreshTokenExpiresIn, uid: $uid, pendingCount: $pendingCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResultImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.accessTokenExpiresIn, accessTokenExpiresIn) ||
                other.accessTokenExpiresIn == accessTokenExpiresIn) &&
            (identical(other.refreshTokenExpiresIn, refreshTokenExpiresIn) ||
                other.refreshTokenExpiresIn == refreshTokenExpiresIn) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    accessToken,
    refreshToken,
    accessTokenExpiresIn,
    refreshTokenExpiresIn,
    uid,
    pendingCount,
  );

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      __$$AuthResultImplCopyWithImpl<_$AuthResultImpl>(this, _$identity);
}

abstract class _AuthResult extends AuthResult {
  const factory _AuthResult({
    final String accessToken,
    final String refreshToken,
    final int accessTokenExpiresIn,
    final int refreshTokenExpiresIn,
    final String uid,
    final int pendingCount,
  }) = _$AuthResultImpl;
  const _AuthResult._() : super._();

  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  int get accessTokenExpiresIn;
  @override
  int get refreshTokenExpiresIn;
  @override
  String get uid;
  @override
  int get pendingCount;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
