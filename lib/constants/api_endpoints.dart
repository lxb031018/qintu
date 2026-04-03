import '../config/app_config.dart';

/// API 端点常量 - 统一定义所有 API 端点地址

class ApiEndpoints {
  // ==================== 基础地址（统一来源：AppConfig）====================

  /// CloudBase 网关地址（从 AppConfig 引用）
  static String get gatewayUrl => AppConfig.gatewayUrl;

  /// 认证 API 基础路径
  static String get authBaseUrl => '$gatewayUrl/auth/v1';

  /// 数据库 API 基础路径
  static String get databaseBaseUrl => '$gatewayUrl/v1/rdb/rest';

  /// 云函数 API 基础路径
  static String get functionsBaseUrl => '$gatewayUrl/v1/functions';

  // ==================== 认证相关 API ====================

  /// 发送验证码
  static const String sendVerificationCode = '/verification';

  /// 验证验证码
  static const String verifyCode = '/verification/verify';

  /// 登录
  static const String signIn = '/signin';

  /// 注册
  static const String signUp = '/signup';

  /// 刷新 Token
  static const String refreshToken = '/token/refresh';

  /// 退出登录
  static const String signOut = '/signout';

  // ==================== 用户相关 API ====================

  /// 更新用户信息
  static const String updateUser = '/auth/v1/user';

  /// 删除用户
  static const String deleteUser = '/auth/v1/user';

  // ==================== 数据库相关 API ====================

  /// 查询用户资料
  static String getUserProfile(String uid) => '/v1/rdb/rest/user_profiles?uid=eq.$uid';

  /// 创建用户资料
  static const String createUserProfile = '/v1/rdb/rest/user_profiles';

  /// 更新用户资料
  static String updateUserProfile(String uid) => '/v1/rdb/rest/user_profiles?uid=eq.$uid';

  // ==================== 导航任务相关 API ====================

  /// 查询导航任务
  static const String getNavigationTasks = '/v1/rdb/rest/navigation_tasks';

  /// 创建导航任务
  static const String createNavigationTask = '/v1/rdb/rest/navigation_tasks';

  /// 更新导航任务
  static String updateNavigationTask(String taskId) => '/v1/rdb/rest/navigation_tasks?id=eq.$taskId';

  // ==================== 云函数 API ====================

  /// 调用云函数
  static String callFunction(String functionName) => '/v1/functions/$functionName';

  // ==================== 完整 URL 构建 ====================

  /// 构建认证 API 完整 URL
  static String buildAuthUrl(String endpoint) => '$gatewayUrl$endpoint';

  /// 构建数据库 API 完整 URL
  static String buildDatabaseUrl(String endpoint) => '$gatewayUrl$endpoint';

  /// 构建云函数 API 完整 URL
  static String buildFunctionUrl(String functionName) => '$gatewayUrl/v1/functions/$functionName';

  // ==================== 请求参数 ====================

  /// 发送验证码目标类型
  static const String targetAny = 'ANY';

  /// 用户角色：长辈
  static const String roleElder = 'elder';

  /// 用户角色：晚辈
  static const String roleJunior = 'junior';
}