import 'package:flutter/material.dart';

/// 背景颜色
///
/// 使用场景：
/// - [pageBg] 页面主背景
/// - [cardBg] 卡片背景
/// - [inputBg] 输入框背景
/// - [overlayBg] 浮层/遮罩背景
///
/// AI 提示：根据组件层级选择合适的背景色
class BackgroundColors {
  /// 页面主背景（奶油白）
  static const Color pageBg = Color(0xFFFFF8F0);

  /// 卡片背景（纯白）
  static const Color cardBg = Color(0xFFFFFFFF);

  /// 输入框背景
  static const Color inputBg = Color(0xFFFFFFFF);

  /// 次要背景（用于分组、区块）
  static const Color secondaryBg = Color(0xFFF7FAFC);

  /// 浮层遮罩背景（半透明黑色 10%）
  static const Color overlayBg = Color(0x1A000000);

  /// 加载状态背景（半透明黑色 20%）
  static const Color loadingBg = Color(0x33000000);

  /// 对话框背景
  static const Color dialogBg = Color(0xFFFFFFFF);

  /// 提示框背景（浅琥珀色）
  static const Color tooltipBg = Color(0xFFFFF8E1);

  /// 底部导航栏背景
  static const Color tabBarBg = Color(0xFFFFFFFF);

  /// 顶部导航栏背景（主色调）
  static const Color appBarBg = Color(0xFFFF8C69);
}
