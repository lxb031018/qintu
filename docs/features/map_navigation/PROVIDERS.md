# Provider 层参考

本文档描述 `map_navigation` 功能中 Provider 层的所有类及其状态管理方式。

## Provider 一览

| Provider | 类型 | 状态 | 说明 |
|----------|------|------|------|
| `mapNavigationProvider` | `NotifierProvider` | `MapNavigationState` | 导航状态管理 |
| `locationInputProvider` | `NotifierProvider` | `LocationInputState` | 位置输入状态 |
| `mapControllerNotifierProvider` | `NotifierProvider` | `MapControllerService` | 地图控制器 |
| `mapDisplayCoordinatorProvider` | `NotifierProvider` | `MapDisplayCoordinator` | 地图显示协调 |
| `routeShareNotifierProvider` | `NotifierProvider` | `RouteShareState` | 路线分享状态 |

---

## MapNavigationNotifier

**文件**：`lib/features/map_navigation/provider/map_navigation/map_navigation_notifier.dart`

**Provider**：`mapNavigationProvider`

### 状态类：MapNavigationState

```dart
class MapNavigationState {
  final PoiSuggestion? originPoi;           // 起点 POI
  final PoiSuggestion? destinationPoi;       // 终点 POI
  final LatLng? originLocation;              // 起点坐标
  final LatLng? destinationLocation;         // 终点坐标
  final RouteType? currentRouteType;         // 当前出行方式
  final List<RouteOption> routes;           // 路线列表
  final int selectedRouteIndex;              // 选中路线索引
  final bool showRoutesSheet;                // 是否显示路线面板
  final bool isNavigating;                  // 是否正在导航
  final AsyncState<List<RouteOption>> routesState;  // 路线加载状态
  final String? errorMessage;               // 错误信息
}
```

### 关键方法

#### 起终点设置

```dart
/// 设置起点
void setOrigin(PoiSuggestion poi)

/// 设置终点
void setDestination(PoiSuggestion poi)

/// 清空起点
void clearOrigin()

/// 清空终点
void clearDestination()

/// 交换起终点
Future<void> swapOriginAndDestination()
```

#### 路线规划

```dart
/// POI 搜索
Future<void> searchPoi(String keywords)

/// 规划路线（自动根据 currentRouteType 选择驾车/步行/骑行/公交）
Future<void> planRoute()

/// 切换出行方式
Future<void> switchRouteType(RouteType type)

/// 选择路线
void selectRoute(int index)
```

#### 导航控制

```dart
/// 开始导航
Future<void> startNavigation()

/// 暂停导航
Future<void> pauseNavigation()

/// 恢复导航
Future<void> resumeNavigation()

/// 停止导航
Future<void> stopNavigation()

/// 显示路线面板
void showRoutesSheet()

/// 隐藏路线面板
void hideRoutesSheet()
```

### 状态流

```
用户输入起终点
    ↓
选择出行方式
    ↓
planRoute() → 调用 AmapNavigationBridge 或 BusRouteService
    ↓
routesState: loading → success/error
    ↓
showRoutesSheet = true
    ↓
用户选择路线
    ↓
selectRoute(index)
    ↓
startNavigation() → 进入导航模式
```

---

## LocationInputNotifier

**文件**：`lib/features/map_navigation/provider/location_Input/location_input_notifier/`

**Provider**：`locationInputProvider`

### 状态类：LocationInputState

```dart
class LocationInputState {
  final LocationInput origin;      // 起点输入状态
  final LocationInput destination;  // 终点输入状态
  final bool listVisible;          // 是否显示分类列表
  final bool isOriginFocused;      // 起点是否获得焦点
  final List<PoiSuggestion> searchResults;  // 搜索结果
  final AsyncState<List<PoiSuggestion>> searchState;  // 搜索状态
}
```

### LocationInput 子类

每个 `LocationInput` 包含：
- `poi`：选中的 POI（`PoiSuggestion`）
- `text`：输入文本
- `inputting`：是否正在输入

### 关键方法

```dart
/// 设置起/终点 POI
void setOriginPoi(PoiSuggestion poi)
void setDestinationPoi(PoiSuggestion poi)

/// 更新输入文本
void updateOriginText(String text)
void updateDestinationText(String text)

/// 聚焦/失焦
void setOriginFocused(bool focused)
void setDestinationFocused(bool focused)

/// 清空
void clearOrigin()
void clearDestination()

/// 交换起终点
void swapOriginAndDestination()

/// 显示/隐藏分类列表
void showCategoryList()
void hideCategoryList()

/// 设置分类（推荐/绑定者/历史）
void setCategory(LocationCategory category)
```

### 搜索流程

```
用户输入 → updateOriginText(text)
    ↓
文本长度 >= 2
    ↓
调用 PoiService.searchPoi()
    ↓
searchState: loading → success/error
    ↓
显示搜索结果列表
```

---

## MapDisplayCoordinator

**文件**：`lib/features/map_navigation/provider/map_display/map_display_coordinator.dart`

**Provider**：`mapDisplayCoordinatorProvider`

**职责**：协调地图显示状态，包括路线展示、标记、相机位置等。

### 关键方法

```dart
/// 处理起终点变化
void handleLocationInputChange(LocationInputState? previous, LocationInputState next)

/// 显示路线
void showRoutes(List<RouteOption> routes, int selectedIndex, RouteType routeType)

/// 显示公交路线详情
void showTransitRouteDetail(RouteOption route)

/// 清除所有路线
void clearRoutes()
```

---

## RouteShareNotifier

**文件**：`lib/features/map_navigation/provider/map_navigation/route_share_notifier.dart`

**Provider**：`routeShareNotifierProvider`

### 状态类：RouteShareState

```dart
class RouteShareState {
  final SharedRoute? latestShare;      // 最新分享路线
  final bool isLoading;                 // 是否正在分享
  final String? errorMessage;           // 错误信息
}
```

### 关键方法

```dart
/// 分享路线
Future<bool> shareRoute({
  required String binderOpenid,        // 绑定者 openid
  required PoiSuggestion origin,       // 起点
  required PoiSuggestion destination,  // 终点
  required RouteType routeType,        // 出行方式
  required int routeId,                // 路线 ID
})

/// 清除最新分享
void clearLatestShare()

/// 启动轮询（检查分享状态）
void startPolling()

/// 停止轮询
void stopPolling()
```

---

## Provider 依赖关系

```
┌─────────────────────────────────────────────────────────────┐
│                    Provider 依赖图                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   locationInputProvider                                     │
│         │                                                   │
│         ├──▶ PoiService (service)                           │
│         │                                                   │
│         └──▶ LocationCategoryService (service)            │
│                                                             │
│   mapNavigationProvider                                      │
│         │                                                   │
│         ├──▶ PoiService                                    │
│         ├──▶ BusRouteService                               │
│         ├──▶ MapDisplayCoordinator                         │
│         │     └──▶ MapControllerService (service)          │
│         │                                                   │
│         └──▶ AmapNavigationBridge (core/bridge)            │
│                                                             │
│   mapDisplayCoordinatorProvider                              │
│         │                                                   │
│         └──▶ MapControllerService (service)                 │
│                                                             │
│   routeShareNotifierProvider                                │
│         │                                                   │
│         └──▶ LocationSharingService (service)             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 事件监听

### 导航状态监听

```dart
// 在 MapNavigationNotifier 中监听导航事件
void _startNavEventListener() {
  AmapNavigationBridge.navigationStateStream.listen((navState) {
    switch (navState.status) {
      case NavigationStatus.navigating:
        state = state.copyWith(isNavigating: true);
        break;
      case NavigationStatus.arrived:
        _handleNavEnd();
        break;
      // ...
    }
  });
}
```

### Widget 中监听 Provider 变化

```dart
// 在 Widget 中使用 ref.watch 和 ref.listen
Widget build(BuildContext context) {
  // 监听特定字段变化
  ref.listen(mapNavigationProvider.select((s) => s.isNavigating), (prev, next) {
    if (next) {
      // 进入导航模式
    }
  });

  final navState = ref.watch(mapNavigationProvider);
  // ...
}
```

---

## 架构合规性

### 禁止事项

```dart
// ❌ 错误：Provider 直接导入 core 层
import 'package:qintu/features/map_navigation/core/bridge/amap_navigation_bridge.dart';

class MapNavigationNotifier extends Notifier<MapNavigationState> {
  Future<void> startNav() async {
    await AmapNavigationBridge.startNavigation(); // 违规！
  }
}

// ✅ 正确：通过 Service 层
class MapNavigationNotifier extends Notifier<MapNavigationState> {
  late final MapDisplayCoordinator _mapDisplayCoordinator = 
      ref.read(mapDisplayCoordinatorProvider);

  Future<void> startNav() async {
    // 业务逻辑通过 Service 处理
  }
}
```