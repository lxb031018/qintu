/// 通知和绑定请求相关字符串
class NotificationStrings {
  /// 通知中心（按钮 tooltip）
  static const String notificationCenterTooltip = '通知中心';

  /// 绑定请求通知
  static const String bindingRequests = '绑定请求';

  /// 待确认的绑定请求
  static const String pendingBindingRequests = '待确认的绑定请求';

  /// 暂无待确认请求
  static const String noPendingRequests = '暂无待确认请求';

  /// 接受绑定请求
  static const String acceptBindingRequest = '接受';

  /// 拒绝绑定请求
  static const String rejectBindingRequest = '拒绝';

  /// 接受确认对话框
  static const String acceptBindingRequestConfirm = '确定要接受这个绑定请求吗？接受后双方将建立绑定关系。';

  /// 拒绝确认对话框
  static const String rejectBindingRequestConfirm = '确定要拒绝这个绑定请求吗？';

  /// 接受成功
  static const String acceptBindingRequestSuccess = '已接受绑定请求，绑定关系已生效';

  /// 拒绝成功
  static const String rejectBindingRequestSuccess = '已拒绝绑定请求';

  /// 接受失败
  static const String acceptBindingRequestFailed = '接受失败，请重试';

  /// 拒绝失败
  static const String rejectBindingRequestFailed = '拒绝失败，请重试';

  /// 请求时间格式
  static String requestTimeAgo(String time) => '⏰ $time';

  /// 绑定请求详情提示
  static const String bindingRequestDetailHint = '对方希望通过此绑定关系与您建立连接，接受后对方将能够与您共享位置信息';

  /// 通知中心
  static const String notificationCenter = '通知中心';

  /// 收到的请求
  static const String receivedRequests = '收到请求';

  /// 发出的请求
  static const String sentRequests = '发出请求';

  /// 被拒绝
  static const String rejectedRequests = '被拒绝';

  /// 暂无收到的请求
  static const String noReceivedRequests = '暂无收到请求';

  /// 暂无发出的请求
  static const String noSentRequests = '暂无发出请求';

  /// 暂无被拒绝的请求
  static const String noRejectedRequests = '暂无被拒绝的请求';

  /// 取消请求
  static const String cancelRequest = '取消请求';

  /// 确认取消请求
  static const String confirmCancelRequest = '确定要取消这个绑定请求吗？';

  /// 不取消
  static const String notCancel = '不取消';

  /// 确认取消
  static const String confirmCancel = '确认取消';

  /// 已取消请求
  static const String requestCancelled = '已取消请求';

  /// 取消失败
  static const String cancelRequestFailed = '取消失败';

  /// 等待对方确认
  static const String waitingForConfirmation = '等待对方确认';

  /// 对方已拒绝
  static const String requestRejected = '对方已拒绝';

  /// 已过期
  static const String requestExpired = '已过期';

  /// 已绑定
  static const String requestActive = '已绑定';

  /// 未知状态
  static const String unknownStatus = '未知状态';

  /// 不足 1 小时
  static const String lessThanOneHour = '不足 1 小时';

  /// 小时后过期
  static String hoursUntilExpire(int hours) => '$hours小时后过期';

  /// 天后过期
  static String daysUntilExpire(int days) => '$days天后过期';

  /// 发送于
  static String sentAt(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// 发送于（相对时间显示，不依赖时区）
  static String sentAtText(DateTime dt) {
    // 确保使用本地时间
    final localDt = dt.isUtc ? dt.toLocal() : dt;
    return '${localDt.year}-${localDt.month.toString().padLeft(2, '0')}-${localDt.day.toString().padLeft(2, '0')} ${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
  }

  /// 发送时间（简短相对时间，适合辅助显示）
  static String sentAtShort(DateTime dt) {
    final now = DateTime.now();
    final localDt = dt.isUtc ? dt.toLocal() : dt;
    final diff = now.difference(localDt);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${localDt.month}月${localDt.day}日';
  }

  /// 取消请求（按钮）
  static const String cancelRequestButton = '取消请求';

  /// 请求即将过期
  static const String requestExpiringSoon = '请求即将过期';

  /// 取消失败（日志用）
  static const String cancelFailedLog = '取消失败';
}
