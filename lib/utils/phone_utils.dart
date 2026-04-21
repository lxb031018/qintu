/// 手机号脱敏工具
///
/// 用于保护用户隐私，在 UI 显示和日志打印时隐藏完整手机号
class PhoneUtils {
  /// 手机号脱敏
  ///
  /// 将手机号的中间 4 位替换为 ****
  /// 例如：13812345678 → 138****5678
  /// 
  /// 参数 [phone] 可以是任意格式（如 "+86 13812345678"、"13812345678"）
  static String maskPhone(String phone) {
    if (phone.isEmpty) return phone;

    // 移除所有非数字字符
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // 如果长度超过 11 位，取最后 11 位（处理国家代码）
    if (cleaned.length > 11) {
      cleaned = cleaned.substring(cleaned.length - 11);
    }

    // 如果不足 7 位，无法脱敏，直接返回
    if (cleaned.length < 7) {
      return cleaned;
    }

    // 脱敏处理：保留前 3 位和后 4 位
    return '${cleaned.substring(0, 3)}****${cleaned.substring(7)}';
  }

  /// 日志脱敏（带脱敏标记，便于日志审查）
  ///
  /// 例如：13812345678 → [脱敏]138****5678
  static String maskForLog(String phone) {
    if (phone.isEmpty) return phone;
    return '[脱敏]${maskPhone(phone)}';
  }

  /// 批量脱敏
  ///
  /// 用于列表显示等需要批量处理的场景
  static List<String> maskList(List<String> phones) {
    return phones.map(maskPhone).toList();
  }

  /// 验证手机号格式（中国大陆）
  ///
  /// 检查是否为有效的 11 位手机号
  static bool isValidPhone(String phone) {
    // 移除非数字字符
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // 如果超过 11 位，取最后 11 位
    if (cleaned.length > 11) {
      cleaned = cleaned.substring(cleaned.length - 11);
    }

    // 中国大陆手机号正则
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(cleaned);
  }

  /// 格式化手机号
  ///
  /// 将手机号格式化为 3-4-4 格式（如 138 1234 5678）
  static String formatPhone(String phone) {
    // 移除非数字字符
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // 如果超过 11 位，取最后 11 位
    if (cleaned.length > 11) {
      cleaned = cleaned.substring(cleaned.length - 11);
    }

    // 如果不足 11 位，直接返回
    if (cleaned.length < 11) {
      return cleaned;
    }

    // 格式化为 3-4-4
    return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 7)} ${cleaned.substring(7)}';
  }

  /// 格式化为 API 请求格式
  ///
  /// 将手机号格式化为 "+86 13800138000"（带空格）用于 API 请求
  static String formatForApi(String phone) {
    // 移除非数字字符
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // 如果超过 11 位，取最后 11 位
    if (cleaned.length > 11) {
      cleaned = cleaned.substring(cleaned.length - 11);
    }

    return '+86 $cleaned';
  }
}

