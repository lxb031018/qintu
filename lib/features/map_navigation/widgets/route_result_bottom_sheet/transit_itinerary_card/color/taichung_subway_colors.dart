import 'package:flutter/material.dart';

class TaichungSubwayColors {
  static const Map<String, Color> lineColors = {
    '绿线': Color(0xFF8EC31C),
    '蓝线': Color(0xFF0093DB),
    '橘线': Color(0xFFFCA311),
    '紫线': Color(0xFFCC00CC),
    '红线': Color(0xFFEA0437),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
