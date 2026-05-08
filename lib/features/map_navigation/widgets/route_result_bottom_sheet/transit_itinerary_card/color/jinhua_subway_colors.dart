import 'package:flutter/material.dart';

class JinhuaSubwayColors {
  static const Map<String, Color> lineColors = {
    '金义东线': Color(0xFFD8273D),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
