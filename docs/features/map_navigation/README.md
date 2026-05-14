# 地图导航 (map_navigation) 功能文档

## 功能概述

`map_navigation` 是勤途应用的核心地图导航功能模块，提供以下能力：

- **路径规划**：驾车、步行、骑行、公交（Bus + 地铁）四种出行方式
- **实时导航**：基于高德地图 SDK 的 turn-by-turn 语音导航
- **POI 搜索**：输入提示、关键词搜索、位置记忆
- **位置分享**：将路线分享给绑定者
- **地图展示**：通过 PlatformView 嵌入原生高德地图

## 目录结构

```
lib/features/map_navigation/
├── map_navigation_tab.dart          # 功能入口 Tab
├── core/
│   ├── bridge/                       # Platform Channel 桥接层（api 层）
│   │   ├── amap_navigation_bridge.dart
│   │   ├── amap_bus_route_bridge.dart
│   │   ├── geocode_bridge.dart
│   │   └── poi_search_bridge.dart
│   └── controller/                   # 底层控制器聚合
│       └── amap_map_controller.dart
├── models/                           # 数据模型
├── service/                          # 业务逻辑层
│   ├── map_controller_service/       # 地图控制器服务
│   ├── poi_service.dart             # POI 搜索服务
│   ├── bus_route_service.dart        # 公交路线服务
│   └── ...
├── provider/                         # 状态管理层
│   ├── map_navigation/               # 导航状态
│   ├── location_Input/               # 位置输入状态
│   └── map_display/                  # 地图显示协调
└── widgets/                          # UI 组件层
```

## 快速开始

### 集成 AmapMapView

```dart
import 'package:qintu/features/map_navigation/widgets/amap_map_view.dart';

Stack(
  children: [
    AmapMapView(
      onMapCreated: (controller) {
        // 使用 controller 操作地图
        controller.startLocation();
      },
    ),
    // 其他 UI 覆盖层
  ],
)
```

### 发起路径规划

```dart
// 设置起终点
ref.read(mapNavigationProvider.notifier).setOrigin(poiSuggestion);
ref.read(mapNavigationProvider.notifier).setDestination(poiSuggestion);

// 选择出行方式并规划
ref.read(mapNavigationProvider.notifier).switchRouteType(RouteType.driving);
```

### 启动导航

```dart
// 选择路线后开始导航
ref.read(mapNavigationProvider.notifier).selectRoute(index);
ref.read(mapNavigationProvider.notifier).startNavigation();
```

## 核心概念

### 出行方式 (RouteType)

| 类型 | 说明 | 使用场景 |
|------|------|----------|
| `RouteType.driving` | 驾车导航 | 长途、驾车出行 |
| `RouteType.walking` | 步行导航 | 短途步行 |
| `RouteType.riding` | 骑行导航 | 骑车出行 |
| `RouteType.transit` | 公交导航 | 包含公交+地铁的公共交通 |

### 导航状态 (NavigationStatus)

| 状态 | 说明 |
|------|------|
| `idle` | 空闲 |
| `navigating` | 导航中 |
| `arrived` | 已到达 |
| `stopped` | 已停止 |
| `recalculating` | 重新计算中 |
| `recalculated` | 重算完成 |
| `offRoute` | 偏航 |
| `gpsWeak` | GPS 信号弱 |

## 用户流程

```
┌─────────────────────────────────────────────────────────────┐
│                     用户流程                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │ 输入起点  │───▶│ 输入终点  │───▶│ 选择出行方式 │          │
│  └──────────┘    └──────────┘    └──────────┘              │
│       │                                    │                 │
│       │          ┌────────────────────────┘                 │
│       │          ▼                                          │
│       │    ┌──────────────┐                                 │
│       │    │   路线规划    │                                 │
│       │    └──────────────┘                                 │
│       │          │                                          │
│       ▼          ▼                                          │
│  ┌──────────────────────────────┐                          │
│  │     选择路线 / 查看详情       │                          │
│  └──────────────────────────────┘                          │
│                      │                                      │
│                      ▼                                      │
│              ┌──────────────┐                              │
│              │  开始导航     │                              │
│              └──────────────┘                              │
│                      │                                      │
│                      ▼                                      │
│  ┌─────────────────────────────────────────┐              │
│  │        语音导航 + 地图展示                │              │
│  └─────────────────────────────────────────┘              │
│                      │                                      │
│                      ▼                                      │
│              ┌──────────────┐                              │
│              │   到达目的地  │                              │
│              └──────────────┘                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 相关文档

- [架构规范](ARCHITECTURE.md) - 四层分离架构
- [Platform Channel 契约](PLATFORM_CHANNELS.md) - Flutter 与原生通信
- [Service 层参考](SERVICES.md) - 业务逻辑 API
- [Provider 层参考](PROVIDERS.md) - 状态管理
- [Widget 组件参考](WIDGETS.md) - UI 组件目录
- [数据模型参考](MODELS.md) - 数据结构