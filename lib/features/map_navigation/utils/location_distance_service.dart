import 'package:qintu/models/location/lat_lng.dart';

/// 计算两点间的 Haversine 距离（米）
///
/// 委托给 [LatLng.distanceTo] 以保持单一实现。
double calculateHaversineDistance({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  return LatLng(lat1, lng1).distanceTo(LatLng(lat2, lng2));
}
