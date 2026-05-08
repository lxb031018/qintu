import 'package:flutter/material.dart';

class NanchangSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFE6212A),
    '2号线': Color(0xFFFFD700),
    '3号线': Color(0xFF1E88E5),
    '4号线': Color(0xFF009944),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
