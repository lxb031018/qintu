import 'package:flutter/material.dart';

class ShijiazhuangSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFE53E30),
    '2号线': Color(0xFFFEC30A),
    '3号线': Color(0xFF00A1E0),
    '4号线': Color(0xFFA9A9A9),
    '5号线': Color(0xFFA9A9A9),
    '6号线': Color(0xFFA9A9A9),
    'S2线': Color(0xFFA9A9A9),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
