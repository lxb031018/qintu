import 'package:flutter/services.dart';
import 'package:qintu/core/constants/platform_channels.dart';
import 'package:qintu/utils/logger.dart';
import '../../models/poi_models.dart';

/// 高德 POI 搜索桥接层
///
/// 通过 Platform Channel 调用 Android 原生 PoiSearchV2 SDK 和 Inputtips
class PoiSearchBridge {
  static const _channel = MethodChannel(PlatformChannels.poiSearch);

  /// 输入提示（模糊匹配）
  ///
  /// [keyword] 搜索关键词
  /// [city] 限定城市（可选，null 表示全国）
  /// [lat]/[lng] 中心点坐标（可选）
  static Future<List<PoiSuggestion>> inputTips({
    required String keyword,
    String? city,
    double? lat,
    double? lng,
  }) async {
    try {
      Logs.ui.info('🔍 原生输入提示: $keyword, city=$city');
      final result = await _channel.invokeMapMethod('inputTips', {
        'keyword': keyword,
        'city': city,
        'lat': lat,
        'lng': lng,
      });

      if (result == null) return [];

      final tips = result['tips'] as List<dynamic>? ?? [];
      final suggestions = tips
          .map((t) => PoiSuggestion.fromTip(Map<String, dynamic>.from(t as Map)))
          .toList();

      Logs.ui.info('✅ 原生输入提示成功: ${suggestions.length}条结果');
      return suggestions;
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 原生输入提示失败: ${e.message}');
      return [];
    } catch (e) {
      Logs.ui.warning('❌ 原生输入提示异常: $e');
      return [];
    }
  }

  /// 关键词 POI 搜索
  ///
  /// [keyword] 搜索关键词
  /// [city] 限定城市（可选，null 表示全国）
  /// [lat]/[lng] 搜索中心点坐标（可选）
  /// [radius] 搜索半径（米），默认 50000
  /// [cityLimit] 是否仅在指定城市搜索
  static Future<PoiSearchResult> searchPoi({
    required String keyword,
    String? city,
    double? lat,
    double? lng,
    int radius = 50000,
    bool cityLimit = false,
  }) async {
    try {
      Logs.ui.info('🔍 原生POI搜索: $keyword, city=$city');
      final result = await _channel.invokeMapMethod('searchPoi', {
        'keyword': keyword,
        'city': city,
        'lat': lat,
        'lng': lng,
        'radius': radius,
        'cityLimit': cityLimit,
      });

      if (result == null) {
        return PoiSearchResult(errorCode: 1806, errorMessage: '搜索返回为空');
      }

      final pois = result['pois'] as List<dynamic>? ?? [];
      final suggestions = pois
          .map((p) => PoiSuggestion.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList();

      Logs.ui.info('✅ 原生POI搜索成功: ${suggestions.length}条结果');
      return PoiSearchResult(suggestions: suggestions);
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 原生POI搜索失败: ${e.message}');
      return PoiSearchResult(errorCode: 1806, errorMessage: e.message);
    } catch (e) {
      Logs.ui.warning('❌ 原生POI搜索异常: $e');
      return PoiSearchResult(errorCode: 1203, errorMessage: e.toString());
    }
  }
}
