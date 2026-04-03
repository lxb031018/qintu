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
  static const String appSubtitle = '让爱导航回家';

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

  /// 角色选择提示
  static const String roleSelectionHint = '选择后可以在设置中更改';

  /// 我是长辈
  static const String iAmElder = '我是长辈';

  /// 我是晚辈
  static const String iAmJunior = '我是晚辈';

  /// 长辈角色描述
  static const String elderRoleDescription = '接受子女的导航帮助';

  /// 晚辈角色描述
  static const String juniorRoleDescription = '为长辈规划导航路线';

  /// 角色设置成功
  static const String roleSetSuccess = '角色设置成功';

  /// 角色设置提示
  static String roleSetSuccessMessage(String role) => '您已选择$role，即将进入主页';

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
}