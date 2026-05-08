import 'package:flutter/material.dart';

class ZhengzhouSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFE60012),
    '2号线': Color(0xFFFFF100),
    '3号线': Color(0xFFF39939),
    '4号线': Color(0xFF00A0E9),
    '5号线': Color(0xFF006934),
    '6号线': Color(0xFF920783),
    '7号线': Color(0xFFD6A053),
    '8号线': Color(0xFFE5E289),
    '9号线': Color(0xFFA2AE73),
    '10号线': Color(0xFFBE6254),
    '12号线': Color(0xFF1A60A5),
    '14号线': Color(0xFFB289BC),
    '17号线': Color(0xFF0B4355),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
