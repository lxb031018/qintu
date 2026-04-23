import 'package:flutter/material.dart';

/// 列表颜色
///
/// 使用场景：
/// - 地点列表、路线列表、历史记录列表等
///
/// AI 提示：列表项应有明确的分隔和选中状态
class ListColors {
  /// 列表项背景
  static const Color itemBg = Color(0xFFFFFFFF);

  /// 列表项悬停背景
  static const Color itemHover = Color(0xFFF7FAFC);

  /// 列表项分隔线
  static const Color divider = Color(0xFFEDF2F7);

  /// 列表项选中背景（主色调 10% 透明度）
  static const Color selectedBg = Color(0xFFFFF0EB);

  /// 列表项选中边框（主色调）
  static const Color selectedBorder = Color(0xFFFF8C69);

  /// 列表项标题文字
  static const Color titleText = Color(0xFF2D3748);

  /// 列表项副标题文字
  static const Color subtitleText = Color(0xFF718096);

  /// 列表项图标
  static const Color icon = Color(0xFF718096);

  /// 列表项图标（选中）
  static const Color iconActive = Color(0xFFFF8C69);
}
