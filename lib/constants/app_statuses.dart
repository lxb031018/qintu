/// ============================================
/// 应用状态常量
///
/// 统一定义应用中使用的状态相关常量
/// 避免在代码中硬编码 'active'/'disabled'/'pending' 等字符串
/// ============================================

/// 用户账号状态
class AppUserStatuses {
  /// 正常状态
  static const String active = 'active';

  /// 禁用状态
  static const String disabled = 'disabled';

  /// 所有状态列表
  static const List<String> all = [active, disabled];

  /// 检查状态是否有效
  static bool isValid(String status) => all.contains(status);

  /// 检查是否已激活
  static bool isActive(String status) => status == active;
}

/// 绑定关系状态
class AppBindingStatuses {
  /// 待确认
  static const String pending = 'pending';

  /// 生效中
  static const String active = 'active';

  /// 已过期
  static const String expired = 'expired';

  /// 已解除
  static const String revoked = 'revoked';

  /// 所有状态列表
  static const List<String> all = [pending, active, expired, revoked];

  /// 检查状态是否有效
  static bool isValid(String status) => all.contains(status);

  /// 是否生效中
  static bool isActive(String status) => status == active;

  /// 是否待确认
  static bool isPending(String status) => status == pending;
}

/// 导航任务状态
class AppTaskStatuses {
  /// 待处理
  static const String pending = 'pending';

  /// 进行中
  static const String inProgress = 'in_progress';

  /// 已完成
  static const String completed = 'completed';

  /// 已取消
  static const String cancelled = 'cancelled';

  /// 所有状态列表
  static const List<String> all = [pending, inProgress, completed, cancelled];

  /// 检查状态是否有效
  static bool isValid(String status) => all.contains(status);

  /// 是否待处理
  static bool isPending(String status) => status == pending;

  /// 是否进行中
  static bool isInProgress(String status) => status == inProgress;

  /// 是否已完成
  static bool isCompleted(String status) => status == completed;
}
