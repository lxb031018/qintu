import 'package:flutter/material.dart';

class ChengduSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF28286E),
    '2号线': Color(0xFFEB5A35),
    '3号线': Color(0xFFD5006A),
    '4号线': Color(0xFF00AA58),
    '5号线': Color(0xFFA23E92),
    '6号线': Color(0xFFB96F1D),
    '7号线': Color(0xFF6DC6D6),
    '8号线': Color(0xFF98C51A),
    '9号线': Color(0xFFE9AE00),
    '10号线': Color(0xFF0050A3),
    '11号线': Color(0xFF8C7732),
    '12号线': Color(0xFF772583),
    '13号线': Color(0xFFC5A900),
    '14号线': Color(0xFF80E0A7),
    '15号线': Color(0xFFDFA0C9),
    '16号线': Color(0xFF0085CA),
    '17号线': Color(0xFF8BCAA0),
    '18号线': Color(0xFF006268),
    '19号线': Color(0xFF93A0FE),
    '20号线': Color(0xFFB86125),
    '21号线': Color(0xFFFFC27B),
    '22号线': Color(0xFF6AD1E3),
    '23号线': Color(0xFFE183D1),
    '26号线': Color(0xFF43B02A),
    '27号线': Color(0xFF0097CE),
    '28号线': Color(0xFF9678D3),
    '29号线': Color(0xFF598AD9),
    '30号线': Color(0xFFF67599),
    '32号线': Color(0xFF023BA8),
    '33号线': Color(0xFF8ED365),
    'S1线': Color(0xFFB0D590),
    'S2线': Color(0xFFCD89DC),
    'S3线': Color(0xFF9D9D9E),
    'S4线': Color(0xFF92C21E),
    'S5线': Color(0xFFA7C6ED),
    'S6线': Color(0xFF641E88),
    'S7线': Color(0xFF30895F),
    'S8线': Color(0xFF3073A9),
    'S9线': Color(0xFF09923B),
    'S10线': Color(0xFF96D50B),
    'S11线': Color(0xFF737B4C),
    'S12线': Color(0xFF112B88),
    'S13线': Color(0xFF9E652E),
    'S14线': Color(0xFFBABA1C),
    'S15线': Color(0xFF01B0F1),
    'S16线': Color(0xFFFA7E16),
    'S17线': Color(0xFF1C896A),
    'S18线': Color(0xFF16BADA),
    'S19线': Color(0xFF651D6A),
    'D1线': Color(0xFF0237FF),
    'D2线': Color(0xFFF39C01),
    'D3线': Color(0xFF7E7EF8),
    'D4线': Color(0xFF847129),
    'D5线': Color(0xFFFE807E),
    'D6线': Color(0xFFEB8762),
    '蓉1号线': Color(0xFFFF671F),
    '蓉2号线': Color(0xFF6A911A),
    '天府国际机场旅客捷运系统': Color(0xFFF78921),
    '都江堰M-TR旅游客运专线1': Color(0xFF5A9ED9),
    '都江堰M-TR旅游客运专线2': Color(0xFF8FCF50),
    '安仁古镇有轨电车': Color(0xFF061C68),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
