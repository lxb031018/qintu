import 'package:flutter/material.dart';

class ChangchunSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFE50012),
    '2号线': Color(0xFF1A4695),
    '3号线': Color(0xFF009844),
    '4号线': Color(0xFF684184),
    '5号线': Color(0xFFA88546),
    '6号线': Color(0xFFDE949B),
    '7号线': Color(0xFFA95898),
    '8号线': Color(0xFF2CADB1),
    '9号线': Color(0xFF2D79BB),
    '54路': Color(0xFFA9D3AA),
    '55路': Color(0xFFFCB6C0),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
