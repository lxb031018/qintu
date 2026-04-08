// ============================================
// API 端点常量
//
// 统一定义所有 API 端点路径
// 避免在代码中硬编码 URL 路径
// ============================================

import '../config/app_config.dart';

class ApiEndpoints {
  // ==================== 认证相关配置 ====================

  /// 认证 API 基础地址
  static String get authBaseUrl => AppConfig.authBaseUrl;

  // ==================== 用户管理 ====================

  /// 用户注册
  static const String registerUser = '/api/users/register';

  /// 获取当前用户信息
  static const String getCurrentUser = '/api/users/me';

  /// 更新用户信息
  static const String updateUser = '/api/users/me';

  /// 删除用户账号
  static const String deleteUser = '/api/users/me';

  // ==================== 绑定关系 ====================

  /// 发送绑定请求（手机号绑定）
  static const String requestPhoneBinding = '/api/bindings/request-phone';

  /// 获取待确认的绑定请求
  static const String getPendingRequests = '/api/bindings/pending';

  /// 确认绑定请求
  static const String confirmRequest = '/api/bindings/confirm-request';

  /// 拒绝绑定请求
  static const String rejectRequest = '/api/bindings/reject-request';

  /// 获取我的绑定关系
  static const String getMyBindings = '/api/bindings/my';

  /// 解除绑定
  static const String revokeBinding = '/api/bindings'; // + /{id}

  // ==================== 导航任务 ====================

  /// 创建导航任务
  static const String createTask = '/api/tasks';

  /// 获取我的任务
  static const String getMyTasks = '/api/tasks/my';

  /// 获取任务详情
  static const String getTask = '/api/tasks'; // + /{id}

  /// 接受任务
  static const String acceptTask = '/api/tasks'; // + /{id}/accept

  /// 拒绝任务
  static const String rejectTask = '/api/tasks'; // + /{id}/reject

  /// 取消任务
  static const String cancelTask = '/api/tasks'; // + /{id}/cancel

  /// 完成任务
  static const String completeTask = '/api/tasks'; // + /{id}/complete

  /// 修改路线
  static const String updateRoute = '/api/tasks'; // + /{id}/route

  /// 获取任务状态
  static const String getTaskStatus = '/api/tasks'; // + /{id}/status

  // ==================== 实时位置 ====================

  /// 上报位置
  static const String reportLocation = '/api/locations';

  /// 获取位置
  static const String getLocation = '/api/locations'; // + /{userId}

  /// 获取最后位置
  static const String getLastLocation = '/api/locations'; // + /{userId}/last

  // ==================== 认证相关 ====================
  // 使用 CloudBase 官方 Auth API

  /// 发送验证码
  /// CloudBase 官方 Auth API: POST /auth/v1/verification
  static const String sendVerificationCode = '/auth/v1/verification';

  /// 验证验证码
  /// CloudBase 官方 Auth API: POST /auth/v1/verification/verify
  static const String verifyCode = '/auth/v1/verification/verify';

  /// 登录（老用户）
  /// CloudBase 官方 Auth API: POST /auth/v1/signin
  static const String signIn = '/auth/v1/signin';

  /// 注册/登录（新用户首次登录）
  /// CloudBase 官方 Auth API: POST /auth/v1/signup
  /// 注意：CloudBase 官方 API 中，signup 和 signin 是同一个流程
  /// 新用户验证成功后会自动创建用户，无需单独调用 signup
  static const String signUp = '/auth/v1/signup';

  /// 刷新令牌
  /// CloudBase 官方 Auth API: POST /auth/v1/refreshtoken
  static const String refreshToken = '/auth/v1/refreshtoken';

  /// 登出
  /// CloudBase 官方 Auth API: POST /auth/v1/signout
  static const String signOut = '/auth/v1/signout';
}
