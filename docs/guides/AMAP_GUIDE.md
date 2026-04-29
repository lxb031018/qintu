# 高德地图集成与使用指南

> 本文档涵盖高德地图 Flutter SDK 的集成步骤、配置方法和使用示例。

---

## 📦 已集成的 SDK

| 包名 | 版本 | 用途 |
|------|------|------|
| `amap_map` | ^1.0.15 | 高德地图 Flutter 插件 |
| `x_amap_base` | ^1.0.3 | 基础类型库 |

---

## 🔧 集成步骤

### 1. 添加依赖

在 `pubspec.yaml` 中添加：
```yaml
dependencies:
  amap_map: ^1.0.15
  x_amap_base: ^1.0.3
```

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

**最后更新**：2026-04-09
