import 'package:flutter/material.dart';

class WuxiSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFEE3E41),
    '2号线': Color(0xFF05AA44),
    '3号线': Color(0xFF040BF4),
    '4号线': Color(0xFFB03BA2),
    '5号线': Color(0xFFFFCC00),
    '6号线': Color(0xFFA9A9A9),
    'S1线': Color(0xFFEE2737),
    'S2线': Color(0xFFAD8D44),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
