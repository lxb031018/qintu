import 'package:qintu/models/location/lat_lng.dart';
import 'package:qintu/features/map_navigation/api/poi_api.dart';

/// POI 标注点数据模型
///
/// 用于在地图上显示 POI 标记
class PoiMarkerData {
  final String id;
  final String name;
  final String? address;
  final LatLng position;
  final String? snippet;  // 详情描述

  const PoiMarkerData({
    required this.id,
    required this.name,
    this.address,
    required this.position,
    this.snippet,
  });

  /// 从 PoiSuggestion 创建
  factory PoiMarkerData.fromSuggestion(PoiSuggestion suggestion) {
    return PoiMarkerData(
      id: suggestion.id,
      name: suggestion.name,
      address: suggestion.address,
      position: suggestion.latLng ?? const LatLng(0, 0),
      snippet: suggestion.address,
    );
  }
}

/// POI 标注层
///
/// 用于在地图上批量显示 POI 标注点
/// 类似 Android 的 PoiOverlay
class PoiOverlay {
  final List<PoiMarkerData> _pois;
  int _selectedIndex = -1;

  PoiOverlay(List<PoiMarkerData> pois) : _pois = pois;

  /// 获取所有 POI 数据
  List<PoiMarkerData> get pois => List.unmodifiable(_pois);

  /// 获取选中的 POI 索引
  int get selectedIndex => _selectedIndex;

  /// 选中某个 POI
  void selectPoi(int index) {
    if (index >= 0 && index < _pois.length) {
      _selectedIndex = index;
    }
  }

  /// 获取选中的 POI
  PoiMarkerData? get selectedPoi {
    if (_selectedIndex >= 0 && _selectedIndex < _pois.length) {
      return _pois[_selectedIndex];
    }
    return null;
  }

  /// 获取 POI 索引
  int getPoiIndex(String id) {
    for (int i = 0; i < _pois.length; i++) {
      if (_pois[i].id == id) {
        return i;
      }
    }
    return -1;
  }

  /// 获取第一个 POI 的坐标（用于定位）
  LatLng? get firstPosition {
    if (_pois.isEmpty) return null;
    return _pois.first.position;
  }

  /// 获取所有 POI 的坐标列表
  List<LatLng> get allPositions => _pois.map((p) => p.position).toList();
}
