import 'package:flutter/material.dart';

class TaiyuanSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF1B5EAB),
    '2号线': Color(0xFFB31C21),
    '3号线': Color(0xFFA9A9A9),
    'R3线': Color(0xFFA9A9A9),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
