/// 认证相关字符串
class AuthStrings {
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

  /// 手机号格式错误
  static const String invalidPhoneNumber = '请输入正确的 11 位手机号';

  /// 验证码格式错误
  static const String invalidVerificationCode = '请输入 6 位验证码';

  /// 请先获取验证码
  static const String pleaseGetCodeFirst = '请先获取验证码';
}
