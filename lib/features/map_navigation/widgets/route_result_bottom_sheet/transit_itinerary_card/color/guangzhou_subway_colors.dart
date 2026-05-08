import 'package:flutter/material.dart';

class GuangzhouSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFFF3D03E),
    '2号线': Color(0xFF00629B),
    '3号线': Color(0xFFECA154),
    '4号线': Color(0xFF00843D),
    '5号线': Color(0xFFC5003E),
    '6号线': Color(0xFF80225F),
    '7号线': Color(0xFF87D300),
    '8号线': Color(0xFF008193),
    '9号线': Color(0xFF5EC998),
    '10号线': Color(0xFF7389B2),
    '11号线': Color(0xFFFFB00A),
    '12号线': Color(0xFF435428),
    '13号线': Color(0xFF8E8C13),
    '14号线': Color(0xFF792720),
    '15号线': Color(0xFFAE8A79),
    '16号线': Color(0xFF9E652E),
    '17号线': Color(0xFF8B84D7),
    '18号线': Color(0xFF3040B6),
    '19号线': Color(0xFFBB29BB),
    '20号线': Color(0xFFD60078),
    '21号线': Color(0xFF1D1157),
    '22号线': Color(0xFFCF5125),
    '23号线': Color(0xFFA98B00),
    '24号线': Color(0xFF20ACAC),
    '26号线': Color(0xFFBBB3D8),
    '27号线': Color(0xFF8CC9A6),
    '28号线': Color(0xFFE378AC),
    '32号线': Color(0xFFBFD427),
    '37号线': Color(0xFFA9A9A9),
    '广佛线': Color(0xFFC4D600),
    'APM线': Color(0xFF00B5E6),
    '海珠有轨电车1号线': Color(0xFF6BB23C),
    '黄埔有轨电车1号线': Color(0xFFAD2C26),
    '黄埔有轨电车2号线': Color(0xFFD9017A),
    '黄埔有轨电车5号线': Color(0xFF007800),
    '佛山地铁网络': Color(0xFF565656),
    '广东城际网络': Color(0xFF255AA8),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
