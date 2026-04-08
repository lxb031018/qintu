# 高德地图集成指南

> 本文档记录高德地图 Flutter SDK 的集成经验和使用方法，供后续开发参考。

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
<!-- 高德地图 API Key -->
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="${AMAP_ANDROID_API_KEY}" />
```

在 `android/app/build.gradle.kts` 的 `defaultConfig` 中添加：
```kotlin
manifestPlaceholders["AMAP_ANDROID_API_KEY"] = System.getenv("AMAP_ANDROID_API_KEY") ?: ""
```

### 3. 环境变量配置

在 `.env` 文件中添加：
```env
AMAP_ANDROID_API_KEY=你的高德Android端APIKey
```

### 4. 隐私合规初始化

**必须在 `runApp()` 之前调用**，在 `main.dart` 中：

```dart
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 加载环境变量
  await dotenv.load(fileName: ".env");
  
  // 初始化高德地图隐私合规（必须在任何地图操作之前调用）
  _initAmapPrivacy();
  
  runApp(const MyApp());
}

void _initAmapPrivacy() {
  const privacyStatement = AMapPrivacyStatement(
    hasContains: true,
    hasShow: true,
    hasAgree: true,
  );
  AMapInitializer.updatePrivacyAgree(privacyStatement);
}
```

---

## ⚠️ 常见问题

### 1. INVALID_USER_KEY 错误

**错误日志：**
```
E/3dmap: 获取apikey失败：errorCode : 10001
E/3dmap: 原因：确保调用SDK任何接口前先调用更新隐私合规updatePrivacyShow、updatePrivacyAgree两个接口
```

**解决方案：**
1. 确保隐私合规在 `runApp()` 之前调用
2. 检查高德后台配置的 **SHA1** 和 **PackageName** 是否匹配
3. Debug 和 Release 版本 SHA1 不同，需分别配置

**获取 Debug SHA1：**
```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**注意：** Debug 版本的包名有 `.dev` 后缀（如 `me.lxb.qintu.dev`），需在高德后台单独配置。

### 2. API Key 读取失败

**问题：** `String.fromEnvironment()` 在编译时读取，运行时无法获取 `.env` 配置

**解决方案：** 使用 `flutter_dotenv` 包读取：
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 在 main() 中先加载
await dotenv.load(fileName: ".env");

// 读取配置
final apiKey = dotenv.env['AMAP_ANDROID_API_KEY'] ?? '';
```

### 3. 初始化时序问题

**错误日志：**
```
dependOnInheritedWidgetOfExactType<MediaQuery>() was called before initState() completed
```

**解决方案：** 在 `didChangeDependencies()` 中初始化，而不是 `initState()`：
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  AmapService.instance.initialize(context);
}
```

---

## 📁 代码结构

```
lib/
├── config/
│   └── amap_config.dart           # 高德地图配置
├── services/
│   └── amap_service.dart          # 高德地图服务封装
├── features/
│   └── receiver/
│       ├── receiver_home_page.dart
│       └── widgets/
│           ├── receiver_map_widget.dart       # 地图组件
│           ├── receiver_location_toggle.dart  # 定位开关
│           ├── receiver_location_info_card.dart  # 位置信息卡片
│           └── receiver_binding_dialog.dart   # 绑定对话框
└── main.dart                      # 隐私合规初始化
```

---

## 🔑 核心 API 使用

### 地图创建

```dart
AMapWidget(
  initialCameraPosition: CameraPosition(
    target: LatLng(39.9042, 116.4074),
    zoom: 15.0,
  ),
  onMapCreated: (AMapController controller) {
    _mapController = controller;
  },
  onTap: (LatLng latLng) {
    print('点击地图: $latLng');
  },
)
```

### 相机移动

```dart
_mapController.moveCamera(
  CameraUpdate.newLatLngZoom(position, 15.0),
  animated: true,
  duration: 500,
);
```

### 定位小蓝点

```dart
AMapWidget(
  myLocationStyleOptions: const MyLocationStyleOptions(
    myLocationType: MyLocationType.LOCATION_TYPE_LOCATE,
    showLocationInfo: true,
  ),
)
```

---

## 📝 更新记录

| 日期 | 内容 |
|------|------|
| 2026-04-08 | 初始集成，完成接收者端地图显示 |
