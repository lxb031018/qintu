import 'package:flutter/material.dart';

class TaoyuanSubwayColors {
  static const Map<String, Color> lineColors = {
    '桃园机场捷运': Color(0xFF8246AF),
    '绿线': Color(0xFF62A033),
    '绿线延伸中坜': Color(0xFF006A40),
    '橘线': Color(0xFFFFA500),
    '棕线': Color(0xFF824729),
    '三莺线延伸八德': Color(0xFF00559E),
    '台铁': Color(0xFF020281),
    '台湾高铁': Color(0xFFDB5426),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
