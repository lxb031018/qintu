import 'package:flutter/material.dart';

class HongheSubwayColors {
  static const Map<String, Color> lineColors = {
    '红河现代有轨电车': Color(0xFF003573),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
