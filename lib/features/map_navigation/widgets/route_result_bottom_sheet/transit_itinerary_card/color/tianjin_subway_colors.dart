import 'package:flutter/material.dart';

class TianjinSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFCB333B),
    '2号线': Color(0xFFE1E000),
    '3号线': Color(0xFF00ACD0),
    '4号线': Color(0xFF007A33),
    '5号线': Color(0xFFDE6D10),
    '6号线': Color(0xFF994878),
    '7号线': Color(0xFFC6893F),
    '8号线': Color(0xFF714993),
    '9号线': Color(0xFF0047BB),
    '10号线': Color(0xFFC4D600),
    '11号线': Color(0xFF002D72),
    '12号线': Color(0xFFF99FC9),
    '13号线': Color(0xFFFFC845),
    '14号线': Color(0xFF99D6EA),
    '15号线': Color(0xFF6ECEB2),
    'B1线': Color(0xFFE03E52),
    'B2线': Color(0xFFF3EA5D),
    'B3线': Color(0xFF2DCCD3),
    'B4线': Color(0xFF6CC24A),
    'B5线': Color(0xFFFEAD77),
    'B6线': Color(0xFFB06C96),
    'B7线': Color(0xFFB9975B),
    'Z1线': Color(0xFF8B84D7),
    'Z2线': Color(0xFF006BA6),
    'Z4线': Color(0xFFA57FB2),
    '津静线': Color(0xFFF8B5C4),
    '津宁线': Color(0xFFDECD63),
    '津武线': Color(0xFFFFC72C),
    '津港线': Color(0xFF4A412A),
    '宁武线': Color(0xFFFDAA63),
    '双湖线': Color(0xFFC66E4E),
    '导轨1号线': Color(0xFF8FC31F),
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
