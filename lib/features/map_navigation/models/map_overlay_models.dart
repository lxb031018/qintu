import 'package:flutter/foundation.dart';
import 'package:qintu/features/map_navigation/core/poi_api.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';

/// ============================================
/// 地图覆盖物数据模型
///
/// 从 widgets/ 目录迁移过来，统一放置在 models/ 目录
/// ============================================

// ============ POI 标注层相关 ============

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

// ============ 路线覆盖层相关 ============

/// 路线透明度常量
class RouteTransparency {
  /// 选中路线透明度（不透明）
  static const double selected = 1.0;

  /// 未选中路线透明度（半透明）
  static const double unselected = 0.3;
}

/// 单条路线数据
class RouteOverlayData {
  /// 路线索引
  final int index;

  /// 路线选项
  final RouteOption option;

  /// 路线坐标点
  final List<LatLng> points;

  /// 路线颜色（ARGB格式）
  final int color;

  /// 路线宽度
  final double width;

  /// 是否选中
  bool isSelected;

  RouteOverlayData({
    required this.index,
    required this.option,
    required this.points,
    this.color = 0xFF1890FF,
    this.width = 12.0,
    this.isSelected = false,
  });

  /// 获取透明度
  double get transparency => isSelected ? RouteTransparency.selected : RouteTransparency.unselected;
}

/// 路线标注层
///
/// 用于管理地图上的多条路线
/// 支持路线选择、透明度控制
class RouteOverlay {
  final List<RouteOverlayData> _routes;

  RouteOverlay(List<RouteOverlayData> routes) : _routes = routes;

  /// 获取所有路线
  List<RouteOverlayData> get routes => List.unmodifiable(_routes);

  /// 获取路线数量
  int get routeCount => _routes.length;

  /// 获取当前选中的索引
  int get selectedIndex => _selectedIndex;
  int _selectedIndex = -1;

  /// 获取选中的路线
  RouteOverlayData? get selectedRoute {
    if (_selectedIndex >= 0 && _selectedIndex < _routes.length) {
      return _routes[_selectedIndex];
    }
    return null;
  }

  /// 是否有效（有路线）
  bool get isNotEmpty => _routes.isNotEmpty;

  /// 获取所有路线的坐标点列表（用于 showRoutes）
  List<List<LatLng>> get allPoints {
    final result = _routes.map((r) => r.points).toList();
    debugPrint('🗺️ [RouteOverlay] allPoints getter:');
    debugPrint('   - 返回 ${result.length} 条路线');
    for (int i = 0; i < result.length; i++) {
      debugPrint('   - allPoints[$i]: ${result[i].length} 个点');
    }
    return result;
  }

  /// 选择路线
  ///
  /// [index] 路线索引
  /// 返回被选中的路线
  RouteOverlayData? selectRoute(int index) {
    if (index < 0 || index >= _routes.length) {
      return null;
    }

    // 取消之前的选中状态
    if (_selectedIndex >= 0 && _selectedIndex < _routes.length) {
      _routes[_selectedIndex].isSelected = false;
    }

    // 设置新的选中状态
    _selectedIndex = index;
    _routes[index].isSelected = true;

    return _routes[index];
  }

  /// 获取需要更新的路线透明度列表
  /// 返回 Map with index as key and transparency as value
  Map<int, double> getTransparencyUpdates() {
    final updates = <int, double>{};
    for (final route in _routes) {
      updates[route.index] = route.transparency;
    }
    return updates;
  }

  /// 根据 RouteOptions 创建路线标注层
  factory RouteOverlay.fromRouteOptions(List<RouteOption> options, {int selectIndex = 0}) {
    debugPrint('🗺️ [RouteOverlay] fromRouteOptions:');
    debugPrint('   - options.length: ${options.length}');
    debugPrint('   - selectIndex: $selectIndex');

    final routes = <RouteOverlayData>[];

    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      debugPrint('   - option[$i]: ${option.points.length} 个点');
      if (option.points.isNotEmpty) {
        debugPrint('      起点: ${option.points.first.latitude}, ${option.points.first.longitude}');
        debugPrint('      终点: ${option.points.last.latitude}, ${option.points.last.longitude}');
      }
      routes.add(RouteOverlayData(
        index: i,
        option: option,
        points: option.points,
        isSelected: i == selectIndex,
      ));
    }

    debugPrint('🗺️ [RouteOverlay] 创建完成: ${routes.length} 条路线');

    final overlay = RouteOverlay(routes);
    overlay._selectedIndex = selectIndex;
    return overlay;
  }
}

/// 路线颜色配置
class RouteColors {
  /// 驾车路线颜色
  static const int driving = 0xFF1890FF; // 蓝色

  /// 步行路线颜色
  static const int walking = 0xFF52C41A; // 绿色

  /// 骑行路线颜色
  static const int riding = 0xFFFAAD14; // 橙色

  /// 公交地铁路线颜色
  static const int transit = 0xFF722ED1; // 紫色

  /// 获取路线类型对应的颜色
  static int getColor(RouteType type) {
    switch (type) {
      case RouteType.driving:
        return driving;
      case RouteType.walking:
        return walking;
      case RouteType.riding:
        return riding;
      case RouteType.transit:
        return transit;
    }
  }

  /// 选中状态高亮颜色
  static const int selected = 0xFFFF4D4F; // 红色高亮

  /// 未选中状态淡化颜色（基于原色的淡化）
  static int getDimmedColor(RouteType type) {
    switch (type) {
      case RouteType.driving:
        return 0x801890FF; // 蓝色淡化
      case RouteType.walking:
        return 0x8052C41A; // 绿色淡化
      case RouteType.riding:
        return 0x80FAAD14; // 橙色淡化
      case RouteType.transit:
        return 0x80722ED1; // 紫色淡化
    }
  }
}

/// 路线结果数据模型（供 UI 使用）
class RouteResultItem {
  final String distance;
  final String formattedDistance;
  final String duration;
  final String formattedDuration;
  final String strategy;
  final double? tolls;

  const RouteResultItem({
    required this.distance,
    required this.formattedDistance,
    required this.duration,
    required this.formattedDuration,
    required this.strategy,
    this.tolls,
  });
}