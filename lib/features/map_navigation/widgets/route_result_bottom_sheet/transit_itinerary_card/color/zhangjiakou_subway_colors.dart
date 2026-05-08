import 'package:flutter/material.dart';

class ZhangjiakouSubwayColors {
  static const Map<String, Color> lineColors = {
    '太子城冰雪小镇有轨电车': Color(0xFFA51E25),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
