# 高德地图使用指南

## 📦 已完成的配置

### 1. 依赖配置
- ✅ `pubspec.yaml` 已添加 `amap_map: ^1.0.15`
- ✅ 已运行 `flutter pub get`

### 2. Android 配置
- ✅ `AndroidManifest.xml` 已添加所需权限
- ✅ `build.gradle.kts` 已配置 API Key 占位符
- ✅ API Key 从环境变量 `AMAP_ANDROID_API_KEY` 读取

### 3. 服务层
- ✅ `lib/services/amap_service.dart` - 高德地图服务封装
- ✅ `lib/config/amap_config.dart` - 高德地图配置

### 4. 日志
- ✅ `lib/utils/logger.dart` 已添加 `Logs.map` 日志实例

---

## 🚀 使用方法

### 1. 配置 API Key

在 `.env` 文件中添加：
```env
AMAP_ANDROID_API_KEY=你的高德地图 Android API Key
```

### 2. 初始化 SDK

在应用启动时（如 `main.dart` 或首页）初始化：

```dart
import 'package:qintu/services/amap_service.dart';

// 在 Widget 的 initState 或 build 方法中
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AmapService.instance.initialize(context);
  });
}
```

### 3. 使用地图

在页面中使用 `AMapWidget`：

```dart
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  AMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AMapWidget(
        // 初始相机位置
        initialCameraPosition: const CameraPosition(
          target: LatLng(39.9042, 116.4074), // 北京
          zoom: 15,
        ),
        // 地图创建成功回调
        onMapCreated: (AMapController controller) {
          _mapController = controller;
          Logs.map.info('地图创建成功');
        },
        // 点击地图回调
        onTap: (LatLng latLng) {
          Logs.map.info('点击地图: $latLng');
        },
        // 添加标记点
        markers: {
          Marker(
            position: const LatLng(39.9042, 116.4074),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(
              title: '亲途',
              snippet: '北京',
            ),
          ),
        },
        // 显示实时路况
        trafficEnabled: true,
      ),
    );
  }
}
```

### 4. 地图操作

通过 `_mapController` 操作地图：

```dart
// 移动相机到新位置
_mapController?.moveCamera(
  CameraUpdate.newLatLngZoom(
    const LatLng(39.9042, 116.4074),
    17,
  ),
);

// 移动相机（带动画）
_mapController?.moveCamera(
  CameraUpdate.newCameraPosition(
    const CameraPosition(
      target: LatLng(39.9042, 116.4074),
      zoom: 15,
      bearing: 45,
      tilt: 30,
    ),
  ),
  animated: true,
  duration: 500,
);

// 地图截图
final image = await _mapController?.takeSnapshot();

// 经纬度转屏幕坐标
final screenCoord = await _mapController?.toScreenCoordinate(
  const LatLng(39.9042, 116.4074),
);
```

### 5. 计算距离

使用 `AmapService` 计算两点间距离：

```dart
final distance = AmapService.calculateDistance(
  39.9042, 116.4074,  // 起点
  31.2304, 121.4737,  // 终点
);
print('距离: ${distance.toStringAsFixed(2)} 米');
```

---

## 📝 注意事项

### 1. API Key 配置
- Android Key 需要在高德开放平台控制台绑定包名：`me.lxb.qintu`
- Debug 和 Release 版本的 SHA1 不同，需要分别配置

### 2. 隐私合规
- SDK 初始化时已配置隐私声明（`AMapPrivacyStatement`）
- 确保在用户同意隐私政策后再初始化

### 3. 权限
- 已配置位置权限（`ACCESS_FINE_LOCATION`、`ACCESS_COARSE_LOCATION`）
- 使用前需要通过 `LocationService` 检查位置权限

### 4. 调试
- 使用 `Logs.map.info()` 查看地图相关日志
- 地图初始化成功/失败都会有日志输出

---

## 🔗 相关文档

- 高德开放平台：https://lbs.amap.com/
- amap_map 文档：https://pub.dev/packages/amap_map
- 项目架构文档：`docs/architecture/PROJECT_ARCHITECTURE.md`
