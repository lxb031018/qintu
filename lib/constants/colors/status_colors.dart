import 'package:flutter/material.dart';

/// 状态颜色
///
/// 使用场景：
/// - 徽章、标签、状态指示器、提示框等
///
/// AI 提示：状态颜色应配合对应的背景色使用，确保可读性
class StatusColors {
  // 状态指示色
  /// 成功状态（绿色）
  static const Color success = Color(0xFF48BB78);

  /// 错误状态（红色）
  static const Color error = Color(0xFFE53E3E);

  /// 警告状态（橙色）
  static const Color warning = Color(0xFFED8936);

  /// 信息状态（蓝色）
  static const Color info = Color(0xFF4299E1);

  // 状态背景色（半透明）
  /// 成功状态背景（浅绿）
  static const Color successBg = Color(0xFFF0FFF4);

  /// 错误状态背景（浅红）
  static const Color errorBg = Color(0xFFFFF5F5);

  /// 警告状态背景（浅橙）
  static const Color warningBg = Color(0xFFFFFAF0);

  /// 信息状态背景（浅蓝）
  static const Color infoBg = Color(0xFFEBF8FF);

  // 状态文字色
  /// 成功状态文字（深绿）
  static const Color successText = Color(0xFF2F855A);

  /// 错误状态文字（深红）
  static const Color errorText = Color(0xFFC53030);

  /// 警告状态文字（深橙）
  static const Color warningText = Color(0xFFC05621);

  /// 信息状态文字（深蓝）
  static const Color infoText = Color(0xFF2B6CB0);
}
