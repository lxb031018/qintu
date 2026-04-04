/// ============================================
/// 应用角色常量
///
/// 统一定义应用中使用的角色相关常量
/// 避免在代码中硬编码 'sender'/'receiver' 字符串
/// ============================================

/// 用户角色类型
class AppRoles {
  /// 发送者
  static const String sender = 'sender';

  /// 接收者
  static const String receiver = 'receiver';

  /// 两者皆可
  static const String both = 'both';

  /// 所有角色列表
  static const List<String> all = [sender, receiver, both];

  /// 检查角色是否有效
  static bool isValid(String role) => all.contains(role);

  /// 检查是否为发送者角色
  static bool isSender(String role) => role == sender || role == both;

  /// 检查是否为接收者角色
  static bool isReceiver(String role) => role == receiver || role == both;
}
