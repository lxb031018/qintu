import 'package:flutter/material.dart';

class ChongqingSubwayColors {
  static const Map<String, Color> lineColors = {
    '环线': Color(0xFFF2A900),
    '1号线': Color(0xFFE4002B),
    '2号线': Color(0xFF007A33),
    '3号线': Color(0xFF003DA5),
    '4号线': Color(0xFFDC8633),
    '5号线': Color(0xFF00A3E0),
    '6号线': Color(0xFFF67599),
    '7号线': Color(0xFF008C95),
    '8号线': Color(0xFF7A9A01),
    '9号线': Color(0xFF861F41),
    '10号线': Color(0xFF5F259F),
    '11号线': Color(0xFFD986BA),
    '12号线': Color(0xFFD2D755),
    '13号线': Color(0xFFB89D18),
    '14号线': Color(0xFFB94700),
    '15号线': Color(0xFF0057B8),
    '16号线': Color(0xFFB04A5A),
    '17号线': Color(0xFF9F5CC0),
    '18号线': Color(0xFF2CD5C4),
    '19号线': Color(0xFFBC204B),
    '20号线': Color(0xFFE31C79),
    '21号线': Color(0xFF309B42),
    '22号线': Color(0xFF2F6F7A),
    '23号线': Color(0xFF93C90F),
    '24号线': Color(0xFFDC9F42),
    '25号线': Color(0xFF8A75D1),
    '26号线': Color(0xFF00C389),
    '27号线': Color(0xFF685BC7),
    '28号线': Color(0xFF007398),
    '29号线': Color(0xFFFF585D),
    '直快列车': Color(0xFFC16C18),
    '10号线快车': Color(0xFF3C1B5D),
    '空港线': Color(0xFF003DA5),
    '国博线': Color(0xFFF67599),
    '江跳线': Color(0xFF0077C8),
    '璧铜线': Color(0xFF685BC7),
    '永川线': Color(0xFF0057B8),
    '江北国际机场单轨捷运系统': Color(0xFF4683EC),
    '璧山云巴': Color(0xFF0062A8),
    '长江索道': Color(0xFFAA9500),
    '长寿缆车': Color(0xFF252C34),
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
