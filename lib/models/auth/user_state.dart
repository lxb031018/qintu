import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_state.freezed.dart';

/// 用户状态枚举
enum AuthStatus {
  unknown,      // 未知状态
  unauthenticated,  // 未认证
  authenticated,    // 已认证
  loading,      // 加载中
}

/// 用户状态模型（不可变）
///
/// 安全说明：
/// - Token（accessToken/refreshToken）不存储在此状态中
/// - Token 仅存在于 SecureStorage 中，由 ApiClient 拦截器按需读取
///
/// 注意：已删除 userRole 字段，所有用户使用统一主页
@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    @Default(AuthStatus.unknown) AuthStatus authStatus,
    String? userId,
    String? phoneNumber,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(0) int pendingBindingCount,
  }) = _UserState;

  const UserState._();

  /// 初始状态
  factory UserState.initial() => const UserState();

  /// 检查是否已登录
  bool get isLoggedIn => authStatus == AuthStatus.authenticated;
}
