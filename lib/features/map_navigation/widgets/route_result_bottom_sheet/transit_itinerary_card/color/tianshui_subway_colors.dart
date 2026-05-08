import 'package:flutter/material.dart';

class TianshuiSubwayColors {
  static const Map<String, Color> lineColors = {
    '天水有轨电车1号线': Color(0xFFFBC23D),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
