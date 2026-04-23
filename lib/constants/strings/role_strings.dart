/// 角色和绑定相关字符串
class RoleStrings {
  /// 角色选择标题
  static const String roleSelectionTitle = '欢迎使用亲途';

  /// 我是接收者
  static const String iAmReceiver = '我是接收者';

  /// 我是发送者
  static const String iAmSender = '我是发送者';

  /// 接收者角色描述
  static const String receiverRoleDescription = '接收导航指引，轻松出行';

  /// 发送者角色描述
  static const String senderRoleDescription = '发送导航指引，帮助他人';

  /// 角色设置提示
  static String roleSetSuccessMessage(String role) => '您已选择$role，即将进入主页';

  /// 角色（接收者端）
  static const String roleReceiver = '接收者端';

  /// 角色（发送者端）
  static const String roleSender = '发送者端';

  /// 切换角色
  static const String switchRole = '切换角色';

  /// 切换
  static const String switchText = '切换';

  /// 点击右侧按钮切换角色
  static const String switchRoleHint = '点击右侧按钮切换角色';

  /// 接收者
  static const String receiver = '接收者';

  /// 发送者
  static const String sender = '发送者';

  /// 确认切换角色提示
  static String confirmSwitchRole(String role) => '确定要切换到$role吗？';

  /// 角色未设置
  static const String roleNotSet = '未设置';

  /// 切换角色失败
  static String switchRoleFailed(String error) => '切换角色失败: $error';

  /// 当前角色
  static const String currentRole = '当前角色';
}
