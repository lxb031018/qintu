import 'package:flutter/material.dart';

/// 卡片颜色
///
/// 使用场景：
/// - 信息卡片、路线卡片、地点详情卡片等
///
/// AI 提示：卡片应有明确的边框和阴影以区分层级
class CardColors {
  /// 卡片背景
  static const Color bg = Color(0xFFFFFFFF);

  /// 卡片边框
  static const Color border = Color(0xFFEDF2F7);

  /// 卡片阴影（半透明黑色 5%）
  static const Color shadow = Color(0x0D000000);

  /// 卡片头部背景
  static const Color headerBg = Color(0xFFF7FAFC);

  /// 卡片底部背景
  static const Color footerBg = Color(0xFFF7FAFC);

  /// 卡片选中边框（主色调）
  static const Color selectedBorder = Color(0xFFFF8C69);

  /// 卡片选中背景（主色调 10% 透明度）
  static const Color selectedBg = Color(0xFFFFF0EB);

  /// 卡片错误边框
  static const Color errorBorder = Color(0xFFE53E3E);

  /// 卡片成功边框
  static const Color successBorder = Color(0xFF48BB78);
}
