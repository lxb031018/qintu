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
class UserState {
  final AuthStatus authStatus;
  final String? userId;
  final String? phoneNumber;
  final String? userRole;
  final bool isLoading;
  final String? errorMessage;
  
  /// 待确认的绑定请求数量
  final int pendingBindingCount;

  const UserState({
    this.authStatus = AuthStatus.unknown,
    this.userId,
    this.phoneNumber,
    this.userRole,
    this.isLoading = false,
    this.errorMessage,
    this.pendingBindingCount = 0,
  });

  /// 初始状态
  const UserState.initial()
      : authStatus = AuthStatus.unknown,
        userId = null,
        phoneNumber = null,
        userRole = null,
        isLoading = false,
        errorMessage = null,
        pendingBindingCount = 0;

  /// 复制并修改状态
  UserState copyWith({
    AuthStatus? authStatus,
    String? userId,
    String? phoneNumber,
    String? userRole,
    bool? isLoading,
    String? errorMessage,
    int? pendingBindingCount,
  }) {
    return UserState(
      authStatus: authStatus ?? this.authStatus,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userRole: userRole ?? this.userRole,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // 默认不清除错误消息
      pendingBindingCount: pendingBindingCount ?? this.pendingBindingCount,
    );
  }

  /// 检查是否已登录
  bool get isLoggedIn => authStatus == AuthStatus.authenticated;

  @override
  String toString() {
    return 'UserState('
        'authStatus: $authStatus, '
        'userId: $userId, '
        'userRole: $userRole, '
        'isLoading: $isLoading, '
        'hasError: ${errorMessage != null}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserState &&
        other.authStatus == authStatus &&
        other.userId == userId &&
        other.phoneNumber == phoneNumber &&
        other.userRole == userRole &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.pendingBindingCount == pendingBindingCount;
  }

  @override
  int get hashCode => Object.hash(
        authStatus,
        userId,
        phoneNumber,
        userRole,
        isLoading,
        errorMessage,
        pendingBindingCount,
      );
}
