import 'package:flutter/material.dart';

class NingboSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF1590CA),
    '2号线': Color(0xFFD60E19),
    '3号线': Color(0xFFF39800),
    '4号线': Color(0xFFABCD03),
    '5号线': Color(0xFF1D2088),
    '6号线': Color(0xFF800000),
    '7号线': Color(0xFFE00080),
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
