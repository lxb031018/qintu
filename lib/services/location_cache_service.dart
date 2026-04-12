import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../utils/date_utils.dart';

/// 位置缓存服务 - 缓存用户上次的位置信息

class LocationCacheService {
  static const String _cacheLatKey = 'location_cache_latitude';
  static const String _cacheLngKey = 'location_cache_longitude';
  static const String _cacheTimeKey = 'location_cache_timestamp';

  /// 保存位置到缓存
  static Future<void> saveLocation(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_cacheLatKey, latitude);
      await prefs.setDouble(_cacheLngKey, longitude);
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      Logs.storage.info('位置缓存已更新: $latitude, $longitude');
    } catch (e) {
      Logs.storage.warning('保存位置缓存失败: $e');
    }
  }

  /// 获取缓存位置
  /// 返回 [latitude, longitude, timestamp] 或 null
  static Future<List<double>?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_cacheLatKey);
      final lng = prefs.getDouble(_cacheLngKey);
      final timestamp = prefs.getInt(_cacheTimeKey)?.toDouble() ?? 0;

      if (lat != null && lng != null) {
        Logs.storage.info('使用缓存位置: $lat, $lng');
        return [lat, lng, timestamp];
      }
      return null;
    } catch (e) {
      Logs.storage.warning('读取位置缓存失败: $e');
      return null;
    }
  }

  /// 清除缓存位置
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheLatKey);
      await prefs.remove(_cacheLngKey);
      await prefs.remove(_cacheTimeKey);
      Logs.storage.info('位置缓存已清除');
    } catch (e) {
      Logs.storage.warning('清除位置缓存失败: $e');
    }
  }

  /// 获取缓存时间（人类可读）
  static Future<String?> getCachedTime() async {
    final cached = await getCachedLocation();
    if (cached == null) return null;

    final timestamp = cached[2].toInt();
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return AppDateUtils.formatRelative(time);
  }
}
