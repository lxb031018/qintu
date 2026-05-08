import 'package:flutter/material.dart';

class NewTaipeiSubwayColors {
  static const Map<String, Color> lineColors = {
    '环状线': Color(0xFFFFD500),
    '三莺线': Color(0xFF79BCE8),
    '淡海轻轨': Color(0xFFE5554F),
    '八里轻轨': Color(0xFFE5554F),
    '安坑轻轨': Color(0xFFC3B091),
    '深坑轻轨': Color(0xFFCC7722),
    '五股泰山板桥轻轨': Color(0xFFE5007F),
    '林口轻轨': Color(0xFFF6C2D8),
    '中和光复线': Color(0xFFF6C2D8),
    '汐东捷运': Color(0xFF1E90FF),
    '基隆捷运': Color(0xFF1E90FF),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
