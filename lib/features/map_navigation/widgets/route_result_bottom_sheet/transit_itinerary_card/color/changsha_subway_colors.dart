import 'package:flutter/material.dart';

class ChangshaSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFE60012),
    '2号线': Color(0xFF00AFEC),
    '3号线': Color(0xFFABCD03),
    '4号线': Color(0xFF920783),
    '5号线': Color(0xFFFFE200),
    '6号线': Color(0xFF005BAC),
    '7号线': Color(0xFF009036),
    '8号线': Color(0xFFD9027D),
    '9号线': Color(0xFF7A6EAB),
    '10号线': Color(0xFF7BDEDE),
    '11号线': Color(0xFFF19400),
    '12号线': Color(0xFF8E3423),
    '14号线': Color(0xFF085C64),
    '西环线': Color(0xFFDB7093),
    'S1线': Color(0xFF0C3C24),
    'S2线': Color(0xFFF891A5),
    'S3线': Color(0xFFA9A9A9),
    'Y1线': Color(0xFF1CA494),
    '株洲智轨': Color(0xFF0062A8),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
