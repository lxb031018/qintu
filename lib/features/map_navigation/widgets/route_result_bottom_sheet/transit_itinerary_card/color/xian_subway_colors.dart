import 'package:flutter/material.dart';

class XianSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF0077C8),
    '2号线': Color(0xFFEF3340),
    '3号线': Color(0xFFCE70CC),
    '4号线': Color(0xFF2CCCD3),
    '5号线': Color(0xFFA6E35F),
    '6号线': Color(0xFF485CC7),
    '8号线': Color(0xFFDEAE39),
    '9号线': Color(0xFFFF9E1B),
    '10号线': Color(0xFF4AAA94),
    '14号线': Color(0xFF00C1D4),
    '15号线': Color(0xFFCE607E),
    '16号线': Color(0xFFDE8663),
    '西户线': Color(0xFF6C0B74),
    '高新云巴': Color(0xFF4A9AD5),
    '智轨A1线': Color(0xFF0062A8),
    '智轨示范线1号线': Color(0xFF3385FF),
    '昆明池景区观光专线': Color(0xFFA8EDC1),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
