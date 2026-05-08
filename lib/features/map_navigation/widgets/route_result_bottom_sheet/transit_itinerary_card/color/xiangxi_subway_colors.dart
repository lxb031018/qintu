import 'package:flutter/material.dart';

class XiangxiSubwayColors {
  static const Map<String, Color> lineColors = {
    '凤凰磁浮观光快线': Color(0xFF924C32),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
