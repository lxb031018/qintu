import 'package:flutter/material.dart';

class NanjingSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF009ACE),
    '2号线': Color(0xFFA6093D),
    '3号线': Color(0xFF009A44),
    '4号线': Color(0xFF7D55C7),
    '5号线': Color(0xFFF2DA51),
    '6号线': Color(0xFF4BBBB4),
    '7号线': Color(0xFF4A7729),
    '9号线': Color(0xFFFA4616),
    '10号线': Color(0xFFB9975B),
    '11号线': Color(0xFFEF426F),
    'S1号线': Color(0xFF4BBBB4),
    'S2号线': Color(0xFF93282C),
    'S3号线': Color(0xFFBA84AC),
    'S4号线': Color(0xFFFF631B),
    'S5号线': Color(0xFFF2DF67),
    'S6号线': Color(0xFFC98BDB),
    'S7号线': Color(0xFFB46B7A),
    'S8号线': Color(0xFFFF8000),
    'S9号线': Color(0xFFFFC600),
    '河西有轨电车': Color(0xFF00A199),
    '麒麟有轨电车': Color(0xFF0DAC67),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
