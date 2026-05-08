import 'package:flutter/material.dart';

class HefeiSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFF50000),
    '2号线': Color(0xFF006BFA),
    '3号线': Color(0xFF098137),
    '4号线': Color(0xFFFF850D),
    '5号线': Color(0xFFC1D522),
    '6号线': Color(0xFFCB95FD),
    '7号线': Color(0xFFFACF10),
    '8号线': Color(0xFF98CDFF),
    '9号线': Color(0xFF008080),
    '10号线': Color(0xFFD8BFD8),
    '11号线': Color(0xFF800080),
    '12号线': Color(0xFFDEB887),
    'S1号线': Color(0xFF33AFAC),
    '东部城区有轨电车': Color(0xFFDAC0F7),
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
