import 'package:flutter/material.dart';

class WenshanSubwayColors {
  static const Map<String, Color> lineColors = {
    '普者黑有轨电车4号线': Color(0xFF2367B7),
    '普者黑有轨电车5号线': Color(0xFF53D6E0),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
