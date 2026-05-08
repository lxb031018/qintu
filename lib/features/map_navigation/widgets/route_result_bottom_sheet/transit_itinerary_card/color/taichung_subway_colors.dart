import 'package:flutter/material.dart';

class TaichungSubwayColors {
  static const Map<String, Color> lineColors = {
    '绿线': Color(0xFF8EC31C),
    '蓝线': Color(0xFF0093DB),
    '橘线': Color(0xFFFCA311),
    '紫线': Color(0xFFCC00CC),
    '红线': Color(0xFFEA0437),
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
