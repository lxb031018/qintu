import 'package:flutter/material.dart';

class DongguanSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF3190CB),
    '2号线': Color(0xFFD22730),
    '3号线': Color(0xFFFAA61A),
    '4号线': Color(0xFF00AB4E),
    '松山湖华为有轨电车1号线': Color(0xFFC5001C),
    '松山湖华为有轨电车2号线': Color(0xFF0073AA),
    '松山湖华为有轨电车3号线': Color(0xFF7C4892),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
