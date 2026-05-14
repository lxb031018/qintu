# map_navigation 架构规范

## 四层架构

`map_navigation` 遵循 Flutter 四层分离架构：

```
┌─────────────────────────────────────────────────────────────┐
│                      Widget 层                              │
│                  （UI 组件，纯展示）                          │
├─────────────────────────────────────────────────────────────┤
│                     Provider 层                              │
│               （UI 状态，编排 Service）                       │
├─────────────────────────────────────────────────────────────┤
│                      Service 层                             │
│                   （业务逻辑，不持有状态）                     │
├─────────────────────────────────────────────────────────────┤
│                      Core 层                                │
│         （Platform Channel 桥接，底层控制器聚合）              │
└─────────────────────────────────────────────────────────────┘
```

## 数据流向

```
用户操作 → Widget → Provider → Service → Core/Bridge → Platform Channel → Android 原生
                ↑                                      │
                └──────────── 状态更新 ←────────────────┘
```

## 各层职责

### Core 层 (`core/`)

**职责**：封装 Platform Channel 与 Android 原生通信

| 目录 | 职责 | 禁止 |
|------|------|------|
| `core/bridge/` | Platform Channel 桥接，封装原生 SDK 调用 | 调用 service 层 |
| `core/controller/` | 底层控制器聚合，管理生命周期 | 持有 UI 状态 |

**Bridge 类**（对应 `api/` 层）：

- `AmapNavigationBridge` - 导航生命周期（开始/暂停/恢复/停止）
- `AmapBusRouteBridge` - 公交路线规划
- `GeocodeBridge` - 正向/逆向地理编码
- `PoiSearchBridge` - POI 搜索

### Service 层 (`service/`)

**职责**：纯业务逻辑，不持有 UI 状态

| Service | 封装 | 关键方法 |
|---------|------|----------|
| `MapControllerService` | `AmapMapController` | `startLocation()`, `showRoutes()` |
| `PoiService` | `PoiSearchBridge` | `inputTips()`, `searchPoi()` |
| `BusRouteService` | `AmapBusRouteBridge` | `calculateBusRoute()` |
| `BackgroundLocationService` | `background_location` 通道 | `startTracking()` |

**规则**：
- 不继承 `ChangeNotifier`
- 不直接持有 UI 状态
- 异常需包装成业务异常，不直接吐给 UI

### Provider 层 (`provider/`)

**职责**：UI 状态管理，编排 Service

| Provider | 状态 | 编排的 Service |
|----------|------|----------------|
| `MapNavigationNotifier` | 路线规划、导航状态 | `PoiService`, `BusRouteService` |
| `LocationInputNotifier` | 起终点输入、POI 搜索 | `PoiService` |
| `MapDisplayCoordinator` | 地图显示协调 | `MapControllerService` |

**规则**：
- 使用 Riverpod `Notifier` / `AsyncNotifier`
- **禁止直接导入 `core/` 层**，必须通过 Service 层
- 通过 `ref.read(serviceProvider)` 访问 Service

### Widget 层 (`widgets/`)

**职责**：纯 UI 展示，只读 Provider

**规则**：
- 不含业务逻辑
- 通过 callbacks 与父组件交互
- 不直接调用 Platform Channel

## 关键类映射表

| 层级 | Dart 类 | 对应 Kotlin 类 |
|------|---------|----------------|
| Core/Bridge | `AmapNavigationBridge` | `AmapNavigationPlugin` |
| Core/Bridge | `GeocodeBridge` | `GeocodePlugin` |
| Core/Bridge | `PoiSearchBridge` | `PoiSearchPlugin` |
| Core/Controller | `AmapMapController` | `MapViewController` |
| Service | `MapControllerService` | - |
| Provider | `MapNavigationNotifier` | - |
| Provider | `LocationInputNotifier` | - |
| Widget | `AmapMapView` | `NavigationActivity` |

## 架构合规性检查

### Flutter 侧

1. **四层分离**：每层职责是否正确
2. **禁止逆向调用**：Provider 不能直接调 core 层
3. **禁止在 Widget 层写业务逻辑**
4. **使用统一 HTTP 客户端**：第三方 SDK 通过 Platform Channel 调用
5. **清理死代码**：删除不再使用的文件/函数/import
6. **更新目录/函数名**：使用清晰、合适的命名

### Android 原生侧

参考 [Android 架构文档](../../../architecture/ANDROID_ARCHITECTURE.md)：
- 三层分离：Activity → Plugin → 功能模块
- Plugin 层禁止业务逻辑
- Platform Channel 名称一致

## 示例：架构合规的调用链

```
❌ 错误：Provider 直接调 Bridge
LocationInputNotifier 
  → PoiSearchBridge.inputTips()  // 违规！

✅ 正确：Provider → Service → Bridge
LocationInputNotifier 
  → PoiService.inputTips() 
    → PoiSearchBridge.inputTips()  // 合规
```

## 文件权限

| 目录 | 可被哪些层导入 |
|------|---------------|
| `core/bridge/` | `service/` 层 |
| `core/controller/` | `service/` 层 |
| `service/` | `provider/` 层 |
| `provider/` | `widget/` 层 |
| `widgets/` | 其他 `widget/` 层、`map_navigation_tab.dart` |