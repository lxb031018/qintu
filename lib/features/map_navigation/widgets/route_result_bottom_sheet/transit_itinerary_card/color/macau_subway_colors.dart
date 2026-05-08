import 'package:flutter/material.dart';

class MacauSubwayColors {
  static const Map<String, Color> lineColors = {
    '氹仔线': Color(0xFFA4D65E),
    '石排湾线': Color(0xFF9900FF),
    '横琴线': Color(0xFFD30000),
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
