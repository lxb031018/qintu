import 'package:flutter/material.dart';

/// 灰色层级
///
/// 使用场景：
/// - 从浅到深的灰色系统，适用于各种需要灰色的场景
///
/// AI 提示：数值越大颜色越深，根据对比度需求选择合适的灰色
class GreyColors {
  /// 极浅灰（用于次要背景）
  static const Color grey50 = Color(0xFFF7FAFC);

  /// 浅灰（用于分割线）
  static const Color grey100 = Color(0xFFEDF2F7);

  /// 中浅灰（用于禁用状态）
  static const Color grey200 = Color(0xFFE2E8F0);

  /// 中灰（用于次要文字）
  static const Color grey300 = Color(0xFFCBD5E0);

  /// 中深灰（用于辅助文字）
  static const Color grey400 = Color(0xFFA0AEC0);

  /// 深灰（用于正文）
  static const Color grey500 = Color(0xFF718096);

  /// 更深灰（用于标题）
  static const Color grey600 = Color(0xFF4A5568);

  /// 深灰蓝（用于主文字）
  static const Color grey700 = Color(0xFF2D3748);

  /// 极深灰（用于强调文字）
  static const Color grey800 = Color(0xFF1A202C);

  /// 接近黑色
  static const Color grey900 = Color(0xFF171923);
}
