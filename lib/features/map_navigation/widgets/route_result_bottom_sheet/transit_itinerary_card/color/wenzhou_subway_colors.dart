import 'package:flutter/material.dart';

class WenzhouSubwayColors {
  static const Map<String, Color> lineColors = {
    'S1线': Color(0xFF0061AE),
    'S2线': Color(0xFFDA1F2B),
    'S3线': Color(0xFFFF8C00),
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
