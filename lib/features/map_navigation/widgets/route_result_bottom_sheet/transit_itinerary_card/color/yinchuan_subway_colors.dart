import 'package:flutter/material.dart';

class YinchuanSubwayColors {
  static const Map<String, Color> lineColors = {
    '银川云轨1号线': Color(0xFF252C34),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
