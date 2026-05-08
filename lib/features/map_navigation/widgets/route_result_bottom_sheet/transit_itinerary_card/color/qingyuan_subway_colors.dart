import 'package:flutter/material.dart';

class QingyuanSubwayColors {
  static const Map<String, Color> lineColors = {
    '长隆磁浮旅游专线': Color(0xFF0072E6),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
