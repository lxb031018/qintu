import 'package:flutter/material.dart';

class WuhanSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF0067A1),
    '2号线': Color(0xFFEC9CBB),
    '3号线': Color(0xFFD3B466),
    '4号线': Color(0xFFA6D30B),
    '5号线': Color(0xFFA43034),
    '6号线': Color(0xFF007128),
    '7号线': Color(0xFFEB7C16),
    '8号线': Color(0xFF9DABAA),
    '9号线': Color(0xFFA5D4AD),
    '10号线': Color(0xFF8C3626),
    '11号线': Color(0xFFF6D300),
    '12号线': Color(0xFF00A3E9),
    '13号线': Color(0xFF25CAD0),
    '14号线': Color(0xFF825AA3),
    '16号线': Color(0xFFC24C6D),
    '19号线': Color(0xFF469C7F),
    '21号线': Color(0xFFB2007B),
    '车都有轨电车T1线': Color(0xFFB28146),
    '光谷有轨电车L1线': Color(0xFFBAB0D9),
    '光谷有轨电车L2线': Color(0xFFA4D2BD),
    '光谷有轨电车L3线': Color(0xFF4996D8),
    '光谷空轨旅游专线': Color(0xFF38A9E5),
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
