import 'package:flutter/material.dart';

class ShenyangSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFAF3639),
    '2号线': Color(0xFFF07C52),
    '3号线': Color(0xFFE1679E),
    '4号线': Color(0xFF7A439A),
    '5号线': Color(0xFFA9A9A9),
    '6号线': Color(0xFFFEDC00),
    '7号线': Color(0xFFA9A9A9),
    '8号线': Color(0xFFA9A9A9),
    '9号线': Color(0xFF2A99C5),
    '10号线': Color(0xFF7EB92E),
    '16号线': Color(0xFFA9A9A9),
    'K1快线': Color(0xFFA9A9A9),
    'K2快线': Color(0xFFA9A9A9),
    '浑南有轨电车1号线': Color(0xFFE71F1C),
    '浑南有轨电车2号线': Color(0xFF593C94), // 疑似停运
    '浑南有轨电车3号线': Color(0xFF4AB134),
    '浑南有轨电车4号线': Color(0xFF4AB5E8), // 疑似停运
    '浑南有轨电车5号线': Color(0xFF224B9F),
    '浑南有轨电车6号线': Color(0xFFE7BE28), // 疑似停运
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
