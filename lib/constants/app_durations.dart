// ============================================
// 应用时间常量
//
// 统一定义应用中使用的所有时间相关常量
// 便于维护和修改
// ============================================

class AppDurations {
  // ==================== 网络相关 ====================

  /// 网络请求超时时间
  static const Duration networkTimeout = Duration(seconds: 30);

  /// 网络请求重试次数
  static const int maxRetryCount = 3;

  // ==================== 动画相关 ====================

  /// 标准动画时长
  static const Duration standardAnimation = Duration(milliseconds: 300);

  /// 快速动画时长
  static const Duration fastAnimation = Duration(milliseconds: 200);

  /// 慢速动画时长
  static const Duration slowAnimation = Duration(milliseconds: 500);

  /// 启动页动画时长
  static const Duration splashAnimation = Duration(milliseconds: 800);

  // ==================== 倒计时相关 ====================

  /// 验证码倒计时时长
  static const Duration verificationCodeCountdown = Duration(seconds: 60);

  /// 通用倒计时时长（5 秒）
  static const Duration shortCountdown = Duration(seconds: 5);

  // ==================== 轮询/定时任务 ====================

  /// 位置更新间隔
  static const Duration locationUpdateInterval = Duration(seconds: 5);

  /// 任务轮询间隔
  static const Duration taskPollingInterval = Duration(seconds: 10);

  /// 日志刷新间隔
  static const Duration logFlushInterval = Duration(seconds: 2);

  // ==================== 启动/初始化 ====================

  /// 启动页最小显示时长
  static const Duration splashMinDuration = Duration(seconds: 1);

  /// 初始化延迟（用于确保 Provider 初始化完成）
  static const Duration initDelay = Duration.zero;

  // ==================== 日志相关 ====================

  /// 日志缓冲区最大大小
  static const int maxLogBufferSize = 50;

  /// 日志文件最大大小（10MB）
  static const int maxLogFileSize = 10 * 1024 * 1024;

  /// 保留的旧日志文件数量
  static const int maxRotatedLogFiles = 5;
}
