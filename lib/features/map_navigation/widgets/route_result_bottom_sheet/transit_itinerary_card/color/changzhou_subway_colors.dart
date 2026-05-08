import 'package:flutter/material.dart';

class ChangzhouSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFCD5C5C),
    '2号线': Color(0xFF529FC9),
    '5号线': Color(0xFFA9A9A9),
    '6号线': Color(0xFFA9A9A9),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
