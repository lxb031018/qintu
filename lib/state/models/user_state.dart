/// 用户状态枚举
enum AuthStatus {
  unknown,      // 未知状态
  unauthenticated,  // 未认证
  authenticated,    // 已认证
  loading,      // 加载中
}

/// 用户状态模型（不可变）
class UserState {
  final AuthStatus authStatus;
  final String? userId;
  final String? accessToken;
  final String? refreshToken;
  final String? phoneNumber;
  final String? userRole;
  final bool isLoading;
  final String? errorMessage;

  const UserState({
    this.authStatus = AuthStatus.unknown,
    this.userId,
    this.accessToken,
    this.refreshToken,
    this.phoneNumber,
    this.userRole,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 初始状态
  const UserState.initial()
      : authStatus = AuthStatus.unknown,
        userId = null,
        accessToken = null,
        refreshToken = null,
        phoneNumber = null,
        userRole = null,
        isLoading = false,
        errorMessage = null;

  /// 复制并修改状态
  UserState copyWith({
    AuthStatus? authStatus,
    String? userId,
    String? accessToken,
    String? refreshToken,
    String? phoneNumber,
    String? userRole,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserState(
      authStatus: authStatus ?? this.authStatus,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userRole: userRole ?? this.userRole,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // 默认不清除错误消息
    );
  }

  /// 检查是否已登录
  bool get isLoggedIn => authStatus == AuthStatus.authenticated;

  /// 检查是否有有效的 Token
  bool get hasTokens => accessToken != null && refreshToken != null;

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
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.phoneNumber == phoneNumber &&
        other.userRole == userRole &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
        authStatus,
        userId,
        accessToken,
        refreshToken,
        phoneNumber,
        userRole,
        isLoading,
        errorMessage,
      );
}
