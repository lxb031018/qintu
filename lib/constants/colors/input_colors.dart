import 'package:flutter/material.dart';

/// 输入框颜色
///
/// 使用场景：
/// - 搜索框、表单输入、地址输入等
///
/// AI 提示：根据输入框状态选择对应颜色
class InputColors {
  /// 输入框背景
  static const Color bg = Color(0xFFFFFFFF);

  /// 输入框禁用背景
  static const Color bgDisabled = Color(0xFFF7FAFC);

  /// 输入框边框（默认）
  static const Color border = Color(0xFFE2E8F0);

  /// 输入框边框（聚焦/激活）
  static const Color borderFocus = Color(0xFFFF8C69);

  /// 输入框边框（错误状态）
  static const Color borderError = Color(0xFFE53E3E);

  /// 输入框文字
  static const Color text = Color(0xFF4A5568);

  /// 输入框提示文字/占位符
  static const Color hint = Color(0xFFA0AEC0);

  /// 输入框图标（默认）
  static const Color icon = Color(0xFF718096);

  /// 输入框图标（聚焦）
  static const Color iconFocus = Color(0xFFFF8C69);

  /// 输入框图标（错误）
  static const Color iconError = Color(0xFFE53E3E);

  /// 输入框标签文字
  static const Color label = Color(0xFF2D3748);

  /// 错误提示文字
  static const Color errorText = Color(0xFFE53E3E);
}
