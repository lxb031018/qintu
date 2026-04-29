import 'package:qintu/models/location/lat_lng.dart';
import 'package:qintu/utils/logger.dart';

/// 解析 polyline 坐标串
///
/// 格式: "lon1,lat1;lon2,lat2;lon3,lat3"
List<LatLng> parsePolyline(String polyline) {
  try {
    return polyline.split(';').map((coord) {
      return LatLng.fromAmapString(coord);
    }).toList();
  } catch (e) {
    Logs.ui.warning('⚠️ Polyline 解析失败: $e');
    return [];
  }
}