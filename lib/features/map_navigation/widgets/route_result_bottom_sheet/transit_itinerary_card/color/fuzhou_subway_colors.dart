import 'package:flutter/material.dart';

class FuzhouSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFCB333B),
    '2号线': Color(0xFF286140),
    '3号线': Color(0xFF766CB1),
    '4号线': Color(0xFFFF7F41),
    '5号线': Color(0xFF893B67),
    '6号线': Color(0xFF005EB8),
    '7号线': Color(0xFFA9A9A9),
    '8号线': Color(0xFFD6A461),
    '9号线': Color(0xFFA9A9A9),
    '10号线': Color(0xFFA9A9A9),
    '11号线': Color(0xFFA9A9A9),
    '13号线': Color(0xFFA9A9A9),
    'S1线': Color(0xFFB04A5A),
    'S2线': Color(0xFFA9A9A9),
    'S3线': Color(0xFFA9A9A9),
    '滨海快线': Color(0xFF00ADBB),
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
