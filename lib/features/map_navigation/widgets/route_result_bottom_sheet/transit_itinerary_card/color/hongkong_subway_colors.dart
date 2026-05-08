import 'package:flutter/material.dart';

class HongkongSubwayColors {
  static const Map<String, Color> lineColors = {
    '东铁线': Color(0xFF53B7E8),
    '屯马线': Color(0xFF923011),
    '观塘线': Color(0xFF00AB4E),
    '荃湾线': Color(0xFFED1C24),
    '港岛线': Color(0xFF007DC5),
    '东涌线': Color(0xFFF7943E),
    '南港岛线': Color(0xFFB5BD00),
    '将军澳线': Color(0xFF7E459B),
    '迪士尼线': Color(0xFFF173AC),
    '机场快线': Color(0xFF00888A),
    '北环线': Color(0xFFA3238E),
    '南港岛线西段': Color(0xFF9182C2),
    '东九龙线': Color(0xFF009758),
    '中铁线': Color(0xFFA9A9A9),
    '修正早期系统': Color(0xFFFF0000),
    '西铁线': Color(0xFFB6008D),
    '九广东铁': Color(0xFF08498E),
    '九广西铁': Color(0xFFA3238F),
    '马鞍山线': Color(0xFF761E10),
    '九广轻铁': Color(0xFFF48933),
    '港岛西至洪水桥铁路': Color(0xFFA9A9A9),
    '轻铁': Color(0xFFD3A809),
    '505线': Color(0xFFDA2128),
    '506P线': Color(0xFF000000),
    '507线': Color(0xFF00A650),
    '507P线': Color(0xFF0CA650),
    '610线': Color(0xFF551B14),
    '614线': Color(0xFF00C0F3),
    '614P线': Color(0xFFF4858D),
    '615线': Color(0xFFFFDD00),
    '615P线': Color(0xFF006684),
    '705线': Color(0xFF72BF44),
    '706线': Color(0xFFB27AB4),
    '751线': Color(0xFFF5821F),
    '751P线': Color(0xFF000000),
    '761P线': Color(0xFF6F2B91),
    '轻铁第1收费区': Color(0xFFF05B7D),
    '轻铁第2收费区': Color(0xFFF7931D),
    '轻铁第3收费区': Color(0xFF0089CF),
    '轻铁第4收费区': Color(0xFF0CB14B),
    '轻铁第5收费区': Color(0xFF7C51A1),
    '轻铁第5A收费区': Color(0xFFF36F21),
    '昂坪360': Color(0xFF94989A),
    '香港电车': Color(0xFF007549),
    '香港国际机场旅客捷运系统': Color(0xFF232F9D),
    '太平山顶缆车': Color(0xFF004C45),
    '高速铁路': Color(0xFF9D948B),
    '深圳地铁网络': Color(0xFFC2C4C6),
  };

  static Color? getColor(String? lineName) {
    if (lineName == null) return null;
    return lineColors[lineName];
  }

  static Color getColorOrDefault(String? lineName, {Color defaultColor = const Color(0xFF1890FF)}) {
    return getColor(lineName) ?? defaultColor;
  }
}
