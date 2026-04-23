import 'package:flutter/material.dart';

/// 文字颜色
///
/// 使用场景：
/// - [primary] 主标题、重要文字
/// - [secondary] 副标题、辅助说明
/// - [hint] 提示文字、占位符
/// - [link] 链接文字
///
/// AI 提示：根据文字重要性选择对应颜色，确保对比度符合 WCAG 标准
class TextColors {
  /// 主标题文字（深灰蓝，WCAG AA 级）
  static const Color primary = Color(0xFF2D3748);

  /// 正文文字（灰蓝，WCAG AA 级）
  static const Color body = Color(0xFF4A5568);

  /// 辅助文字（浅灰，用于次要信息）
  static const Color secondary = Color(0xFF718096);

  /// 提示文字/占位符（中灰）
  static const Color hint = Color(0xFFA0AEC0);

  /// 禁用文字
  static const Color disabled = Color(0xFFCBD5E0);

  /// 链接文字（主色调）
  static const Color link = Color(0xFFFF8C69);

  /// 白色文字（用于深色背景）
  static const Color white = Color(0xFFFFFFFF);

  /// 成功文字（绿色）
  static const Color success = Color(0xFF48BB78);

  /// 错误文字（红色）
  static const Color error = Color(0xFFE53E3E);

  /// 警告文字（橙色）
  static const Color warning = Color(0xFFED8936);

  /// 信息文字（蓝色）
  static const Color info = Color(0xFF4299E1);
}
