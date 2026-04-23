// ============================================
// 应用 Widget 样式常量
//
// 统一定义应用中 Widget 使用的样式值
// 包括图标大小、内边距、阴影等
// 确保 UI 一致性
// ============================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppWidgets {
  AppWidgets._();

  // ==================== 图标大小 ====================

  /// 极小图标（14px，用于标签内小图标）
  static const double iconXSmall = 14.0;

  /// 小图标（16px，用于快捷按钮、列表项）
  static const double iconSmall = 16.0;

  /// 中等图标（18px，用于列表项左侧图标）
  static const double iconMedium = 18.0;

  /// 标准图标（20px，用于输入框前缀图标）
  static const double iconNormal = 20.0;

  /// 大图标（24px，用于主要操作按钮）
  static const double iconLarge = 24.0;

  /// 特大图标（48px，用于空状态图标）
  static const double iconXLarge = 48.0;

  // ==================== 输入框样式 ====================

  /// 输入框高度
  static const double inputHeight = 48.0;

  /// 输入框内边距
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 12.0,
  );

  /// 输入框边框颜色
  static const Color inputBorderColor = Color(0xFFE8E8E8);

  /// 输入框圆角
  static const Radius inputBorderRadius = Radius.circular(10);

  // ==================== 卡片样式 ====================

  /// 卡片圆角
  static const Radius cardRadius = Radius.circular(12);

  /// 卡片阴影
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// 卡片内边距
  static const EdgeInsets cardPadding = EdgeInsets.all(12);

  /// 列表卡片外边距
  static const EdgeInsets listCardMargin = EdgeInsets.symmetric(horizontal: 12);

  /// 列表卡片高度（占屏幕比例）
  static const double listCardHeightRatio = 0.6;

  // ==================== 快捷操作按钮 ====================

  /// 快捷操作按钮内边距
  static const EdgeInsets quickActionPadding = EdgeInsets.symmetric(
    horizontal: 10.0,
    vertical: 6.0,
  );

  /// 快捷操作按钮圆角
  static const Radius quickActionRadius = Radius.circular(8);

  // ==================== 列表项样式 ====================

  /// 列表项内边距
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 10.0,
  );

  /// 列表分割线颜色
  static const Color listDividerColor = AppColors.dividerColor;

  // ==================== 选择模式 ====================

  /// 选择指示器大小
  static const double selectionIndicatorSize = 20.0;

  /// 选择模式栏内边距
  static const EdgeInsets selectionBarPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 8.0,
  );

  // ==================== 按钮样式 ====================

  /// 主按钮圆角
  static const Radius buttonRadius = Radius.circular(8);

  /// 主按钮内边距
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 8.0,
  );

  // ==================== 交换按钮 ====================

  /// 交换按钮大小
  static const double swapButtonSize = 24.0;

  /// 交换按钮容器内边距
  static const EdgeInsets swapButtonPadding = EdgeInsets.all(10);
}
