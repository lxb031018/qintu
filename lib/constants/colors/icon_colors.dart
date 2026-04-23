import 'package:flutter/material.dart';

/// 图标颜色
///
/// 使用场景：
/// - 导航图标、操作图标、装饰图标等
///
/// AI 提示：图标颜色应与当前状态和用途匹配
class IconColors {
  /// 默认图标颜色（中灰）
  static const Color default_ = Color(0xFF718096);

  /// 激活/选中图标颜色（主色调）
  static const Color active = Color(0xFFFF8C69);

  /// 禁用图标颜色
  static const Color disabled = Color(0xFFCBD5E0);

  /// 导航图标颜色（主色调）
  static const Color navigation = Color(0xFFFF8C69);

  /// 操作图标颜色（蓝色）
  static const Color action = Color(0xFF4299E1);

  /// 装饰图标颜色（浅灰）
  static const Color decorative = Color(0xFFA0AEC0);

  /// 成功图标颜色（绿色）
  static const Color success = Color(0xFF48BB78);

  /// 错误图标颜色（红色）
  static const Color error = Color(0xFFE53E3E);

  /// 警告图标颜色（橙色）
  static const Color warning = Color(0xFFED8936);

  /// 信息图标颜色（蓝色）
  static const Color info = Color(0xFF4299E1);

  /// 白色图标（用于深色背景）
  static const Color white = Color(0xFFFFFFFF);
}
