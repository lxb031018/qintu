import 'package:flutter/material.dart';

/// 分割线颜色
///
/// 使用场景：
/// - 区块分隔、列表项分隔、表单分隔等
///
/// AI 提示：根据分隔的重要性选择对应粗细的分割线
class DividerColors {
  /// 浅色分割线（用于列表项分隔）
  static const Color light = Color(0xFFEDF2F7);

  /// 中等分割线（用于区块分隔）
  static const Color medium = Color(0xFFE2E8F0);

  /// 深色分割线（用于重要分隔）
  static const Color dark = Color(0xFFCBD5E0);

  /// 章节分割线
  static const Color section = Color(0xFFE2E8F0);

  /// 列表项分割线
  static const Color item = Color(0xFFEDF2F7);

  /// 表单分割线
  static const Color form = Color(0xFFE2E8F0);
}
