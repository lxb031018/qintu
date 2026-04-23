import 'package:flutter/material.dart';

/// 浮层颜色
///
/// 使用场景：
/// - 对话框、弹窗、提示框、加载遮罩等
///
/// AI 提示：浮层应有明确的遮罩背景以区分层级
class OverlayColors {
  /// 对话框背景
  static const Color dialogBg = Color(0xFFFFFFFF);

  /// 遮罩背景（半透明黑色 10%）
  static const Color backdrop = Color(0x1A000000);

  /// 提示框背景（深色）
  static const Color tooltipBg = Color(0xFF1A202C);

  /// 提示框文字（白色）
  static const Color tooltipText = Color(0xFFFFFFFF);

  /// 加载遮罩背景（半透明黑色 20%）
  static const Color loadingBg = Color(0x33000000);

  /// 下拉菜单背景
  static const Color menuBg = Color(0xFFFFFFFF);

  /// 下拉菜单项悬停背景
  static const Color menuHover = Color(0xFFF7FAFC);

  /// 侧边栏背景
  static const Color drawerBg = Color(0xFFFFFFFF);

  /// 底部弹出面板背景
  static const Color panelBg = Color(0xFFFFFFFF);
}
