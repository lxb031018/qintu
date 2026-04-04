/// ============================================
/// 应用字符串常量
///
/// 统一定义应用中使用的所有文字
/// 便于国际化和管理
/// ============================================
class AppStrings {
  // ==================== 应用名称 ====================

  /// 应用名称
  static const String appName = '亲途';

  /// 应用副标题
  static const String appSubtitle = '指尖即是爱的方向';

  // ==================== 启动页 ====================

  /// 加载中提示
  static const String loading = '加载中...';

  // ==================== 认证页面 ====================

  /// 欢迎标题
  static const String welcomeTitle = '欢迎来到亲途';

  /// 登录副标题
  static const String loginSubtitle = '使用手机号验证码登录';

  /// 手机号输入提示
  static const String phoneHint = '请输入 11 位手机号';

  /// 手机号标签
  static const String phoneLabel = '手机号';

  /// 验证码输入提示
  static const String codeHint = '请输入 6 位验证码';

  /// 验证码标签
  static const String codeLabel = '验证码';

  /// 获取验证码按钮
  static const String getVerificationCode = '获取验证码';

  /// 登录按钮
  static const String login = '登录';

  /// 进入应用按钮
  static const String enterApp = '进入应用';

  /// 重新登录
  static const String relogin = '重新登录';

  /// 验证码已发送
  static const String codeSent = '验证码已发送至';

  /// 重新发送验证码
  static const String resendCode = '重新发送验证码';

  /// 重新发送（倒计时）
  static String resendCodeCountdown(int seconds) => '重新发送 ($seconds 秒)';

  /// 登录成功
  static const String loginSuccess = '登录成功！';

  /// 用户信息
  static const String userInfo = '用户信息';

  // ==================== 角色选择页面 ====================

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

  /// 角色设置成功
  static const String roleSetSuccess = '角色设置成功';

  /// 角色设置提示
  static String roleSetSuccessMessage(String role) => '您已选择$role，即将进入主页';

  // ==================== 位置权限 ====================

  /// 位置权限标题
  static const String locationPermissionTitle = '需要位置权限';

  /// 位置权限说明
  static const String locationPermissionMessage = '亲途需要获取您的位置信息以提供导航服务，请授权位置权限';

  /// 位置服务未开启
  static const String locationServiceDisabled = '位置服务未开启，请在设置中开启';

  /// 开启定位
  static const String openLocation = '开启定位';

  /// 定位已开启
  static const String locationEnabled = '定位已开启';

  /// 定位未开启
  static const String locationDisabled = '定位未开启';

  /// 等待导航
  static const String waitingForNavigation = '等待接收导航指引...';

  /// 暂无导航任务
  static const String noNavigationTask = '暂无导航任务';

  // ==================== 发送者端 ====================

  /// 发送者主页标题
  static const String senderHomeTitle = '发送导航指引';

  /// 输入起点
  static const String inputStartPoint = '输入起点';

  /// 输入终点
  static const String inputEndPoint = '输入终点';

  /// 起点标签
  static const String startPointLabel = '起点';

  /// 终点标签
  static const String endPointLabel = '终点';

  /// 规划路线
  static const String planRoute = '规划路线';

  /// 发送导航
  static const String sendNavigation = '发送导航';

  /// 选择接收者
  static const String selectReceiver = '选择接收者';

  // ==================== 退出登录 ====================

  /// 退出
  static const String logout = '退出';

  /// 退出确认标题
  static const String logoutConfirmTitle = '您确定退出嘛？>_<';

  /// 确定
  static const String confirmLogout = '确定';

  /// 取消
  static const String cancelLogout = '取消';

  /// 位置权限被拒绝
  static const String locationPermissionDenied = '位置权限被拒绝，部分功能可能受限';

  /// 前往设置
  static const String goToSettings = '前往设置';

  /// 稍后再说
  static const String later = '稍后再说';

  // ==================== 错误提示 ====================

  /// 手机号格式错误
  static const String invalidPhoneNumber = '请输入正确的 11 位手机号';

  /// 验证码格式错误
  static const String invalidVerificationCode = '请输入 6 位验证码';

  /// 请先获取验证码
  static const String pleaseGetCodeFirst = '请先获取验证码';

  /// 验证码发送失败
  static const String codeSendFailed = '验证码发送失败，请检查手机号是否正确';

  /// 验证码错误或已过期
  static const String codeInvalidOrExpired = '验证码错误或已过期，请重新获取';

  /// 验证码错误
  static const String codeInvalid = '验证码错误，请重新输入';

  /// 登录失败
  static const String loginFailed = '登录失败，请稍后重试';

  /// 注册失败
  static const String registerFailed = '注册失败，请稍后重试';

  /// 网络连接失败
  static const String networkError = '网络连接失败，请检查网络设置';

  /// 网络异常
  static const String networkException = '网络异常，请检查网络连接';

  /// 操作失败
  static const String operationFailed = '操作失败，请稍后重试';

  /// 验证码发送过于频繁
  static const String codeSendTooFrequent = '验证码发送过于频繁，请稍后再试';

  // ==================== 通用 ====================

  /// 确定
  static const String confirm = '确定';

  /// 取消
  static const String cancel = '取消';

  /// 保存
  static const String save = '保存';

  /// 删除
  static const String delete = '删除';

  /// 编辑
  static const String edit = '编辑';

  /// 返回
  static const String back = '返回';

  /// 加载中
  static const String loadingText = '加载中...';

  /// 设置失败
  static const String settingFailed = '设置失败';

  /// 保存失败
  static const String saveFailed = '保存失败，请重试';

  /// 保存角色信息失败
  static const String saveRoleFailed = '保存角色信息失败，请重试';

  /// 角色（接收者端）
  static const String roleReceiver = '接收者端';

  /// 角色（发送者端）
  static const String roleSender = '发送者端';
}
