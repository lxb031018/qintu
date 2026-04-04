/// 认证仓库
///
/// 职责：
/// - 封装认证相关的数据访问
/// - 统一错误处理和日志记录
/// - 为 Provider 提供清晰的接口
///
/// 注意：此仓库为未来重构准备
/// 当前认证功能仍使用 CloudBaseAuthService 静态方法
class AuthRepository {
  /// 发送验证码
  Future<String> sendVerificationCode(String phoneNumber) async {
    // TODO: 实现
    throw UnimplementedError('认证仓库待实现');
  }

  /// 验证验证码
  Future<String> verifyCode(String verificationId, String code) async {
    // TODO: 实现
    throw UnimplementedError('认证仓库待实现');
  }

  /// 智能登录/注册
  Future<void> signInOrSignUp({
    required String verificationToken,
    required String phoneNumber,
  }) async {
    // TODO: 实现
    throw UnimplementedError('认证仓库待实现');
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    // TODO: 实现
    return false;
  }
}
