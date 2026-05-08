import 'package:flutter/material.dart';

class TaiyuanSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF1B5EAB),
    '2号线': Color(0xFFB31C21),
    '3号线': Color(0xFFA9A9A9),
    'R3线': Color(0xFFA9A9A9),
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
