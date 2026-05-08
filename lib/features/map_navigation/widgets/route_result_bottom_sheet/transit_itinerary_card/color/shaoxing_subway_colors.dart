import 'package:flutter/material.dart';

class ShaoxingSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFC5003E),
    '2号线': Color(0xFF307FE2),
    '4号线': Color(0xFFFD9E6E),
    '5号线': Color(0xFF8B1016),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
