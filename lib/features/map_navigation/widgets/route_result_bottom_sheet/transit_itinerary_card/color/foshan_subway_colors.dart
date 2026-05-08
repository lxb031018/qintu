import 'package:flutter/material.dart';

class FoshanSubwayColors {
  static const Map<String, Color> lineColors = {
    '2号线': Color(0xFFEA2628),
    '3号线': Color(0xFF002F87),
    '4号线': Color(0xFF923A7F),
    '5号线': Color(0xFF0EAB4A),
    '6号线': Color(0xFFFFB81D),
    '9号线': Color(0xFFA25EB5),
    '11号线': Color(0xFF035C67),
    '13号线': Color(0xFF32B7EA),
    '南海有轨电车1号线': Color(0xFF60B4E3),
    '南海有轨电车2号线': Color(0xFF8CC63F),
    '高明有轨电车': Color(0xFF5AAB82),
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
