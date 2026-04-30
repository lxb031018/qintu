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
  // 地图视图
  static const String mapView = 'com.qintu/amap_map_view';
}