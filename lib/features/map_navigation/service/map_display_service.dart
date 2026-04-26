import '../core/amap_map_controller.dart';
import '../models/map_overlay_models.dart';
import '../provider/location_input_provider.dart';

/// ============================================
/// 地图显示 Service
///
/// 封装地图状态编排逻辑（相机移动、标记操作）
/// 不持有 UI 状态，只负责地图视图层面的操作协调
/// ============================================

class MapDisplayService {
  AmapMapController? _mapController;

  /// 设置地图控制器
  void setMapController(AmapMapController? controller) {
    _mapController = controller;
  }

  /// 处理位置输入变化，更新地图视图
  ///
  /// 当 origin/destination POI 变化时：
  /// - 移动相机到选中位置
  /// - 添加 POI 标记
  void handleLocationInputChange(
    LocationInputState? previous,
    LocationInputState next,
  ) {
    // 当起点 POI 变化时
    if (next.origin.poi != previous?.origin.poi && next.origin.poi != null) {
      final latlng = next.origin.poi!.latLng;
      if (latlng != null) {
        _mapController?.moveCamera(lat: latlng.latitude, lng: latlng.longitude, zoom: 17);
        _mapController?.addPoiMarker(PoiMarkerData(
          id: 'origin_${DateTime.now().millisecondsSinceEpoch}',
          name: next.origin.poi!.name,
          address: next.origin.poi!.address,
          position: latlng,
        ));
      }
    }
    // 当终点 POI 变化时
    if (next.destination.poi != previous?.destination.poi && next.destination.poi != null) {
      final latlng = next.destination.poi!.latLng;
      if (latlng != null) {
        _mapController?.moveCamera(lat: latlng.latitude, lng: latlng.longitude, zoom: 17);
        _mapController?.addPoiMarker(PoiMarkerData(
          id: 'destination_${DateTime.now().millisecondsSinceEpoch}',
          name: next.destination.poi!.name,
          address: next.destination.poi!.address,
          position: latlng,
        ));
      }
    }
    // 当起点被清除时
    if (previous?.origin.poi != null && next.origin.poi == null) {
      _mapController?.clearPoiMarkers();
    }
    // 当终点被清除时
    if (previous?.destination.poi != null && next.destination.poi == null) {
      _mapController?.clearPoiMarkers();
    }
  }
}

/// 全局单例
final mapDisplayService = MapDisplayService();
