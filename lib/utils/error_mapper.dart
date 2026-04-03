// 错误映射工具 - 将后端错误转换为用户友好的提示信息

class ErrorMapper {
  /// 解析错误信息，返回用户友好的提示
  static String parse(String error) {
    // 如果包含"验证码"，说明是验证码相关错误
    if (error.contains('验证码')) {
      if (error.contains('发送失败')) {
        return '验证码发送失败，请检查手机号是否正确';
      }
      if (error.contains('验证失败')) {
        return '验证码错误或已过期，请重新获取';
      }
      return '验证码错误，请重新输入';
    }

    // 如果包含"登录失败"
    if (error.contains('登录失败')) {
      return '登录失败，请稍后重试';
    }

    // 如果包含"注册失败"
    if (error.contains('注册失败')) {
      return '注册失败，请稍后重试';
    }

    // 如果包含"网络"
    if (error.contains('网络')) {
      return '网络连接失败，请检查网络设置';
    }

    // 默认错误信息
    return '操作失败，请稍后重试';
  }
}