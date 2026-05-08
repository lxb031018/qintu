import 'package:flutter/material.dart';

class NingboSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF1590CA),
    '2号线': Color(0xFFD60E19),
    '3号线': Color(0xFFF39800),
    '4号线': Color(0xFFABCD03),
    '5号线': Color(0xFF1D2088),
    '6号线': Color(0xFF800000),
    '7号线': Color(0xFFE00080),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
