# Service 层 API 参考

本文档描述 `map_navigation` 功能中 Service 层的所有类及其 API。

## Service 一览

| Service | 封装 | 说明 |
|---------|------|------|
| `MapControllerService` | `AmapMapController` | 地图控制器，封装地图操作 |
| `PoiService` | `PoiSearchBridge` | POI 搜索，含缓存和去重 |
| `BusRouteService` | `AmapBusRouteBridge` | 公交路线规划 |
| `BackgroundLocationService` | `background_location` 通道 | 后台定位服务 |
| `LocationCategoryService` | - | 位置分类（历史/绑定者）管理 |
| `LocationSharingService` | API | 路线分享 |

## MapControllerService

**文件**：`lib/features/map_navigation/service/map_controller_service/map_controller_service.dart`

**职责**：封装 `AmapMapController`，提供地图操作能力给 Provider 层。

**注意**：Provider 层禁止直接访问 `core/controller/`，必须通过本 Service。

### 构造

```dart
MapControllerService()
```

### 定位

```dart
/// 启动定位
Future<void> startLocation({bool autoMoveToFirstLocation = true})

/// 移动到我的位置
Future<void> moveToMyLocation()

/// 获取当前位置
Future<Map<String, dynamic>?> getCurrentLocation()

/// 获取最后已知位置
Future<Map<String, dynamic>?> getLastKnownLocation()
```

### 相机控制

```dart
/// 移动相机
Future<void> moveCamera({required double lat, required double lng, double zoom = 15.0})

/// 动画移动相机
Future<void> animateCamera({required double lat, required double lng, ...})

/// 动画移动到指定区域（用于显示多条路线）
Future<void> animateCameraToBounds(List<Map<String, double>> points, {int padding = 100, int duration = 800})
```

### 路线

```dart
/// 显示路线
Future<int?> showRoutes(List<Map<String, dynamic>> routes, {int selectIndex = 0, ...})

/// 显示路线（带 TMC 交通路况）
Future<int?> showRoutesWithOverlay(List<int> routeIds, {int selectIndex = 0})

/// 选中路线
Future<bool> selectRoute(int index, {int selectedColor = 0xFFFF4D4F, ...})

/// 进入导航模式
Future<bool> enterNavigationMode(int routeId)

/// 清除路线
Future<void> clearRoutes()
Future<void> clearRouteOverlays()
```

### 导航/车载

```dart
/// 更新车辆标记
Future<bool> updateCarMarker({required double lat, required double lng, double bearing = 0})

/// 设置跟随模式
Future<bool> setFollowMode(bool enabled)

/// 设置定位点显示
Future<bool> setLocationDotEnabled(bool enabled)

/// 设置车辆图标显示
Future<bool> setCarOverlayVisible(bool visible)
```

### AMapNaviView 生命周期

```dart
/// 暂停导航视图（对应 Activity.onPause）
Future<void> pauseNaviView()

/// 恢复导航视图（对应 Activity.onResume）
Future<void> resumeNaviView()

/// 启用导航模式
Future<void> enableNaviMode()

/// 禁用导航模式
Future<void> disableNaviMode()
```

---

## PoiService

**文件**：`lib/features/map_navigation/service/poi_service.dart`

**职责**：POI 搜索业务逻辑，封装 `PoiSearchBridge`，提供缓存和请求去重。

### 构造

```dart
PoiService()  // 使用 poiServiceProvider 访问
```

### 搜索方法

```dart
/// 输入提示（模糊匹配）
Future<List<PoiSuggestion>> inputTips({
  required String keywords,
  String? city,
  LatLng? location,
})

/// POI 关键字搜索（带缓存和去重）
Future<PoiSearchResult> searchPoi({
  required String keywords,
  String? city,
  LatLng? location,
  int radius = 50000,
})
```

### 地理编码

```dart
/// 坐标转城市名
Future<String?> getCityFromLocation(LatLng location)

/// 坐标转城市区号
Future<String?> getCityCodeFromLocation(LatLng location)

/// 完整的逆地理编码结果
Future<RegeocodeResult?> getRegeocodeFromLocation(LatLng location)
```

### 带位置上下文的搜索

```dart
Future<LocationSearchResult> searchPoiWithLocation({
  required String keyword,
  required LocationSearchContext context,
})
```

**示例**：

```dart
final result = await poiService.searchPoi(
  keywords: '北京大学',
  city: '010',
  location: myLocation,
);
```

---

## BusRouteService

**文件**：`lib/features/map_navigation/service/bus_route_service.dart`

**职责**：公交路线规划业务逻辑，封装 `AmapBusRouteBridge`。

### 构造

```dart
BusRouteService()
```

### 搜索方法

```dart
/// 计算公交路线
Future<List<BusPath>> calculateBusRoute({
  required LatLng from,        // 起点坐标
  required LatLng to,          // 终点坐标
  required String city,        // 城市区号（用于公交规划）
  required String cityCode,    // 城市区号（用于地铁颜色匹配）
  int mode = BusModeValues.defaultMode,  // 公交模式
  int nightFlag = 0,           // 夜班公交标识
})
```

**示例**：

```dart
final busService = BusRouteService();
final paths = await busService.calculateBusRoute(
  from: startLatLng,
  to: endLatLng,
  city: '010',
  cityCode: '010',
);
```

---

## BackgroundLocationService

**文件**：`lib/features/map_navigation/service/background_location_service.dart`

**职责**：后台定位服务管理。

### Provider

```dart
final backgroundLocationServiceProvider = Provider<BackgroundLocationService>(...);
```

### 方法

```dart
/// 启动后台定位
Future<void> startTracking()

/// 停止后台定位
Future<void> stopTracking()

/// 获取最后位置
Future<LocationData?> getLastLocation()
```

### 使用方式

```dart
// 在 Provider 中使用
ref.read(backgroundLocationServiceProvider).startTracking();

// 监听位置更新
backgroundLocationServiceProvider.locationStream.listen((location) {
  // 处理位置更新
});
```

---

## LocationCategoryService

**文件**：`lib/features/map_navigation/service/location_category_service.dart`

**职责**：位置分类管理，包括历史记录、绑定者位置。

### 分类类型

```dart
enum LocationCategory {
  recommend,  // 推荐
  binder,     // 绑定者
  history,    // 历史
}
```

### 主要方法

```dart
/// 获取分类列表
Future<List<LocationCategoryItem>> getCategories()

/// 选择分类项
Future<void> selectCategory(LocationCategoryItem item)

/// 添加到历史
Future<void> addToHistory(PoiSuggestion poi)
```

---

## LocationSharingService

**文件**：`lib/features/map_navigation/service/location_sharing_service.dart`

**职责**：路线分享业务逻辑。

### 主要方法

```dart
/// 生成分享链接
Future<String?> generateShareLink({
  required PoiSuggestion origin,
  required PoiSuggestion destination,
  required RouteType routeType,
  required int routeId,
})

/// 解析分享链接
Future<SharedRoute?> parseShareLink(String shareCode)
```

---

## 架构合规性

### 正确用法

```dart
// Provider 层通过 Service 访问 Bridge
class MapNavigationNotifier extends Notifier<MapNavigationState> {
  late final PoiService _poiService = ref.read(poiServiceProvider);

  Future<void> searchPoi(String keywords) async {
    final result = await _poiService.searchPoi(keywords: keywords);
    // 处理结果
  }
}
```

### 错误用法

```dart
// ❌ 错误：Provider 直接访问 Bridge
class MapNavigationNotifier extends Notifier<MapNavigationState> {
  Future<void> searchPoi(String keywords) async {
    final result = await PoiSearchBridge.searchPoi(keywords: keywords); // 违规！
  }
}
```