import 'package:flutter/material.dart';

class WuxiSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFEE3E41),
    '2号线': Color(0xFF05AA44),
    '3号线': Color(0xFF040BF4),
    '4号线': Color(0xFFB03BA2),
    '5号线': Color(0xFFFFCC00),
    '6号线': Color(0xFFA9A9A9),
    'S1线': Color(0xFFEE2737),
    'S2线': Color(0xFFAD8D44),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null || lineName.isEmpty) return null;
    final sortedEntries = lineColors.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in sortedEntries) {
      if (lineName.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
