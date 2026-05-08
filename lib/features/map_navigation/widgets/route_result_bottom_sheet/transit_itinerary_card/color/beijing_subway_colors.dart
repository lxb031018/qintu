import 'package:flutter/material.dart';

class BeijingSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFC23A30),
    '2号线': Color(0xFF006098),
    '3号线': Color(0xFFE60033),
    '4号线': Color(0xFF008E9C),
    '5号线': Color(0xFFA6217F),
    '6号线': Color(0xFFD29700),
    '7号线': Color(0xFFFAC671),
    '8号线': Color(0xFF009B6B),
    '9号线': Color(0xFF8FC31F),
    '10号线': Color(0xFF009BC0),
    '11号线': Color(0xFFED796B),
    '12号线': Color(0xFFC76B00),
    '13号线': Color(0xFFF9E700),
    '14号线': Color(0xFFD5A7A1),
    '15号线': Color(0xFF6A357D),
    '16号线': Color(0xFF76A32D),
    '17号线': Color(0xFF00A9A9),
    '18号线': Color(0xFF5654A2),
    '19号线': Color(0xFFD6ABC1),
    '20号线': Color(0xFF21788C),
    '21号线': Color(0xFFA8FFD7),
    '22号线': Color(0xFFF7C8CE),
    '25号线': Color(0xFFE46022),
    '28号线': Color(0xFF35570B),
    'S1线': Color(0xFFB25921),
    '亦庄线': Color(0xFFE40077),
    '房山线': Color(0xFFE46022),
    '燕房线': Color(0xFFE46022),
    '昌平线': Color(0xFFDE82B2),
    '西郊线': Color(0xFFE60B1C),
    '亦庄T1线': Color(0xFFD22630),
    '首都机场线': Color(0xFFA29BBB),
    '大兴机场线': Color(0xFF004BA0),
    '首都国际机场旅客捷运系统': Color(0xFF7E74EF),
    '前门大街有轨电车': Color(0xFF330000),
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
