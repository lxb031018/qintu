import 'package:flutter/material.dart';

class LijiangSubwayColors {
  static const Map<String, Color> lineColors = {
    '丽江雪山观光火车': Color(0xFF03B5EB),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
