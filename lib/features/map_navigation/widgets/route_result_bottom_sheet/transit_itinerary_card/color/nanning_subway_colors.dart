import 'package:flutter/material.dart';

class NanningSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF00B04F),
    '2号线': Color(0xFFEB3D1A),
    '3号线': Color(0xFF571887),
    '4号线': Color(0xFFDAE600),
    '5号线': Color(0xFF0057A3),
    '6号线': Color(0xFFF27D00),
    '7号线': Color(0xFF945A41),
    '8号线': Color(0xFF10B3B0),
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
