import 'package:flutter/material.dart';

class SanyaSubwayColors {
  static const Map<String, Color> lineColors = {
    '三亚有轨电车1号线': Color(0xFF0012E0),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
