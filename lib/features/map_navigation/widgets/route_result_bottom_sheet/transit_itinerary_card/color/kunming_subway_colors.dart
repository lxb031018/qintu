import 'package:flutter/material.dart';

class KunmingSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFDB372B),
    '2号线': Color(0xFF296DB4),
    '3号线': Color(0xFFFE4998),
    '4号线': Color(0xFFFFCD12),
    '5号线': Color(0xFF00B700),
    '6号线': Color(0xFF0290A4),
    '7号线': Color(0xFFFFE400),
    '8号线': Color(0xFFABF200),
    '9号线': Color(0xFF00D8FF),
    '长水国际机场旅客捷运系统': Color(0xFF645189),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
