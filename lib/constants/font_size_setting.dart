library;

/// 字体大小选项配置
/// 为不同用户提供合适的字体大小选择

import 'package:flutter/material.dart';

class FontSizeOption {
  /// 选项名称（用于显示）
  final String label;

  /// 字体大小乘数
  final double scale;

  /// 图标
  final IconData icon;

  const FontSizeOption({
    required this.label,
    required this.scale,
    required this.icon,
  });

  /// 预设字体大小选项
  static const small = FontSizeOption(
    label: '小',
    scale: 0.9,
    icon: Icons.text_fields,
  );

  static const standard = FontSizeOption(
    label: '标准',
    scale: 1.0,
    icon: Icons.text_fields,
  );

  static const large = FontSizeOption(
    label: '大',
    scale: 1.2,
    icon: Icons.text_increase,
  );

  static const extraLarge = FontSizeOption(
    label: '特大',
    scale: 1.4,
    icon: Icons.text_increase,
  );

  /// 所有可选值
  static const List<FontSizeOption> values = [
    small,
    standard,
    large,
    extraLarge,
  ];
}
