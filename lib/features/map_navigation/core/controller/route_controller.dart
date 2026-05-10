import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/platform_channels.dart';

class RouteController {
  static const _channel = MethodChannel(PlatformChannels.mapControl);

  Future<int?> showRoutes(
    List<Map<String, dynamic>> routes, {
    int selectIndex = 0,
    List<int>? colors,
    List<double>? widths,
    List<bool>? dashedFlags,
  }) async {
    try {
      debugPrint('🗺️ [Flutter] showRoutes 调用:');
      debugPrint('   - 路线数量: ${routes.length}');
      debugPrint('   - 选中索引: $selectIndex');

      final params = <String, dynamic>{
        'routes': routes,
        'selectIndex': selectIndex,
      };
      if (colors != null) params['colors'] = colors;
      if (widths != null) params['widths'] = widths;
      if (dashedFlags != null) params['dashedFlags'] = dashedFlags;

      final result = await _channel.invokeMethod<int>('showRoutes', params);
      debugPrint('🗺️ [Flutter] showRoutes 结果: $result 条路线');
      return result;
    } catch (e) {
      debugPrint('❌ [Flutter] 显示路线失败: $e');
      return null;
    }
  }

  Future<bool> selectRoute(
    int index, {
    int selectedColor = 0xFFFF4D4F,
    int unselectedColor = 0x401890FF,
  }) async {
    try {
      debugPrint('🗺️ [Flutter] selectRoute 调用: index=$index');

      final result = await _channel.invokeMethod<bool>('selectRoute', {
        'index': index,
        'selectedColor': selectedColor,
        'unselectedColor': unselectedColor,
      });

      debugPrint('🗺️ [Flutter] selectRoute 结果: $result');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 选择路线失败: $e');
      return false;
    }
  }

  Future<bool> enterNavigationMode(int routeId) async {
    try {
      final result = await _channel.invokeMethod<bool>('enterNavigationMode', {
        'routeId': routeId,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ enterNavigationMode 失败: $e');
      return false;
    }
  }

  Future<void> clearRoutes() async {
    await _channel.invokeMethod('clearRoutes');
  }

  Future<void> clearRouteOverlays() async {
    await _channel.invokeMethod('clearRouteOverlays');
  }

  Future<int?> showRoutesWithOverlay(List<int> routeIds, {int selectIndex = 0}) async {
    try {
      debugPrint('🗺️ [Flutter] showRoutesWithOverlay: routeIds=${routeIds.length}, selectIndex=$selectIndex');
      final result = await _channel.invokeMethod<int>('showRoutesWithOverlay', {
        'routeIds': routeIds,
        'selectIndex': selectIndex,
      });
      return result;
    } catch (e) {
      debugPrint('❌ [Flutter] showRoutesWithOverlay failed: $e');
      return null;
    }
  }

  Future<bool> highlightRouteOverlay(int routeId) async {
    try {
      debugPrint('🗺️ [Flutter] highlightRouteOverlay: routeId=$routeId');
      final result = await _channel.invokeMethod<bool>('highlightRouteOverlay', {
        'routeId': routeId,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] highlightRouteOverlay failed: $e');
      return false;
    }
  }
}