# Widget 组件目录

本文档描述 `map_navigation` 功能中 Widget 层的所有 UI 组件。

## 组件一览

| Widget | 文件 | 说明 |
|--------|------|------|
| `AmapMapView` | `widgets/amap_map_view.dart` | PlatformView 嵌入原生地图 |
| `MapNavigationTab` | `map_navigation_tab.dart` | 功能入口 Tab |
| `LocationInputCard` | `widgets/location_input_card/` | 起终点输入卡片 |
| `LocationCategoryList` | `widgets/location_category_list/` | 分类列表（搜索结果/历史/绑定者） |
| `RouteResultBottomSheet` | `widgets/route_result_bottom_sheet/` | 路线结果底部面板 |
| `LocationStatusButton` | `widgets/location_status_button.dart` | GPS 状态按钮 |
| `MyLocationButton` | `widgets/my_location_button.dart` | 我的位置按钮 |
| `RouteShareCard` | `widgets/route_share_card/` | 路线分享卡片 |

---

## AmapMapView

**文件**：`lib/features/map_navigation/widgets/amap_map_view.dart`

**职责**：通过 PlatformView 嵌入原生高德地图。

### 属性

```dart
AmapMapView({
  Key? key,
  required void Function(MapControllerService controller) onMapCreated,
})
```

### 使用方式

```dart
Stack(
  children: [
    AmapMapView(
      onMapCreated: (controller) {
        ref.read(mapControllerNotifierProvider.notifier).setController(controller);
      },
    ),
  ],
)
```

### 生命周期

`AmapMapView` 对应 Android 原生的 `NavigationActivity`，通过 Platform Channel 与 Flutter 通信。

---

## MapNavigationTab

**文件**：`lib/features/map_navigation/map_navigation_tab.dart`

**职责**：地图导航功能的主入口 Tab，组合所有子组件。

### 状态管理

- 监听 `locationInputProvider` 变化
- 监听 `routeShareNotifierProvider` 分享事件
- 处理 App 生命周期（前台/后台）

### 组合关系

```
MapNavigationTab
├── AmapMapView                    // 地图
├── LocationInputCard              // 输入卡
├── LocationCategoryList           // 分类列表
├── LocationStatusButton           // GPS 状态
└── RouteResultBottomSheet         // 路线结果面板
```

---

## LocationInputCard

**目录**：`lib/features/map_navigation/widgets/location_input_card/`

**职责**：起终点输入卡片，包含起点/终点输入行和交换按钮。

### 子组件

| 组件 | 说明 |
|------|------|
| `LocationInputRow` | 单个位置输入行 |
| `SwappableLocationRow` | 可拖拽交换的行 |
| `RouteTypeSelector` | 出行方式选择器 |

### LocationInputRow

**文件**：`location_input_card/location_input_row.dart`

单个位置输入行，包含：
- 输入框
- 清除按钮
- 历史按钮

### SwappableLocationRow

**文件**：`location_input_card/swappable_location_row.dart`

可拖拽交换的行，支持：
- 拖拽排序交换起终点
- 长按提示

### RouteTypeSelector

**文件**：`location_input_card/route_type_selector.dart`

出行方式选择器，支持：
- `driving` - 驾车
- `walking` - 步行
- `riding` - 骑行
- `transit` - 公交

---

## LocationCategoryList

**目录**：`lib/features/map_navigation/widgets/location_category_list/`

**职责**：位置分类列表，显示搜索结果/推荐/绑定者/历史。

### 子组件

| 组件 | 说明 |
|------|------|
| `CategoryTabBar` | 分类 Tab 栏（推荐/绑定/历史） |
| `CategoryButton` | 分类 Tab 按钮 |
| `LocationListItem` | 位置列表项 |
| `HistoryListItem` | 历史记录项 |
| `HistorySelectionBar` | 历史选择栏 |
| `CloseButton` | 关闭按钮 |

### CategoryTabBar

```dart
CategoryTabBar({
  required LocationCategory selectedCategory,
  required void Function(LocationCategory) onCategoryChanged,
})
```

### LocationListItem

```dart
LocationListItem({
  required PoiSuggestion poi,
  required VoidCallback onTap,
  VoidCallback? onDelete,
})
```

---

## RouteResultBottomSheet

**目录**：`lib/features/map_navigation/widgets/route_result_bottom_sheet/`

**职责**：路线结果底部面板，显示多条路线选项。

### 子组件

| 组件 | 说明 |
|------|------|
| `RouteCard` | 单条路线卡片（非公交） |
| `TransitItineraryCard` | 公交路线详情卡片 |
| `TrafficBar` | 交通状况条 |
| `DiffLabel` | 差异标签（时间/距离） |
| `DetailPageHeader` | 详情页头部 |
| `DragHandle` | 拖拽手柄 |
| `EmptyState` | 空状态 |

### RouteCard

用于非公交路线的路线卡片，显示：
- 距离、时间
- 路线策略
- 收费信息
- 时间/距离差异对比

### TransitItineraryCard

用于公交路线的详细卡片，包含：
- 分段信息（步行、公交、地铁）
- 地铁线路颜色（60+ 城市）
- 换乘信息

---

## LocationStatusButton

**文件**：`lib/features/map_navigation/widgets/location_status_button.dart`

**职责**：显示 GPS 状态（定位中/定位成功/GPS 不可用）。

### 使用方式

```dart
LocationStatusButton()
// 需要配合 locationProvider 使用
```

---

## MyLocationButton

**文件**：`lib/features/map_navigation/widgets/my_location_button.dart`

**职责**：点击后移动相机到我的位置。

### 使用方式

```dart
MyLocationButton(
  onPressed: () {
    ref.read(mapControllerNotifierProvider.notifier).moveToMyLocation();
  },
)
```

---

## RouteShareCard

**目录**：`lib/features/map_navigation/widgets/route_share_card/`

**职责**：显示被分享的路线，提供导航或取消选项。

### 使用方式

```dart
RouteShareCard(
  share: sharedRoute,
  onNavigate: () {
    // 开始导航
  },
  onCancel: () {
    // 取消分享
  },
)
```

---

## 组件层级

```
┌─────────────────────────────────────────────────────────────┐
│                      Stack                                 │
├─────────────────────────────────────────────────────────────┤
│  Positioned.fill: AmapMapView                              │
│                                                             │
│  Positioned (top): LocationInputCard                        │
│    └── LocationInputRow × 2 + RouteTypeSelector            │
│                                                             │
│  Positioned (top, conditional): LocationCategoryList        │
│    └── CategoryTabBar + LocationListItem × N                │
│                                                             │
│  Positioned (bottom): RouteResultBottomSheet               │
│    └── RouteCard × N / TransitItineraryCard                 │
│                                                             │
│  Positioned (left, bottom): LocationStatusButton            │
│                        MyLocationButton                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 架构合规性

### Widget 层规则

1. **纯 UI**：Widget 只负责展示，不含业务逻辑
2. **只读状态**：通过 `ref.watch()` 读取 Provider 状态
3. **通过 callbacks 交互**：用户操作通过 callbacks 传给父组件
4. **禁止直接调用 Service**：不直接访问 `service/` 层

### 正确示例

```dart
class LocationInputCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationInputProvider);
    
    return Column(
      children: [
        LocationInputRow(
          text: state.origin.text,
          onChanged: (text) {
            ref.read(locationInputProvider.notifier).updateOriginText(text);
          },
        ),
      ],
    );
  }
}
```

### 错误示例

```dart
class LocationInputCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ 错误：在 Widget 中直接调用 Service
    final result = await PoiService().searchPoi(keywords: 'test');
    
    // ❌ 错误：在 Widget 中直接访问 core 层
    await AmapNavigationBridge.startNavigation();
  }
}
```