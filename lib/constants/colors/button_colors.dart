import 'package:flutter/material.dart';

/// 按钮颜色
///
/// 使用场景：
/// - [primaryBg] 主要操作按钮（如"提交"、"确认"、"开始导航"）
/// - [secondaryBg] 次要操作按钮（如"取消"、"返回"）
/// - [successBg] 成功操作按钮（如"保存"、"完成"）
/// - [dangerBg] 危险操作按钮（如"删除"、"退出"）
///
/// AI 提示：根据按钮重要性选择对应颜色，每页最多一个 primary 按钮
class ButtonColors {
  // 主要按钮
  /// 主要按钮背景（珊瑚橙）
  static const Color primaryBg = Color(0xFFFF8C69);

  /// 主要按钮按下状态（深珊瑚橙）
  static const Color primaryPressed = Color(0xFFFF7B5F);

  /// 主要按钮悬停状态（浅珊瑚橙）
  static const Color primaryHover = Color(0xFFFF9F7F);

  /// 主要按钮文字（白色）
  static const Color primaryText = Color(0xFFFFFFFF);

  // 次要按钮
  /// 次要按钮背景（浅灰）
  static const Color secondaryBg = Color(0xFFEDF2F7);

  /// 次要按钮文字（深灰）
  static const Color secondaryText = Color(0xFF2D3748);

  /// 次要按钮边框
  static const Color secondaryBorder = Color(0xFFE2E8F0);

  // 状态按钮
  /// 成功按钮背景（绿色）
  static const Color successBg = Color(0xFF48BB78);

  /// 成功按钮文字
  static const Color successText = Color(0xFFFFFFFF);

  /// 危险按钮背景（红色）
  static const Color dangerBg = Color(0xFFE53E3E);

  /// 危险按钮文字
  static const Color dangerText = Color(0xFFFFFFFF);

  /// 警告按钮背景（橙色）
  static const Color warningBg = Color(0xFFED8936);

  /// 警告按钮文字
  static const Color warningText = Color(0xFFFFFFFF);

  // 禁用状态
  /// 禁用按钮背景
  static const Color disabledBg = Color(0xFFCBD5E0);

  /// 禁用按钮文字
  static const Color disabledText = Color(0xFFA0AEC0);
}
