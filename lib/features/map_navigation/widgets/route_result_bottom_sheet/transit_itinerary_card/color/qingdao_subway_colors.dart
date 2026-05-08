import 'package:flutter/material.dart';

class QingdaoSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFEAAA00),
    '2号线': Color(0xFFAF272F),
    '3号线': Color(0xFF0057B8),
    '4号线': Color(0xFF007A33),
    '5号线': Color(0xFF981D97),
    '6号线': Color(0xFF6CACE4),
    '7号线': Color(0xFFAD96DC),
    '8号线': Color(0xFFDF1995),
    '9号线': Color(0xFF64A70B),
    '10号线': Color(0xFF844B18),
    '11号线': Color(0xFF304299),
    '12号线': Color(0xFF8246AF),
    '13号线': Color(0xFF00AB84),
    '14号线': Color(0xFFFF585D),
    '15号线': Color(0xFFF2ACB9),
    '16号线': Color(0xFF71DBD4),
    '城阳有轨电车1号线': Color(0xFFC79F62),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
