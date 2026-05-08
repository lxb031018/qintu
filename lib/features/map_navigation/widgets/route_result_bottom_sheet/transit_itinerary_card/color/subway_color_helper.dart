import 'package:flutter/material.dart';
import 'beijing_subway_colors.dart';
import 'shanghai_subway_colors.dart';
import 'shenzhen_subway_colors.dart';
import 'chengdu_subway_colors.dart';
import 'hangzhou_subway_colors.dart';
import 'nanjing_subway_colors.dart';
import 'wuhan_subway_colors.dart';
import 'xian_subway_colors.dart';
import 'chongqing_subway_colors.dart';
import 'tianjin_subway_colors.dart';
import 'suzhou_subway_colors.dart';
import 'dalian_subway_colors.dart';
import 'nanchang_subway_colors.dart';
import 'harbin_subway_colors.dart';
import 'shenyang_subway_colors.dart';
import 'xiamen_subway_colors.dart';
import 'changsha_subway_colors.dart';
import 'zhengzhou_subway_colors.dart';
import 'kunming_subway_colors.dart';
import 'ningbo_subway_colors.dart';
import 'hefei_subway_colors.dart';
import 'wuxi_subway_colors.dart';
import 'qingdao_subway_colors.dart';
import 'jinan_subway_colors.dart';
import 'guangzhou_subway_colors.dart' as guangzhou;
import 'foshan_subway_colors.dart';
import 'dongguan_subway_colors.dart';
import 'changchun_subway_colors.dart';
import 'taiyuan_subway_colors.dart';
import 'nanning_subway_colors.dart';
import 'kaohsiung_subway_colors.dart';
import 'taipei_subway_colors.dart';
import 'hongkong_subway_colors.dart';
import 'macau_subway_colors.dart';

class SubwayColorHelper {
  static const Map<int, String> _adcodeToHelper = {
    110000: 'beijing',
    310000: 'shanghai',
    440100: 'guangzhou',
    440300: 'shenzhen',
    510100: 'chengdu',
    330100: 'hangzhou',
    320100: 'nanjing',
    420100: 'wuhan',
    610100: 'xian',
    500000: 'chongqing',
    120000: 'tianjin',
    320500: 'suzhou',
    210200: 'dalian',
    360100: 'nanchang',
    230100: 'harbin',
    210100: 'shenyang',
    350200: 'xiamen',
    430100: 'changsha',
    410100: 'zhengzhou',
    530100: 'kunming',
    330200: 'ningbo',
    340100: 'hefei',
    320200: 'wuxi',
    370200: 'qingdao',
    370100: 'jinan',
    350500: 'quanzhou',
    440400: 'zhuhai',
    441900: 'dongguan',
    220100: 'changchun',
    140100: 'taiyuan',
    450100: 'nanning',
    810000: 'hongkong',
    820000: 'macau',
    850000: 'kaohsiung',
    830000: 'taipei',
  };

  static int? toCityLevelAdcode(int? districtAdcode) {
    if (districtAdcode == null) return null;
    return (districtAdcode ~/ 1000) * 1000;
  }

  static Color getSubwayColor(String? lineName, int? cityAdcode, {Color defaultColor = const Color(0xFFFF4D4F)}) {
    if (lineName == null || lineName.isEmpty) return defaultColor;

    final cityLevelAdcode = toCityLevelAdcode(cityAdcode);
    if (cityLevelAdcode != null) {
      final helperName = _adcodeToHelper[cityLevelAdcode];
      if (helperName != null) {
        final color = _getColorFromHelper(helperName, lineName);
        if (color != null) return color;
      }
    }

    return defaultColor;
  }

  static Color? _getColorFromHelper(String helper, String lineName) {
    switch (helper) {
      case 'beijing':
        return BeijingSubwayColors.getColor(lineName);
      case 'shanghai':
        return ShanghaiSubwayColors.getColor(lineName);
      case 'guangzhou':
        return guangzhou.GuangzhouSubwayColors.getColor(lineName);
      case 'shenzhen':
        return ShenzhenSubwayColors.getColor(lineName);
      case 'chengdu':
        return ChengduSubwayColors.getColor(lineName);
      case 'hangzhou':
        return HangzhouSubwayColors.getColor(lineName);
      case 'nanjing':
        return NanjingSubwayColors.getColor(lineName);
      case 'wuhan':
        return WuhanSubwayColors.getColor(lineName);
      case 'xian':
        return XianSubwayColors.getColor(lineName);
      case 'chongqing':
        return ChongqingSubwayColors.getColor(lineName);
      case 'tianjin':
        return TianjinSubwayColors.getColor(lineName);
      case 'suzhou':
        return SuzhouSubwayColors.getColor(lineName);
      case 'dalian':
        return DalianSubwayColors.getColor(lineName);
      case 'nanchang':
        return NanchangSubwayColors.getColor(lineName);
      case 'harbin':
        return HarbinSubwayColors.getColor(lineName);
      case 'shenyang':
        return ShenyangSubwayColors.getColor(lineName);
      case 'xiamen':
        return XiamenSubwayColors.getColor(lineName);
      case 'changsha':
        return ChangshaSubwayColors.getColor(lineName);
      case 'zhengzhou':
        return ZhengzhouSubwayColors.getColor(lineName);
      case 'kunming':
        return KunmingSubwayColors.getColor(lineName);
      case 'ningbo':
        return NingboSubwayColors.getColor(lineName);
      case 'hefei':
        return HefeiSubwayColors.getColor(lineName);
      case 'wuxi':
        return WuxiSubwayColors.getColor(lineName);
      case 'qingdao':
        return QingdaoSubwayColors.getColor(lineName);
      case 'jinan':
        return JinanSubwayColors.getColor(lineName);
      case 'foshan':
        return FoshanSubwayColors.getColor(lineName);
      case 'dongguan':
        return DongguanSubwayColors.getColor(lineName);
      case 'changchun':
        return ChangchunSubwayColors.getColor(lineName);
      case 'taiyuan':
        return TaiyuanSubwayColors.getColor(lineName);
      case 'nanning':
        return NanningSubwayColors.getColor(lineName);
      case 'hongkong':
        return HongkongSubwayColors.getColor(lineName);
      case 'macau':
        return MacauSubwayColors.getColor(lineName);
      case 'kaohsiung':
        return KaohsiungSubwayColors.getColor(lineName);
      case 'taipei':
        return TaipeiSubwayColors.getColor(lineName);
      default:
        return null;
    }
  }
}