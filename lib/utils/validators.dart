/// 验证工具类
///
/// 统一封装各种表单验证逻辑
/// 消除分散在各处的验证代码
class Validators {
  /// 验证手机号格式（中国大陆）
  ///
  /// 返回 null 表示验证通过，否则返回错误信息
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }

    // 移除非数字字符
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    // 如果超过 11 位，取最后 11 位
    if (cleaned.length > 11) {
      cleaned = cleaned.substring(cleaned.length - 11);
    }

    // 验证是否为有效的 11 位手机号
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(cleaned)) {
      return '请输入正确的 11 位手机号';
    }

    return null;
  }

  /// 验证验证码（6 位数字）
  static String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return '请输入 6 位数字验证码';
    }

    return null;
  }

  /// 验证姓名
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入姓名';
    }

    if (value.length < 2) {
      return '姓名至少需要 2 个字符';
    }

    if (value.length > 20) {
      return '姓名不能超过 20 个字符';
    }

    return null;
  }

  /// 验证是否为空
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    return null;
  }

  /// 验证邮箱格式
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }

    // 简单邮箱验证
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '请输入正确的邮箱地址';
    }

    return null;
  }

  /// 验证密码（6-20 位）
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }

    if (value.length < 6) {
      return '密码至少需要 6 个字符';
    }

    if (value.length > 20) {
      return '密码不能超过 20 个字符';
    }

    return null;
  }
}
