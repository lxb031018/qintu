/// 日期时间格式化工具
///
/// 统一管理所有时间相关的格式化逻辑，消除重复代码
library;

class AppDateUtils {
  /// 相对时间格式化（"X分钟前"、"X小时前"、"X天前"）
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime).abs();

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';

    // 超过 7 天显示具体日期
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
  }

  /// 剩余时间格式化（"X分钟后过期"、"X天后过期"）
  static String formatRemaining(DateTime expireDateTime) {
    final remaining = expireDateTime.difference(DateTime.now());
    if (remaining.isNegative) return '已过期';
    if (remaining.inMinutes < 1) return '即将过期';
    if (remaining.inHours < 1) return '剩余 ${remaining.inMinutes} 分钟过期';
    if (remaining.inHours < 24) return '剩余 ${remaining.inHours} 小时过期';
    return '剩余 ${remaining.inDays} 天过期';
  }

  /// 固定格式（YYYY-MM-DD HH:mm）
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  /// 日期格式（YYYY-MM-DD）
  static String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
  }

  /// 两位数格式化（补零）
  static String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
