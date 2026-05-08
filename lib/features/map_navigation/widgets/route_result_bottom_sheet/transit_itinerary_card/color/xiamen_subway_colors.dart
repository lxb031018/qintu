import 'package:flutter/material.dart';

class XiamenSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFEC7000),
    '2号线': Color(0xFF4BB134),
    '3号线': Color(0xFF0C89DE),
    '4号线': Color(0xFF3D5295),
    '6号线': Color(0xFFFE8DBA),
    '9号线': Color(0xFFA9A9A9),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
