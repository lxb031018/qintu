// ============================================
// API 端点常量
//
// 统一定义所有 API 路径
// 避免在业务代码中硬编码 URL 路径
// ============================================

import '../config/environments/environment_manager.dart';

class ApiEndpoints {
  // ==================== 通用配置 ====================

  /// API 路径前缀
  static const String apiPrefix = '/api';

  // ==================== 认证相关配置 ====================

  /// 认证 API 基础地址
  /// 根据环境自动选择：本地 → EnvironmentManager.baseUrl，CloudBase → CloudBase 网关
  static String get authBaseUrl => EnvironmentManager.baseUrl;

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

  /// 获取我发出的绑定请求
  static const String getSentRequests = '/api/bindings/sent';

  /// 确认绑定请求
  static const String confirmRequest = '/api/bindings/confirm-request';

  /// 拒绝绑定请求
  static const String rejectRequest = '/api/bindings/reject-request';

  /// 获取我的绑定关系
  static const String getMyBindings = '/api/bindings/my';

  /// 解除绑定
  static const String revokeBinding = '/api/bindings'; // + /{id}

  /// 取消发出的绑定请求
  static String cancelSentRequest(int requestId) => '/api/bindings/$requestId';

  // ==================== 用户管理 ====================

  /// 同步用户信息
  static const String syncUser = '/api/users/sync';

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
  // 注意：以下端点在 CloudBase 环境下走官方 Auth API，本地环境下走自建后端

  /// 发送验证码
  /// 本地: POST /auth/v1/verification → 自建后端（控制台打印验证码）
  /// CloudBase: POST /auth/v1/verification → CloudBase Auth v2（短信发送）
  static const String sendVerificationCode = '/auth/v1/verification';

  /// 验证验证码
  /// 本地: POST /auth/v1/verification/verify → 自建后端
  /// CloudBase: POST /auth/v1/verification/verify → CloudBase Auth v2
  static const String verifyCode = '/auth/v1/verification/verify';

  /// 登录
  /// 本地: POST /auth/v1/signin → 自建后端
  /// CloudBase: POST /auth/v1/signin → CloudBase Auth v2
  static const String signIn = '/auth/v1/signin';

  /// 注册/登录（新用户首次）
  /// 本地: POST /auth/v1/signup → 自建后端
  /// CloudBase: POST /auth/v1/signup → CloudBase Auth v2
  static const String signUp = '/auth/v1/signup';

  /// 刷新令牌
  /// CloudBase 官方 Auth API: POST /auth/v1/refreshtoken
  static const String refreshToken = '/auth/v1/refreshtoken';

  /// 登出
  /// CloudBase 官方 Auth API: POST /auth/v1/signout
  /// 注意：实际路由为 /auth/api/auth/sign-out (通过 requireAuth 中间件保护)
  static const String signOut = '/auth/api/auth/sign-out';

  // ==================== 路由分享 ====================

  /// 发送路由分享
  static const String routeShareSend = '/api/route-share/send';

  /// 获取待接收的路由分享
  static const String routeSharePending = '/api/route-share/pending';
}
