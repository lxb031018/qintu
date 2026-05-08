import 'package:flutter/material.dart';

class ShenzhenSubwayColors {
  static const Map<String, Color> lineColors = {
    '1号线': Color(0xFF00AB4A),
    '2号线': Color(0xFFB94700),
    '3号线': Color(0xFF00A3DE),
    '4号线': Color(0xFFD1201A),
    '5号线': Color(0xFF924898),
    '6号线': Color(0xFF23B5AD),
    '6号线支线': Color(0xFF00877C),
    '7号线': Color(0xFF003993),
    '8号线': Color(0xFFB94700),
    '8号线原色': Color(0xFFE45DBF),
    '9号线': Color(0xFF87666B),
    '10号线': Color(0xFFEC7091),
    '11号线': Color(0xFF631538),
    '12号线': Color(0xFFA78EAD),
    '13号线': Color(0xFFD38407),
    '14号线': Color(0xFFECCB5B),
    '15号线': Color(0xFF79BB29),
    '16号线': Color(0xFF322288),
    '17号线': Color(0xFFDAC4CC),
    '18号线': Color(0xFF005690),
    '19号线': Color(0xFFA91786),
    '20号线': Color(0xFF88DBDF),
    '21号线': Color(0xFF873320),
    '22号线': Color(0xFFF5E20A),
    '23号线': Color(0xFFBB2C21),
    '24号线': Color(0xFF75A9DB),
    '25号线': Color(0xFFF4A56E),
    '26号线': Color(0xFF968C26),
    '27号线': Color(0xFF508C91),
    '28号线': Color(0xFFE5006A),
    '29号线': Color(0xFF91CDA8),
    '30号线': Color(0xFFB18C76),
    '31号线': Color(0xFF603D75),
    '32号线': Color(0xFF63431E),
    '33号线': Color(0xFF8498B8),
    '龙华有轨电车': Color(0xFFA28F4F),
    '坪山云巴1号线': Color(0xFF1E22AA),
    '宝安国际机场旅客捷运系统': Color(0xFFAB004F),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
