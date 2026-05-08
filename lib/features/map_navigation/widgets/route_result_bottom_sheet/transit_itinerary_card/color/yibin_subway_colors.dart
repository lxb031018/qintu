import 'package:flutter/material.dart';

class YibinSubwayColors {
  static const Map<String, Color> lineColors = {
    '智轨T1线': Color(0xFF116CB1),
    '智轨T2线': Color(0xFFFF7E26),
    '智轨T4线': Color(0xFF24B14D),
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
