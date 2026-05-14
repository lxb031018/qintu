# Platform Channel 契约

本文档记录 `map_navigation` 功能与 Android 原生通信的所有 Platform Channel。

**常量定义来源**：`lib/core/constants/platform_channels.dart`

## Channel 一览

| Channel 名称 | 类型 | 用途 |
|--------------|------|------|
| `com.qintu/amap_map_control` | MethodChannel | 地图控制（相机、标记、路线） |
| `com.qintu/amap_location_event` | EventChannel | 位置更新流 |
| `com.qintu/amap_navigation` | MethodChannel | 导航生命周期 |
| `com.qintu/amap_navigation/events` | EventChannel | 导航状态事件流 |
| `com.qintu/amap_route_search` | MethodChannel | 驾车/步行/骑行路线规划 |
| `com.qintu/amap_bus_search` | MethodChannel | 公交路线规划 |
| `com.qintu/amap_geocode` | MethodChannel | 地理编码（正向+逆向） |
| `com.qintu/amap_poi_search` | MethodChannel | POI 搜索、输入提示 |
| `com.qintu/background_location` | MethodChannel | 后台定位服务控制 |
| `com.qintu/background_location/events` | EventChannel | 后台位置更新流 |
| `com.qintu/amap_map_view` | MethodChannel | AMapNaviView 控制 |

## 详细契约

### 1. amap_navigation

**类型**：MethodChannel

**用途**：导航生命周期管理（开始/暂停/恢复/停止）

**方法**：

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `selectRouteId` | `{routeId: int}` | `bool` | 选择路线 |
| `calculateRoute` | `{routeType, fromLat, fromLng, toLat, toLng, strategy, isMultiple}` | `Map` | 计算路线 |
| `startNavigation` | `{isEmulator: bool, enableVoice: bool}` | `bool` | 开始导航 |
| `stopNavigation` | - | `bool` | 停止导航 |
| `pauseNavigation` | - | `bool` | 暂停导航 |
| `resumeNavigation` | - | `bool` | 恢复导航 |

### 2. amap_navigation/events

**类型**：EventChannel

**用途**：导航状态事件流

**事件类型**：

| type | 字段 | 说明 |
|------|------|------|
| `locationUpdate` | `lat`, `lng`, `speed`, `bearing` | 位置更新 |
| `naviInfo` | `remainingDistance`, `remainingTime`, `nextRoadName`, `currentRoadName` | 导航信息 |
| `naviStatus` | `status`, `calcRouteType` | 导航状态 |
| `naviText` | `text` | 导航语音播报文本 |
| `gpsStatus` | `isWeak` | GPS 状态 |

### 3. amap_map_control

**类型**：MethodChannel

**用途**：地图控制（相机、标记、路线渲染）

**方法**：

| 方法 | 说明 |
|------|------|
| `startLocation` | 启动定位 |
| `moveCamera` | 移动相机 |
| `animateCamera` | 动画移动相机 |
| `animateCameraToBounds` | 动画移动到指定区域 |
| `showRoutes` | 显示路线 |
| `showRoutesWithOverlay` | 显示路线（带 TMC 交通路况） |
| `selectRoute` | 选中路线 |
| `clearRoutes` | 清除路线 |
| `setRouteMarkers` | 设置起终点标记 |
| `clearRouteMarkers` | 清除起终点标记 |
| `setFollowMode` | 设置跟随模式 |
| `setLockCar` | 设置锁车 |
| `setLocationDotEnabled` | 设置定位点显示 |
| `setCarOverlayVisible` | 设置车辆图标显示 |
| `enableNaviMode` | 启用导航模式 |
| `disableNaviMode` | 禁用导航模式 |
| `enterNavigationMode` | 进入导航视图 |

### 4. amap_location_event

**类型**：EventChannel

**用途**：位置更新流

**事件格式**：
```dart
{
  'lat': double,
  'lng': double,
  'speed': double,
  'bearing': double,
  'accuracy': double,
  'time': String,
}
```

### 5. amap_route_search

**类型**：MethodChannel

**用途**：驾车/步行/骑行多路线规划

**方法**：

| 方法 | 参数 | 返回值 |
|------|------|--------|
| `calculateRoute` | `routeType`, `fromLat`, `fromLng`, `toLat`, `toLng`, `strategy`, `isMultiple` | `List<RouteOption>` |

### 6. amap_bus_search

**类型**：MethodChannel

**用途**：公交路线规划（Bus + 地铁）

**方法**：

| 方法 | 参数 | 返回值 |
|------|------|--------|
| `calculateBusRoute` | `from`, `to`, `city`, `cityCode`, `mode`, `nightFlag` | `List<BusPath>` |

### 7. amap_geocode

**类型**：MethodChannel

**用途**：正向/逆向地理编码

**方法**：

| 方法 | 参数 | 返回值 |
|------|------|--------|
| `geocodeAddress` | `address`, `city` | `GeocodeResult` |
| `regeocode` | `lat`, `lng`, `radius` | `RegeocodeResult` |

### 8. amap_poi_search

**类型**：MethodChannel

**用途**：POI 搜索、输入提示

**方法**：

| 方法 | 参数 | 返回值 |
|------|------|--------|
| `inputTips` | `keyword`, `city`, `lat`, `lng` | `List<PoiSuggestion>` |
| `searchPoi` | `keyword`, `city`, `lat`, `lng`, `radius`, `cityLimit` | `PoiSearchResult` |

### 9. background_location

**类型**：MethodChannel

**用途**：后台定位服务控制

**方法**：

| 方法 | 参数 | 返回值 |
|------|------|--------|
| `start` | - | `bool` |
| `stop` | - | `bool` |
| `getLastLocation` | - | `Map` |

### 10. background_location/events

**类型**：EventChannel

**用途**：后台位置更新流

### 11. amap_map_view

**类型**：MethodChannel

**用途**：AMapNaviView 控制

**方法**：

| 方法 | 参数 | 返回值 |
|------|------|--------|
| `pauseNaviView` | - | `void` |
| `resumeNaviView` | - | `void` |
| `setNaviShowMode` | `mode: int` | `void` |

**mode 取值**：
- `1` = 锁车态
- `2` = 全览态
- `3` = 普通态

## Dart 桥接类

| Channel | Dart 桥接类 | 文件 |
|---------|------------|------|
| `amap_navigation` | `AmapNavigationBridge` | `lib/features/map_navigation/core/bridge/amap_navigation_bridge.dart` |
| `amap_bus_search` | `AmapBusRouteBridge` | `lib/features/map_navigation/core/bridge/amap_bus_route_bridge.dart` |
| `amap_geocode` | `GeocodeBridge` | `lib/features/map_navigation/core/bridge/geocode_bridge.dart` |
| `amap_poi_search` | `PoiSearchBridge` | `lib/features/map_navigation/core/bridge/poi_search_bridge.dart` |

## Kotlin 对应

参考 [Android 架构文档](../../../architecture/ANDROID_ARCHITECTURE.md) 的 Plugin 层。

## 错误处理

所有 MethodChannel 方法：
- 捕获 `PlatformException`
- 返回 `null` 或 `false` 表示失败
- 记录错误日志到 `Logs.navigation`