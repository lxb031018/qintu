import 'package:flutter/material.dart';

class UrumqiSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF2980B9),
    '2号线': Color(0xFF27AE60),
    '3号线': Color(0xFFFFC100),
    '4号线': Color(0xFFFF4E52),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
