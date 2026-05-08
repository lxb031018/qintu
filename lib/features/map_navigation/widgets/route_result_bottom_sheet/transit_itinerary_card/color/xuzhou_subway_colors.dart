import 'package:flutter/material.dart';

class XuzhouSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFA23337),
    '2号线': Color(0xFFEF8200),
    '3号线': Color(0xFF008BD6),
    '4号线': Color(0xFF6FB92C),
    '5号线': Color(0xFFAE4283),
    '6号线': Color(0xFF541F7F),
    'S1号线': Color(0xFF27D4C1),
    'S3号线': Color(0xFF349BD1),
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
