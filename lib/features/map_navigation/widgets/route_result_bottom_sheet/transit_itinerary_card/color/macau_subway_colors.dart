import 'package:flutter/material.dart';

class MacauSubwayColors {
  static const Map<String, Color> lineColors = {
    '氹仔线': Color(0xFFA4D65E),
    '石排湾线': Color(0xFF9900FF),
    '横琴线': Color(0xFFD30000),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
