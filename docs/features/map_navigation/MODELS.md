# 数据模型参考

本文档描述 `map_navigation` 功能中使用的数据模型。

## 模型文件

| 模型 | 文件 | 说明 |
|------|------|------|
| `NavigationState` | `models/navigation_models.dart` | 导航状态 |
| `NavigationStatus` | `models/navigation_models.dart` | 导航状态枚举 |
| `RouteOption` | `models/route_option_model.dart` | 路线规划结果 |
| `PoiSuggestion` | `models/poi_models.dart` | POI 建议 |
| `BusPath` | `models/bus_route_models.dart` | 公交路径 |
| `RouteSegment` | `models/route_segment_models.dart` | 路线分段 |
| `MapOverlayModels` | `models/map_overlay_models.dart` | 地图覆盖物样式 |

---

## NavigationStatus

**文件**：`lib/features/map_navigation/models/navigation_models.dart`

```dart
enum NavigationStatus {
  idle,              // 空闲
  navigating,        // 导航中
  arrived,           // 已到达
  offRoute,          // 偏航
  gpsWeak,           // GPS 信号弱
  error,             // 错误
  recalculating,     // 重新计算中
  recalculated,     // 重算完成
  stopped,           // 已停止
  parallelRoad,     // 主辅路状态
}
```

---

## NavigationState

**文件**：`lib/features/map_navigation/models/navigation_models.dart`

导航过程中的状态数据。

```dart
class NavigationState {
  final NavigationStatus status;       // 状态
  final double currentSpeed;           // 当前速度 (km/h)
  final int remainingDistance;          // 剩余距离 (m)
  final int remainingDuration;         // 剩余时间 (s)
  final String nextInstruction;        // 下一指令
  final double? currentLat;           // 当前纬度
  final double? currentLng;           // 当前经度
  final double? bearing;              // 朝向
  final String? roadName;             // 当前道路名
  final String? naviText;            // 导航播报文本
  final int naviTextType;           // 播报类型
  final Map<dynamic, dynamic>? rawData;  // 原始数据
  final int? calcRouteType;          // 路线类型
}
```

### 工厂方法

```dart
/// 从 EventChannel 事件解析
factory NavigationState.fromMap(Map<dynamic, dynamic> map)
```

---

## RouteType

**文件**：`lib/features/map_navigation/models/route_option_model.dart`

```dart
enum RouteType {
  driving,   // 驾车
  walking,   // 步行
  riding,    // 骑行
  transit,   // 公交
}
```

---

## RouteOption

**文件**：`lib/features/map_navigation/models/route_option_model.dart`

路线规划结果模型。

```dart
class RouteOption {
  final int routeId;                   // 路线 ID（用于导航）
  final double distance;              // 总距离 (m)
  final double duration;              // 总时间 (s)
  final String strategy;              // 路线策略
  final double tolls;                 // 收费金额
  final List<LatLng> points;          // 路线坐标点
  final RouteType routeType;          // 路线类型
  final int? trafficLights;           // 红绿灯数量
  final int strategyId;              // 策略 ID
  
  // 公交路线专用
  final List<RouteSegment>? transitSegments;  // 分段列表
  final double? walkDistance;         // 步行距离
  final double? busDistance;         // 公交距离
  final bool? isNightBus;            // 是否夜班公交
  final List<String>? cityCodes;     // 城市代码列表
  final String? transitSummaryText;  // 公交路线摘要
  final String? transitLineNames;    // 线路名称
  final int? transferCount;         // 换乘次数
  final List<TrafficStatus>? trafficStatuses;  // 交通状态
}
```

### 计算属性

```dart
String get distanceText  // 格式化距离，如 "5.2公里"
String get durationText  // 格式化时间，如 "20分钟"
String get transitSummaryText  // 公交路线摘要
List<String> get transitLineNames  // 线路名称列表
```

---

## PoiSuggestion

**文件**：`lib/features/map_navigation/models/poi_models.dart`

POI 自动补全建议。

```dart
class PoiSuggestion {
  final String id;                    // POI ID
  final String name;                 // 名称
  final String district;             // 所在区
  final String address;              // 地址
  final LatLng? distanceLatLng;      // 距离参考点坐标
  final int? distance;              // 距离 (m)
  final PoiSource source;            // 数据来源
}
```

### PoiSource

```dart
enum PoiSource {
  search,     // 搜索结果
  history,    // 历史记录
  binder,     // 绑定者
  recommend,  // 推荐
}
```

---

## BusPath

**文件**：`lib/features/map_navigation/models/bus_route_models.dart`

公交路线规划结果。

```dart
class BusPath {
  final int routeId;                 // 路线 ID
  final int distance;               // 总距离 (m)
  final int duration;               // 总时间 (秒)
  final int walkDistance;           // 步行距离 (m)
  final int busDistance;            // 公交距离 (m)
  final int cost;                   // 费用
  final bool nightBus;              // 是否夜班公交
  final List<RouteSegment> segments; // 分段列表
  final List<LatLng> points;        // 路线坐标点
  final List<String>? cityCodes;    // 城市代码
}
```

---

## RouteSegment

**文件**：`lib/features/map_navigation/models/route_segment_models.dart`

路线分段（步行、公交、地铁）。

```dart
class RouteSegment {
  final SegmentType type;           // 分段类型
  final String? lineName;           // 线路名称（如 "地铁2号线"）
  final int? lineColor;            // 线路颜色
  final int distance;              // 分段距离
  final int duration;              // 分段时间
  final String? departureName;     // 出发站名称
  final String? arrivalName;       // 到达站名称
  final int? stopCount;            // 站数
  final List<LatLng> points;       // 坐标点
}
```

### SegmentType

```dart
enum SegmentType {
  walk,      // 步行
  bus,       // 公交
  subway,    // 地铁
  coach,     // 长途汽车
}
```

---

## TrafficStatus

**文件**：`lib/features/map_navigation/models/route_option_model.dart`

路况状态。

```dart
class TrafficStatus {
  final int status;  // 0=畅通 1=缓慢 2=拥堵
  final int distance;  // 该路况的区间距离
}
```

---

## MapOverlayModels

**文件**：`lib/features/map_navigation/models/map_overlay_models.dart`

地图覆盖物样式配置。

```dart
class RouteOverlayStyle {
  final int selectedColor;    // 选中颜色
  final int unselectedColor;  // 未选中颜色
  final double selectedWidth;  // 选中宽度
  final double unselectedWidth;  // 未选中宽度
}
```

---

## 模型转换流程

```
Android 原生
    ↓ (EventChannel / MethodChannel)
Bridge 层 (如 AmapNavigationBridge)
    ↓ 转换为 Dart 模型
Service 层
    ↓
Provider 层 (状态管理)
    ↓
Widget 层 (UI 展示)
```

### 示例：路线规划结果转换

```dart
// Bridge 层返回原始 Map
final result = await _methodChannel.invokeMethod<Map>('calculateRoute', {...});

// 转换为 RouteOption 列表
return routes.asMap().entries.map((entry) {
  final map = entry.value as Map<dynamic, dynamic>;
  return RouteOption(
    routeId: routeIds[index],
    distance: (map['distance'] as num).toDouble(),
    duration: (map['duration'] as num).toDouble(),
    points: parsePoints(map['points']),
    routeType: _parseRouteType(routeType),
  );
}).toList();
```