# 亲途 Android 架构文档

## 三层架构

```
me.lxb.qintu/
├── MainActivity.kt              # Activity 层：插件注册、FlutterEngine 配置
├── constant/
│   └── PlatformChannels.kt     # Platform Channel 常量（与 Dart 共享）
├── map/                         # 地图模块（功能模块层）
│   ├── AMapHolder.kt           # AMap 实例共享
│   ├── CameraController.kt     # 相机控制（移动、缩放、动画）
│   ├── GestureHandler.kt       # 手势与锁车逻辑
│   ├── MapController.kt        # 地图业务控制器（MethodCall 路由）
│   ├── MarkerManager.kt        # 标记管理（起点/终点/站点）
│   ├── NaviViewFactory.kt      # AMapNaviView 创建与配置
│   └── RouteRenderer.kt        # 路线渲染（Polyline / RouteOverLay）
├── location/                    # 定位模块（功能模块层）
│   ├── LocationClientImpl.kt   # 高德定位 SDK 封装
│   ├── LocationSettingsPlugin.kt  # Plugin 层：跳转系统定位设置
│   └── LocationSource.kt       # 定位能力抽象接口
├── navigation/                  # 导航模块（功能模块层）
│   ├── NavigationImpl.kt       # 高德导航 SDK 封装
│   ├── NaviPathSerializer.kt   # 路径序列化工具
│   └── NavigationStateHolder.kt  # 导航状态单例
├── geocode/                     # 地理编码模块（功能模块层）
│   ├── GeocodeImpl.kt         # 地理编码实现
│   ├── GeocodePlugin.kt       # Plugin 层
│   └── GeocodeSource.kt       # 地理编码抽象接口
├── poi/                         # POI 搜索模块（功能模块层）
│   ├── InputtipsImpl.kt       # 输入提示实现
│   ├── PoiSearchImpl.kt       # POI 搜索实现
│   └── PoiSearchPlugin.kt     # Plugin 层
├── bus/                         # 公交搜索模块（功能模块层）
│   ├── BusSearchImpl.kt       # 公交站点/线路搜索实现
│   └── AmapBusSearchPlugin.kt # Plugin 层
├── route/                       # 公交路线模块（功能模块层）
│   ├── BusRouteSearchImpl.kt  # 公交路线规划实现
│   ├── BusSegmentParser.kt    # 公交路线分段解析
│   ├── RoutePathCache.kt      # AMapNaviPath 共享缓存
│   └── RouteSearchV2Plugin.kt # Plugin 层
├── background/                  # 后台定位模块（功能模块层）
│   ├── BackgroundLocationPlugin.kt  # Plugin 层
│   └── BackgroundLocationService.kt  # 前台定位服务
├── overlay/
│   └── CarOverlay.kt          # 车辆标记覆盖层
└── util/
    ├── AMapPrivacy.kt         # 高德隐私合规初始化
    ├── CoordinateExtensions.kt  # 坐标类型扩展
    └── ScreenBrightnessManager.kt  # 屏幕常亮管理
```

### 三层架构职责

| 层级 | 文件 | 职责 |
|------|------|------|
| **Activity** | `MainActivity.kt` | 管理插件注册、FlutterEngine 配置 |
| **Plugin** | `*Plugin.kt`（8 个） | 仅负责 Flutter ↔ 原生通信，不含业务逻辑 |
| **功能模块** | `*Impl.kt`、`*Controller.kt` | 封装高德 SDK 能力（定位、地图、导航、搜索） |

### Plugin 层职责速查

| Plugin 文件 | 处理方法 | 委托对象 |
|------------|----------|----------|
| `AmapMapPlugin.kt` | 地图控制 | `MapController` |
| `AmapNavigationPlugin.kt` | 导航启停、算路 | `NavigationImpl` |
| `LocationSettingsPlugin.kt` | 打开系统设置 | — |
| `GeocodePlugin.kt` | 正/逆地理编码 | `GeocodeImpl` |
| `PoiSearchPlugin.kt` | POI 搜索、输入提示 | `PoiSearchImpl`、`InputtipsImpl` |
| `AmapBusSearchPlugin.kt` | 公交站点/线路搜索 | `BusSearchImpl` |
| `RouteSearchV2Plugin.kt` | 公交路线规划 | `BusRouteSearchImpl` |
| `BackgroundLocationPlugin.kt` | 后台定位启停 | `BackgroundLocationService` |

### Platform Channel 常量

所有常量集中定义在 `constant/PlatformChannels.kt`，Dart 侧对应 `lib/core/constants/platform_channels.dart`：

```
com.qintu/amap_map_control      → 地图控制
com.qintu/amap_location_event   → 地图定位事件
com.qintu/amap_navigation       → 导航
com.qintu/amap_navigation/events → 导航事件
com.qintu/amap_map_view         → 导航视图 PlatformView
com.qintu/amap_bus_search       → 公交搜索
com.qintu/amap_route_search     → 公交路线搜索
com.qintu/amap_geocode          → 地理编码
com.qintu/amap_poi_search       → POI 搜索
qintu/location_settings         → 定位设置
com.qintu/background_location   → 后台定位
```