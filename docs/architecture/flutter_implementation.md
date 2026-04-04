# 亲途 Flutter 端开发文档

## 📋 项目概览

### 技术栈

| 类别 | 技术选型 | 说明 |
|------|---------|------|
| **UI 框架** | Flutter 3.x | 跨平台移动应用 |
| **状态管理** | Provider | 简单易用的全局状态管理 |
| **网络请求** | Dio + http | HTTP 客户端 |
| **本地存储** | flutter_secure_storage | 安全存储 openid |
| **位置服务** | geolocator | 获取设备位置 |
| **二维码** | qr_flutter + mobile_scanner | 生成和扫描二维码 |
| **地图导航** | 高德地图 Flutter 插件 | 地图渲染和导航 |

### 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/                      # 数据模型
│   ├── user.dart               # 用户模型
│   ├── binding.dart            # 绑定关系模型
│   ├── navigation_task.dart    # 导航任务模型
│   └── location.dart           # 位置模型
├── services/                    # 服务层
│   ├── api_service.dart        # API 调用服务
│   └── auth_service.dart       # 认证服务
├── providers/                   # 状态管理
│   ├── user_provider.dart      # 用户状态
│   ├── binding_provider.dart   # 绑定状态
│   └── task_provider.dart      # 任务状态
├── screens/                     # 页面
│   ├── auth/                   # 认证模块
│   ├── binding/                # 绑定模块
│   ├── home/                   # 主页
│   ├── task/                   # 任务模块
│   └── location/               # 位置模块
└── widgets/                     # 通用组件
```

---

## 🚀 快速开始

### 1. 添加依赖

编辑 `pubspec.yaml`：

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP 请求
  http: ^1.2.0
  dio: ^5.4.0
  
  # 状态管理
  provider: ^6.1.2
  
  # 本地存储
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # 位置服务
  geolocator: ^13.0.2
  
  # 二维码
  qr_flutter: ^4.1.0
  mobile_scanner: ^3.5.5
  
  # 环境变量
  flutter_dotenv: ^5.1.0
  
  # 路由
  go_router: ^14.2.0
  
  # 工具
  intl: ^0.19.0  # 国际化
  uuid: ^4.3.0   # UUID 生成

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  
  # 代码生成
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
```

安装依赖：

```bash
flutter pub get
```

### 2. 生成模型代码

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. 配置环境变量

创建 `.env` 文件：

```env
CLOUDBASE_ENV_ID=qintu-cloudebase-5f5bpuj13bc6467
CLOUD_FUNCTION_URL=https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api
```

---

## 📱 核心功能实现

### 认证流程

```dart
// 1. 用户打开 App
// 2. 检查本地是否有 openid
// 3. 没有则调用 CloudBase Auth 进行手机验证码登录
// 4. 登录成功后，调用后端 /api/users/register 注册/登录
// 5. 保存 openid 到本地
```

### 绑定流程

```dart
// 发送者端：
// 1. 点击"绑定接收者"
// 2. 选择扫码或手动输入
// 3. 生成二维码或绑定码
// 4. 等待接收者确认

// 接收者端：
// 1. 点击"绑定发送者"
// 2. 扫码或输入绑定码
// 3. 调用 /api/bindings/confirm 确认绑定
// 4. 绑定成功，显示发送者信息
```

### 导航任务流程

```dart
// 发送者端：
// 1. 选择已绑定的接收者
// 2. 输入目的地，调用高德地图规划路线
// 3. 调用 /api/tasks 创建任务
// 4. 查看任务状态和接收者位置

// 接收者端：
// 1. 收到新任务通知
// 2. 查看任务详情（起点、终点、路线）
// 3. 点击"接受导航"
// 4. 点击"开始导航"
// 5. 导航中上传位置
// 6. 到达后完成任务
```

---

## 🎨 UI 设计规范

### 发送者端主页

```
┌─────────────────────────────┐
│ 亲途                        │
├─────────────────────────────┤
│ 我的绑定接收者 (2/5)        │
│ ┌───────────────────────┐  │
│ │ 👤 父亲  [+86 138***] │  │
│ │ 状态：导航进行中       │  │
│ │ [查看位置] [发路线]   │  │
│ └───────────────────────┘  │
│ ┌───────────────────────┐  │
│ │ 👤 母亲  [+86 139***] │  │
│ │ 状态：等待发送路线     │  │
│ │ [发路线]              │  │
│ └───────────────────────┘  │
│                             │
│ [+ 绑定新接收者]            │
└─────────────────────────────┘
```

### 接收者端主页

```
┌─────────────────────────────┐
│ 亲途                        │
├─────────────────────────────┤
│                             │
│   等待发送者发送路线...     │
│                             │
│   或                        │
│                             │
│   您有新的导航任务！        │
│   从：张三                  │
│   到：北京站                │
│   距离：15.3km  预计：32分钟│
│                             │
│   [接受导航]  [忽略]        │
│                             │
└─────────────────────────────┘
```

### 导航中界面（接收者）

```
┌─────────────────────────────┐
│ 导航进行中                  │
├─────────────────────────────┤
│                             │
│   ┌───────────────────┐    │
│   │                   │    │
│   │    地图视图        │    │
│   │   (高德地图)      │    │
│   │                   │    │
│   └───────────────────┘    │
│                             │
│   距离终点：5.3 km          │
│   预计时间：12 分钟         │
│                             │
│   [停止导航] [联系发送者]   │
│                             │
└─────────────────────────────┘
```

---

## 📡 API 调用示例

### 用户注册

```dart
final apiService = ApiService(
  baseUrl: Constants.baseUrl,
  openid: userOpenid,
);

final response = await apiService.registerUser(
  openid: userOpenid,
  phone: '+86 13800138000',
  nickname: '张三',
  userType: 'both',
);

if (response.isSuccess) {
  print('注册成功：${response.data}');
}
```

### 生成绑定码

```dart
final response = await apiService.generateBindCode(
  receiverPhone: '+86 13800138000',
  remark: '给父亲的绑定',
);

if (response.isSuccess) {
  final bindCode = response.data!['bind_code'] as String;
  print('绑定码：$bindCode');
}
```

### 创建导航任务

```dart
final response = await apiService.createNavigationTask(
  receiverOpenid: receiverOpenid,
  endName: '北京站',
  endLatitude: 39.9042,
  endLongitude: 116.4074,
  routeData: amapRouteData,
  transportMode: 'drive',
  distanceMeters: 15300,
  durationSeconds: 1920,
);

if (response.isSuccess) {
  print('任务创建成功');
}
```

---

## ⚠️ 注意事项

### 1. 权限配置

**Android** (`android/app/src/main/AndroidManifest.xml`)：

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** (`ios/Runner/Info.plist`)：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>此应用需要访问位置用于导航</string>
<key>NSCameraUsageDescription</key>
<string>此应用需要访问相机用于扫描二维码</string>
```

### 2. 高德地图集成

1. 注册高德地图开发者账号
2. 获取 API Key
3. 添加依赖：
   ```yaml
   dependencies:
     amap_flutter_map: ^3.0.0
     amap_flutter_location: ^3.0.0
     amap_flutter_navigation: ^3.0.0
   ```

### 3. 后台定位

为了实现导航时持续上传位置，需要配置后台定位：

**Android**：
- 使用前台服务（Foreground Service）
- 添加 `FOREGROUND_SERVICE` 权限

**iOS**：
- 配置 `Background Modes` → `Location updates`
- 使用 `allowsBackgroundLocationUpdates`

---

## 🧪 测试流程

### 1. 本地测试

```bash
# 启动云函数本地服务
cd functions/qintu-api
npm install
npm start

# 修改 App 配置使用本地服务器
# lib/utils/constants.dart
static const bool useLocalServer = true;

# 运行 Flutter App
flutter run
```

### 2. 测试绑定流程

1. 打开两个模拟器（或真机+模拟器）
2. 分别登录两个账号
3. 账号 A 生成绑定码
4. 账号 B 输入绑定码
5. 验证绑定成功

### 3. 测试导航流程

1. 账号 A（发送者）选择账号 B（接收者）
2. 输入目的地，规划路线
3. 发送导航任务
4. 账号 B 收到任务，点击接受
5. 账号 B 开始导航，上传位置
6. 账号 A 查看账号 B 的位置

---

## 📊 开发里程碑

### 阶段一：基础通信（1-2 天）

- [ ] 完成登录注册功能
- [ ] 实现绑定关系管理
- [ ] 实现二维码生成和扫描
- [ ] 测试绑定流程

### 阶段二：地图与导航（2-3 天）

- [ ] 集成高德地图
- [ ] 实现路线规划
- [ ] 实现导航任务创建和接收
- [ ] 调起高德导航组件

### 阶段三：前台保活（1-2 天）

- [ ] 实现 Android 前台服务
- [ ] 实现 iOS 后台定位
- [ ] 测试锁屏后持续上传位置

### 阶段四：监护与干预（1-2 天）

- [ ] 实现发送者查看位置
- [ ] 实现中途修改路线
- [ ] 实现远程结束导航

### 阶段五：优化与测试（2-3 天）

- [ ] UI 优化
- [ ] 错误处理增强
- [ ] 完整流程测试
- [ ] 性能优化

---

**文档版本**：v1.0.0  
**更新日期**：2026-04-04
