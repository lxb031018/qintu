# 高德地图集成与使用指南

> 本文档（非高德地图官方文档）涵盖高德地图 Flutter SDK 的集成步骤、配置方法和使用示例。

---

### 2. Android 配置

#### 2.1 权限配置（`android/app/src/main/AndroidManifest.xml`）

```xml
<!-- 位置权限 -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- 高德地图所需权限 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### 2.2 API Key 配置

在 `android/app/src/main/AndroidManifest.xml` 的 `<application>` 标签中添加：
```xml
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="${AMAP_ANDROID_API_KEY}" />
```

#### 2.3 Gradle 配置（`android/app/build.gradle.kts`）

```kotlin
defaultConfig {
    manifestPlaceholders["AMAP_ANDROID_API_KEY"] = System.getenv("AMAP_ANDROID_API_KEY") ?: ""
}
```

### 3. 配置 API Key

在 `.env` 文件中添加：
```env
AMAP_ANDROID_API_KEY=你的高德地图 Android API Key
```

> **获取 API Key**：[高德开放平台控制台](https://console.amap.com/) → 应用管理 → 创建应用 → 添加 Key

---

## 🚀 使用方法

### 1. 初始化 SDK

在应用启动时初始化（`main.dart` 已集成）：

```dart
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';

// 隐私合规设置（必须在任何地图操作之前）
AMapInitializer.updatePrivacyAgree(AMapPrivacyStatement(
  hasContains: true,
  hasShow: true,
  hasAgree: true,
));
```

### 2. 使用地图组件

```dart
import 'package:amap_map/amap_map.dart';

AMapWidget(
  onMapCreated: (controller) {
    // 地图创建完成回调
  },
  myLocationEnabled: true,
)
```

### 3. 服务层封装

项目已封装 `AmapService`（`lib/services/amap_service.dart`），提供高级 API：

```dart
import 'package:qintu/services/amap_service.dart';

// 初始化
await AmapService.instance.initialize(context);

// 获取当前位置
final location = await AmapService.instance.getCurrentLocation();
```

---

## ⚙️ 配置类

`lib/config/amap_config.dart` 提供统一配置入口：

```dart
class AmapConfig {
  static String get apiKey => dotenv.env['AMAP_ANDROID_API_KEY'] ?? '';
  static const double defaultZoom = 15.0;
  static const LatLng defaultLocation = LatLng(39.9042, 116.4074); // 北京
}
```

---

## 🐛 常见问题

### 问题 1：地图无法显示

**原因**：API Key 未配置或权限不足

**解决**：
1. 检查 `.env` 中 `AMAP_ANDROID_API_KEY` 是否正确
2. 确认 `AndroidManifest.xml` 中已添加所需权限
3. 检查高德开放平台中 Key 的 SHA1 和应用包名是否匹配

### 问题 2：隐私合规报错

**原因**：未在初始化前设置隐私合规

**解决**：确保 `AMapInitializer.updatePrivacyAgree()` 在 `runApp()` 之前调用

### 问题 3：定位失败

**原因**：位置权限未授予

**解决**：
1. 检查 Android 权限是否已授予
2. 使用 `permission_handler` 请求运行时权限

### 问题 4：API Key 为空，SDK 报 10001 错误

**原因**：Gradle 中 `.env` 文件路径解析错误。在 `android/app/build.gradle.kts` 中使用 `rootProject.file(".env")` 时，路径相对于 Gradle 根项目（即 `android/` 目录），而非 Flutter 项目根目录，导致找不到 `.env` 文件，API Key 为空。

**解决**：修正 `.env` 文件路径为 Flutter 根目录：
```kotlin
// 错误示例
val envFile = rootProject.file(".env")

// 正确示例
val envFile = file("${project.rootDir}/../.env")
```
或者使用 `rootProject.rootDir` 向上定位到 Flutter 项目根目录的 `.env` 文件。

**验证**：构建后检查 `android/app/build/intermediate/processed_res/org/release/processReleaseResources/out/output.json` 中 `AMAP_ANDROID_API_KEY` 是否有值。

---

## 📝 日志

使用 `Logs.map` 记录地图相关日志：

```dart
import 'package:qintu/utils/logger.dart';

Logs.map.info('地图初始化成功');
Logs.map.warning('定位精度较低');
Logs.map.error('地图加载失败: $error');
```

---

## 🔍 Android 原生搜索 SDK 集成（公交/路线）

项目使用高德 Android 原生搜索 SDK（`AMapSearch`）实现公交站搜索、线路查询、公交路径规划，通过 Platform Channel 与 Flutter 通信。

### 1. 隐私合规（搜索 SDK 独立设置）

搜索 SDK 需要**单独设置**隐私合规，不同于地图 SDK 的 `MapsInitializer`：

```kotlin
import com.amap.api.services.core.ServiceSettings

// 在任何搜索 API 调用之前
ServiceSettings.updatePrivacyShow(context, true, true)
ServiceSettings.updatePrivacyAgree(context, true)
```

**遗漏后果**：`calculateBusRouteAsyn` 返回 `errorCode=1200`（参数无效）。

### 2. 公交路径规划的 city 参数必须用城市区号

`RouteSearchV2.BusRouteQuery` 的 `city` 参数要求**城市电话区号**（如 `"010"`、`"0771"`），不能传城市名（如 `"北京"`、`"南宁市"`）。

```kotlin
// ❌ 错误：传城市名
RouteSearchV2.BusRouteQuery(fromAndTo, mode, "南宁市", 0)

// ✅ 正确：传电话区号
RouteSearchV2.BusRouteQuery(fromAndTo, mode, "0771", 0)
```

**获取区号**：通过高德逆地理编码 Web API（`/v3/geocode/regeo`）的 `addressComponent.citycode` 字段获取。

**错误现象**：传城市名时 SDK 返回 `errorCode=1200`（`CODE_AMAP_SERVICE_INVALID_PARAMS`）。

### 3. Polyline 数据必须显式设置 showFields

`BusRouteQuery` 默认不返回路径坐标（polyline）。必须显式设置：

```kotlin
val query = RouteSearchV2.BusRouteQuery(fromAndTo, mode, city, 0)
query.showFields = RouteSearchV2.ShowFields.ALL  // 必须设置！
routeSearchV2.calculateBusRouteAsyn(query)
```

**遗漏后果**：所有路径的 `polyline` 字段为空列表，地图上无法绘制路线。

### 4. 并发请求的回调竞态

`BusLineSearch` 不支持同时发起多个请求（后一个请求会覆盖前一个）。当需要并发搜索多条线路时，使用自增 ID 区分回调：

```kotlin
private val lineCallbacks = mutableMapOf<Int, MethodChannel.Result>()
private val lineRequestId = AtomicInteger(0)

fun searchBusLineByName(keyword: String, city: String, callback: MethodChannel.Result) {
    val requestId = lineRequestId.incrementAndGet()
    lineCallbacks[requestId] = callback
    // ...
}
```

**错误做法**：使用固定字符串 `"line_search"` 作为回调 key，多请求并发时回调被覆盖或错配。

### 5. 导航 UI 已全面使用官方 SDK

项目已全面使用 `AMapNaviView` 内置导航 UI，不再使用 Flutter 自定义覆盖层。

**已启用功能：**
- `setLayoutVisible(true)` — 显示完整导航 UI（转向箭头、路口放大图、限速提示等）
- `setAfterRouteAutoGray(true)` — 已过路段自动变灰
- `setTrafficLine(true)` — 彩虹交通线
- `setEagleMapVisible(true)` — 鹰眼小地图
- `setAutoLockCar(true)` — 导航中自动锁车
- `setAutoDisplayOverview(true)` — 开始导航后自动显示全览
- `setShowCameraDistance(true)` — 电子眼距离提示
- `setLaneInfoShow(true)` — 车道信息
- `setRouteListButtonShow(true)` — 路线概览按钮

**Flutter 侧变更：**
- 已删除 `NavigationOverlay` 自定义widget（`lib/features/map_navigation/widgets/navigation_overlay.dart`）
- `map_navigation_provider.dart` 简化导航状态管理（不再解析 speed/distance/time，SDK UI 直接展示）
- `map_navigation_tab.dart` 移除 `NavigationOverlay` 叠加

**遗留代码清理：**
- `CarOverlay`（自定义车辆绘制）暂时保留作为备份；如 SDK 车辆图标够用可删除
- 生命周期同步已通过 `AmapMapPlugin` 的 `pauseNaviView`/`resumeNaviView` 方法支持

---

**最后更新**：2026-05-03
