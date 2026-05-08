import 'package:flutter/material.dart';

class YanchengSubwayColors {
  static const Map<String, Color> lineColors = {
    'SRT1号线': Color(0xFF0062A8),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
