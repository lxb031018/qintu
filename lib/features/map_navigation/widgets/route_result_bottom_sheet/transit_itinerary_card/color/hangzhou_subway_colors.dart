import 'package:flutter/material.dart';

class HangzhouSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFDF4661),
    '2号线': Color(0xFFF1803A),
    '3号线': Color(0xFFFFCD00),
    '4号线': Color(0xFF6CC24A),
    '5号线': Color(0xFF00AEC7),
    '6号线': Color(0xFF0072CE),
    '7号线': Color(0xFF87189D),
    '8号线': Color(0xFFAC145A),
    '9号线': Color(0xFFBE4D00),
    '10号线': Color(0xFFDAAA00),
    '11号线': Color(0xFF007A3E),
    '12号线': Color(0xFF008C95),
    '13号线': Color(0xFF0047BB),
    '14号线': Color(0xFF753BBD),
    '15号线': Color(0xFFF67599),
    '16号线': Color(0xFFFFB25B),
    '17号线': Color(0xFFEFDF00),
    '18号线': Color(0xFF97D700),
    '19号线': Color(0xFF05C3DD),
    '20号线': Color(0xFF6CACE4),
    '21号线': Color(0xFFAC4FC6),
    '杭德城际': Color(0xFFAA8A00),
    '杭海城际': Color(0xFF0077C8),
    '嘉兴有轨电车1号线': Color(0xFFF51200),
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
