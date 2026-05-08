import 'package:flutter/material.dart';

class GuiyangSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF259B24),
    '2号线': Color(0xFF283593),
    '3号线': Color(0xFFEE2737),
    '4号线': Color(0xFFA9A9A9),
    'S1号线': Color(0xFFA9A9A9),
    'S2号线': Color(0xFFA9A9A9),
    'S3号线': Color(0xFFA9A9A9),
    'S4号线': Color(0xFFA9A9A9),
    'G1号线': Color(0xFFA9A9A9),
    '贵阳有轨电车T1线': Color(0xFFA9A9A9),
    '贵阳有轨电车T2线': Color(0xFFA9A9A9),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
