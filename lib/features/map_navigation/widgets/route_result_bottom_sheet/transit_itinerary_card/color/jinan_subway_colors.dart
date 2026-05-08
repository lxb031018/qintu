import 'package:flutter/material.dart';

class JinanSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFA55FC8),
    '2号线': Color(0xFFFEDD00),
    '3号线': Color(0xFF004B87),
    '4号线': Color(0xFF10883A),
    '5号线': Color(0xFFA9A9A9),
    '6号线': Color(0xFF41B6E6),
    '7号线': Color(0xFFDC241F),
    '8号线': Color(0xFF753BBD),
    '9号线': Color(0xFF888600),
    '高新东区环线': Color(0xFF008AE6),
    '济阳线': Color(0xFF60C1BE),
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
