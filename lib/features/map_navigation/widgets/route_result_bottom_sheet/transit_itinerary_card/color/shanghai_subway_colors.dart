import 'package:flutter/material.dart';

class ShanghaiSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFE3002B),
    '2号线': Color(0xFF82BF25),
    '3号线': Color(0xFFFCD600),
    '4号线': Color(0xFF461D84),
    '5号线': Color(0xFF944D9A),
    '6号线': Color(0xFFD40068),
    '7号线': Color(0xFFFD6F00),
    '8号线': Color(0xFF0094D8),
    '9号线': Color(0xFF87CAED),
    '10号线': Color(0xFFC6AFD4),
    '11号线': Color(0xFF871C2B),
    '12号线': Color(0xFF007A60),
    '13号线': Color(0xFFE999C0),
    '14号线': Color(0xFF626020),
    '15号线': Color(0xFFBCA886),
    '16号线': Color(0xFF98D1C0),
    '17号线': Color(0xFFBC796F),
    '18号线': Color(0xFFC4984F),
    '19号线': Color(0xFFF5AB78),
    '20号线': Color(0xFF009F65),
    '21号线': Color(0xFFF7AF00),
    '22号线': Color(0xFF5F376F),
    '23号线': Color(0xFFB0D478),
    '26号线': Color(0xFF5F67A9),
    '磁浮线': Color(0xFF008B9A),
    '磁浮线2': Color(0xFFF5A74E),
    '浦江线': Color(0xFFB5B5B6),
    '金山线': Color(0xFF000000),
    '机场联络线': Color(0xFF3D6B8A),
    '南汇线': Color(0xFF93ABBB),
    '嘉闵线': Color(0xFF724A57),
    '示范区线': Color(0xFF2E4126),
    '南枫线': Color(0xFF4C6DA9),
    '奉贤线': Color(0xFF898989),
    '沪乍线': Color(0xFF000000),
    '浦南线': Color(0xFF43A5A0),
    '临港捷运系统': Color(0xFF0062A8),
    '浦东国际机场旅客捷运系统东线': Color(0xFFFFA501),
    '浦东国际机场旅客捷运系统西线': Color(0xFF0071C5),
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
