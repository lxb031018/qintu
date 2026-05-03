/// Platform Channel 常量（Dart/Kotlin 共享）
///
/// Kotlin 侧对应：android/app/src/main/kotlin/me/lxb/qintu/constant/PlatformChannels.kt
class PlatformChannels {
  PlatformChannels._();

  // 地图控制
  static const String mapControl = 'com.qintu/amap_map_control';
  // 地图位置事件
  static const String mapLocationEvent = 'com.qintu/amap_location_event';
  // 导航
  static const String navigation = 'com.qintu/amap_navigation';
  // 导航事件
  static const String navigationEvents = 'com.qintu/amap_navigation/events';
  // 定位设置
  static const String locationSettings = 'qintu/location_settings';
  // 导航视图
  static const String naviView = 'com.qintu/amap_map_view';
  // 公交搜索
  static const String busSearch = 'com.qintu/amap_bus_search';
  // 路径搜索（驾车/步行/骑行/货车/公交多路线规划）
  static const String routeSearch = 'com.qintu/amap_route_search';
  // 地理编码（正向 + 逆向）
  static const String geocode = 'com.qintu/amap_geocode';
  // POI 搜索
  static const String poiSearch = 'com.qintu/amap_poi_search';
  // 后台定位
  static const String backgroundLocation = 'com.qintu/background_location';
  static const String backgroundLocationEvents = 'com.qintu/background_location/events';
}