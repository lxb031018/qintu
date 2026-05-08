import 'package:flutter/material.dart';

class HohhotSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFFF0000),
    '2号线': Color(0xFF0066CC),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
