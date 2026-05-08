import 'package:flutter/material.dart';

class KaohsiungSubwayColors {
  static const Map<String, Color> lineColors = {
    '红线': Color(0xFFE20B65),
    '橘线': Color(0xFFFAA73F),
    '环状轻轨': Color(0xFF7CBD52),
    '银线': Color(0xFF929292),
    '蓝线': Color(0xFF007FFF),
    '青线': Color(0xFF00BFFF),
    '佛光山线': Color(0xFFAA34C0),
    '紫线': Color(0xFFC100FF),
    '右昌线': Color(0xFF008583),
    '粉红线': Color(0xFFFFC0CB),
    '台湾铁路': Color(0xFF0008BD),
    '高铁': Color(0xFFC56953),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
