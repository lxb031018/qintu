import 'package:flutter/material.dart';

class DalianSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF3AAD2C),
    '2号线': Color(0xFF0082CA),
    '3号线': Color(0xFFE4007F),
    '4号线': Color(0xFF8B3A1C),
    '5号线': Color(0xFFE80028),
    '6号线': Color(0xFFA9A9A9),
    '7号线': Color(0xFFA9A9A9),
    '8号线': Color(0xFFA9A9A9),
    '9号线': Color(0xFFA9A9A9),
    '10号线': Color(0xFFA9A9A9),
    '11号线': Color(0xFFA9A9A9),
    '12号线': Color(0xFF51468A),
    '13号线': Color(0xFFFFD600),
    '有轨电车201路': Color(0xFFFECD0A),
    '有轨电车202路': Color(0xFFB0C95B),
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
