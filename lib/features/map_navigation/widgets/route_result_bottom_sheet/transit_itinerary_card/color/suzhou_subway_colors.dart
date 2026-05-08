import 'package:flutter/material.dart';

class SuzhouSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF64B735),
    '2号线': Color(0xFFE8374A),
    '3号线': Color(0xFFF18D00),
    '4号线': Color(0xFF006FBA),
    '5号线': Color(0xFFE93CAC),
    '6号线': Color(0xFF21B8ED),
    '7号线': Color(0xFF9D85BD),
    '8号线': Color(0xFFA09200),
    '9号线': Color(0xFFFFCD00),
    '10号线': Color(0xFFAA8066),
    '11号线': Color(0xFF64B735),
    '12号线': Color(0xFFA35C8F),
    '13号线': Color(0xFFF091A0),
    '14号线': Color(0xFF53B5A9),
    '15号线': Color(0xFFFB9968),
    '16号线': Color(0xFF66A9C9),
    '17号线': Color(0xFF468C37),
    '18号线': Color(0xFFC2D047),
    '19号线': Color(0xFFF0A359),
    '20号线': Color(0xFFCAB272),
    '21号线': Color(0xFF98D1C0),
    '高新区有轨电车1号线': Color(0xFFB5CD56),
    '高新区有轨电车2号线': Color(0xFF850000),
    '吴江捷运系统T1线': Color(0xFF0062A8),
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
