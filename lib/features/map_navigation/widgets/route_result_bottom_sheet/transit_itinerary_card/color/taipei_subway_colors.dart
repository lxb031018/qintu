import 'package:flutter/material.dart';

class TaipeiSubwayColors {
  static const Map<String, Color> lineColors = {
    '文湖线': Color(0xFFC48C31),
    '淡水信义线': Color(0xFFE3002C),
    '松山新店线': Color(0xFF008659),
    '中和新芦线': Color(0xFFF8B61C),
    '板南线': Color(0xFF0070BD),
    '环状线': Color(0xFFFEDB00),
    '万大中和树林线': Color(0xFFA1D884),
    '新北投支线': Color(0xFFFD92A3),
    '小碧潭支线': Color(0xFFCFDB00),
    '民生汐止线': Color(0xFF25AAE1),
    '东湖支线': Color(0xFF283991),
    '社子线': Color(0xFFE40078),
    '猫空缆车': Color(0xFF77BC1F),
    '淡海轻轨': Color(0xFFFABEB5),
    '安坑轻轨': Color(0xFFD8D0BA),
    '桃园机场捷运': Color(0xFFD0C6E2),
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
