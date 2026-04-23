import 'package:flutter/material.dart';

/// 导航颜色
///
/// 使用场景：
/// - 顶部导航栏、底部导航栏、地图路线、位置标记等
///
/// AI 提示：地图导航应用的核心颜色，保持视觉一致性
class NavigationColors {
  // 底部导航栏
  /// 底部导航栏背景
  static const Color tabBarBg = Color(0xFFFFFFFF);

  /// 底部导航图标（默认）
  static const Color tabIcon = Color(0xFF718096);

  /// 底部导航图标（选中）
  static const Color tabIconActive = Color(0xFFFF8C69);

  /// 底部导航文字（默认）
  static const Color tabText = Color(0xFF718096);

  /// 底部导航文字（选中）
  static const Color tabTextActive = Color(0xFFFF8C69);

  /// 底部导航指示器颜色
  static const Color tabIndicator = Color(0xFFFF8C69);

  // 顶部导航栏
  /// 顶部导航栏背景（主色调）
  static const Color appBarBg = Color(0xFFFF8C69);

  /// 顶部导航栏文字（白色）
  static const Color appBarText = Color(0xFFFFFFFF);

  /// 顶部导航栏图标（白色）
  static const Color appBarIcon = Color(0xFFFFFFFF);

  // 地图导航
  /// 路线颜色（蓝色）
  static const Color routeLine = Color(0xFF4299E1);

  /// 当前位置标记（主色调）
  static const Color locationMarker = Color(0xFFFF8C69);

  /// 目的地标记（红色）
  static const Color destinationMarker = Color(0xFFE53E3E);

  /// 途经点标记（绿色）
  static const Color waypointMarker = Color(0xFF48BB78);

  /// 地图标注背景
  static const Color mapLabelBg = Color(0xFFFFFFFF);

  /// 地图标注文字
  static const Color mapLabelText = Color(0xFF2D3748);
}
