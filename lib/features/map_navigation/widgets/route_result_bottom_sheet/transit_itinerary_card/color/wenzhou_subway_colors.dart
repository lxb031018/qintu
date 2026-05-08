import 'package:flutter/material.dart';

class WenzhouSubwayColors {
  static const Map<String, Color> lineColors = {
    'S1线': Color(0xFF0061AE),
    'S2线': Color(0xFFDA1F2B),
    'S3线': Color(0xFFFF8C00),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
