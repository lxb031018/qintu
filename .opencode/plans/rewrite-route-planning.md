# 重写路径规划代码 — 实现计划
> 基于官方 AMap Android SDK 文档重写路径规划相关代码

## 概述

根据 `docs/amap/AMap_Android_API_Navi_Doc` 和 `docs/amap/AMap_Android_API_Search_Doc` 的官方文档，
修复当前实现中的关键 bug 并补全缺失功能。

### 关键问题

1. **`NavigationImpl.kt:buildDrivingStrategy()` — strategyConvert 参数顺序错误**
   - 当前：`strategyConvert(avoidCongestion, avoidCost, prioritiseHighway, prioritiseFastSpeed, multiRoute)`
   - 官方签名：`strategyConvert(boolean avoidCongestion, boolean avoidHighway, boolean avoidCost, boolean prioritiseHighway, boolean multipleRoute)`
   - 导致所有驾车策略计算错误

2. **缺少电动自行车算路** — 官方 SDK 支持 `calculateEleBikeRoute()`

3. **路线详情序列化不完整** — step 缺少 links/chargeLength/tollCost/trafficLightCount

4. **公交缺少跨城公交** — 官方 `BusRouteQuery.setCityd()` 未实现

---

## 待修改文件清单（共 11 个文件）

### Android 侧 (Kotlin)

| # | 文件 | 改动 |
|---|------|------|
| 1 | `navigation/NavigationImpl.kt` | 核心：修复 strategy bug + 电动自行车 + 序列化增强 |
| 2 | `AmapNavigationPlugin.kt` | 参数转发更新 |
| 3 | `bus/BusSearchImpl.kt` | 跨城公交 cityd |
| 4 | `bus/AmapBusSearchPlugin.kt` | destCity 参数转发 |

### Flutter 侧 (Dart)

| # | 文件 | 改动 |
|---|------|------|
| 5 | `amap_routing_models.dart` | RouteType 新增 eleBike + DriveStep 新增字段 |
| 6 | `amap_navigation_bridge.dart` | 策略更新 + 新字段解析 |
| 7 | `amap_bus_search_bridge.dart` | 跨城公交 destCity |
| 8 | `amap_routing_service.dart` | eleBike + 跨城分支 |
| 9 | `map_navigation_provider.dart` | eleBike UI 适配 |
| 10 | `poi_api.dart` | （可能需要）eleBike 图标 |
| 11 | `map_overlay_models.dart` | RouteType eleBike overlay 支持 |

---

## 详细改动内容

### 文件 1: `NavigationImpl.kt`

#### 1a. Import 新增
```
+ import com.amap.api.navi.enums.PathPlanningStrategy
+ import com.amap.api.navi.model.AMapTrafficStatus
```

#### 1b. 删除自定义策略常量
删除 STRATEGY_CHEAP/STRATEGY_SHORT/... 等自定义常量（7 个常量 + lastRouteStrategy 成员）

#### 1c. 重写 buildDrivingStrategy()
```kotlin
private fun buildDrivingStrategy(strategy: Int): Int {
    return when (strategy) {
        0 -> PathPlanningStrategy.DRIVING_MULTIPLE_ROUTES_DEFAULT          // 速度优先（推荐默认）
        1 -> PathPlanningStrategy.DRIVING_MULTIPLE_ROUTES_AVOID_COST        // 避免收费
        2 -> PathPlanningStrategy.DRIVING_MULTIPLE_SHORTEST_TIME_DISTANCE   // 距离最短
        3 -> PathPlanningStrategy.DRIVING_MULTIPLE_ROUTES_AVOID_CONGESTION  // 避免拥堵
        4 -> PathPlanningStrategy.DRIVING_MULTIPLE_ROUTES_PRIORITY_HIGHSPEED_AVOID_CONGESTION // 拥堵+高速优先
        5 -> PathPlanningStrategy.DRIVING_MULTIPLE_ROUTES_AVOID_COST        // 收费+高速优先（SDK约束冲突，降级为避收费）
        6 -> PathPlanningStrategy.DRIVING_MULTIPLE_ROUTES_AVOID_HIGHSPEED   // 避开高速
        else -> PathPlanningStrategy.DRIVING_MULTIPLE_ROUTES_DEFAULT
    }
}
```

#### 1d. 更新 calculateRoute() 签名
删除 `multiRoute` 参数（所有策略已是多路径），更新 calculateRoute 内调用：
```kotlin
// 修改前
fun calculateRoute(routeType, fromLat, fromLng, toLat, toLng, strategy, multiRoute, result)

// 修改后
fun calculateRoute(routeType, fromLat, fromLng, toLat, toLng, strategy, result)
```
驾车分支：`val flag = buildDrivingStrategy(strategy)`（去掉 multiRoute 参数）
步行/骑行：`ts` 固定使用 `TravelStrategy.MULTIPLE`

#### 1e. 新增电动自行车分支
```kotlin
"elebike" -> {
    val fromPoi = NaviPoi("起点", LatLng(fromLat, fromLng), "")
    val toPoi = NaviPoi("终点", LatLng(toLat, toLng), "")
    val ts = TravelStrategy.MULTIPLE
    navi.setTravelInfo(AMapTravelInfo(TransportType.EBike))
    navi.calculateEleBikeRoute(fromPoi, toPoi, ts)
}
```

#### 1f. 补全 serializePathStep()
新增字段：
- `"links"` → step.links?.map { mapOf("lat" to it...) }  // 路段道路列表
- `"chargeLength"` → step.chargeLength.toDouble()
- `"tollCost"` → step.tollCost.toDouble()
- `"trafficLightCount"` → step.trafficLightCount
- `"isArriveWayPoint"` → step.isArriveWayPoint

#### 1g. 补全 serializeNaviPath()
新增字段：
- `"routeType"` → path.routeType           // 1=驾车,2=骑行,3=步行,4=电动自行车
- `"mainRoadInfo"` → path.mainRoadInfo ?: ""
- `"restrictionInfo"` → path.restrictionInfo?.let { mapOf("type" to it.type, "title" to it.title) }
- `"trafficStatuses"` → path.trafficStatuses?.map { mapOf("status" to it.status, "speed" to it.speed) }
- `"cityAdcodes"` → path.cityAdcodeList?.toList()
- `"cameraCount"` → (path.allCameras?.size ?: 0)
- `"naviGuideGroupCount"` → (path.naviGuideList?.size ?: 0)

#### 1h. 删除 lastRouteStrategy
该成员变量不再需要，改为在 onCalculateRouteSuccess 中透传 strategyId

---

### 文件 2: `AmapNavigationPlugin.kt`

#### 修改 calculateRoute 处理
- 删除 `multiRoute` 参数提取和传递
- 新增 `elebike` routeType 路由

```kotlin
// 修改前
val strategy = call.argument<Int>("strategy") ?: 0
val multiRoute = call.argument<Boolean>("multiRoute") ?: true
impl.calculateRoute(routeType, fromLat, fromLng, toLat, toLng, strategy, multiRoute, result)

// 修改后
val strategy = call.argument<Int>("strategy") ?: 0
impl.calculateRoute(routeType, fromLat, fromLng, toLat, toLng, strategy, result)
```

---

### 文件 3: `BusSearchImpl.kt`

#### calculateTransitRoute() 新增 destCity 参数
```kotlin
fun calculateTransitRoute(
    ...existing params...,
    destCity: String? = null
) {
    ...
    if (!destCity.isNullOrEmpty()) {
        query.setCityd(destCity)
    }
    ...
}
```

---

### 文件 4: `AmapBusSearchPlugin.kt`

#### 提取并转发 destCity 参数
```kotlin
val destCity = call.argument<String>("destCity")
impl.calculateTransitRoute(..., destCity = destCity)
```

---

### 文件 5: `amap_routing_models.dart`

#### 5a. RouteType 新增 eleBike
```dart
enum RouteType {
  driving,
  walking,
  riding,
  transit,
  eleBike,  // 新增
}
```
配套在 routeTypeName/routeIcon 等 switch 中添加处理。

#### 5b. RouteOption 新增字段
```dart
final int? routeSubType;      // 路线子类型（1=驾车,2=骑行,3=步行,4=电动自行车）
final String? mainRoadInfo;   // 主要道路信息
final int cameraCount;        // 摄像头数量
final List<int>? cityAdcodes; // 途经城市编码
```

#### 5c. DriveStep 新增字段
```dart
final List<Map<String, double>>? links; // 路段道路
final double chargeLength;              // 收费路段距离（米）
final double tollCost;                  // 该段过路费（元）
final int trafficLightCount;            // 红绿灯数量
final bool isArriveWayPoint;            // 是否经过途经点
```

---

### 文件 6: `amap_navigation_bridge.dart`

#### 6a. calculateRoute() 去掉 multiRoute 参数（统一多路径）
所有出行方式固定多路径，不再传 `multiRoute` 参数。

#### 6b. _parseRouteResponse() 新增字段解析
解析 `routeType`、`mainRoadInfo`、`restrictionInfo`、`trafficStatuses`、`cityAdcodes`、`cameraCount` 等。

#### 6c. _parseDriveStep() 新增字段解析
解析 `links`、`chargeLength`、`tollCost`、`trafficLightCount`、`isArriveWayPoint`。

#### 6d. _routeTypeToString() 新增 eleBike 映射
```dart
case RouteType.eleBike: return 'elebike';
```

---

### 文件 7: `amap_bus_search_bridge.dart`

#### planTransitRoute() 新增 destCity 参数
```dart
static Future<List<RouteOption>> planTransitRoute({
    ...existing params...,
    String? destCity,  // 新增
}) async {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'calculateTransitRoute',
      {
        ...existing params...,
        if (destCity != null) 'destCity': destCity,
      },
    );
}
```

---

### 文件 8: `amap_routing_service.dart`

#### 8a. planRoute() 新增 eleBike 分支
```dart
case RouteType.eleBike:
    return withRetry(() => AmapNavigationBridge.calculateRoute(
        type: type,
        origin: origin,
        destination: destination,
        strategy: strategy,
    ));
```

#### 8b. planRoute() transit 分支新增 destCity 参数传递
```dart
Future<List<RouteOption>> planRoute({
    ...existing params...,
    String? destCity,  // 新增：跨城公交目标城市
}) async {
    ...
    case RouteType.transit:
        return withRetry(() async {
            final result = await AmapBusSearchBridge.planTransitRoute(
                ...
                destCity: destCity,  // 新增
            );
            ...
        });
}
```

---

### 文件 9: `map_navigation_provider.dart`

#### 9a. 出行方式列表新增 eleBike
在 routeType 切换相关 UI 中新增电动自行车选项，图标和文本。

#### 9b. eleBike 路线预览
在 planRoute() 中，eleBike 与 driving/walking/riding 一样需要在地图上显示路线。

---

### 文件 10-11: 辅助文件适配
- `map_overlay_models.dart` — RouteOverlayState 确保支持 RouteType.eleBike
- `map_controller_provider.dart` — 确保 eleBike 路线渲染正常

---

## 执行顺序

1. **Android 侧** (1-4)：先修改 Native 层
2. **Flutter 数据模型** (5)：模型层适配
3. **Flutter 桥接层** (6-7)：通信层适配
4. **Flutter 服务层** (8)：业务逻辑适配
5. **Flutter UI 层** (9-11)：UI 层适配

## 验证步骤

执行完成后运行：
```bash
flutter analyze
```
确保无编译错误。
