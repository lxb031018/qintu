# 亲途 (Qintu) - Flutter 移动应用

## 📱 项目简介

"亲途"是一款解决老年群体"导航难"痛点的 Flutter 移动应用。通过"远程代操作"模式，将复杂的路径规划、路线修改等操作转移给子女，长辈仅需"一键接受"即可享受导航服务。

---

## ✅ 已完成的工作

### 1. 后端（云函数）- 100% ✅

**位置**: `functions/qintu-api/`

| 模块 | 接口数 | 状态 |
|------|--------|------|
| 用户管理 | 4 | ✅ 完成 |
| 绑定关系 | 5 | ✅ 完成（含人数限制） |
| 导航任务 | 9 | ✅ 完成 |
| 实时位置 | 3 | ✅ 完成 |
| **合计** | **21** | **✅ 全部完成** |

**特色功能**:
- ✅ 绑定人数限制（发送者 5 人，接收者 3 人）
- ✅ 严格的角色权限验证
- ✅ 完整的错误处理和日志
- ✅ 本地测试通过

### 2. 数据库 - 100% ✅

**位置**: `database/`

| 表名 | 用途 | 状态 |
|------|------|------|
| users | 用户信息 | ✅ |
| user_bindings | 绑定关系 | ✅ |
| navigation_tasks | 导航任务 | ✅ |
| real_time_locations | 实时位置 | ✅ |
| operation_logs | 操作日志 | ✅ |
| v_active_bindings | 视图：活跃绑定 | ✅ |
| v_pending_tasks | 视图：待处理任务 | ✅ |

### 3. Flutter 前端 - 60% ✅

#### 已完成模块

| 模块 | 文件 | 状态 |
|------|------|------|
| **数据模型** | `lib/models/` | ✅ 100% |
|  - User | `user.dart` | ✅ |
|  - Binding | `binding.dart` | ✅ |
|  - NavigationTask | `navigation_task.dart` | ✅ |
|  - Location | `location.dart` | ✅ |
| **API 服务** | `lib/services/` | ✅ 100% |
|  - ApiService | `api_service.dart` | ✅ 21 个接口 |
|  - ApiResponse | `api_response.dart` | ✅ |
| **状态管理** | `lib/providers/` | ✅ 50% |
|  - UserProvider | `user_provider.dart` | ✅ |
|  - BindingProvider | 待实现 | ⏳ |
|  - TaskProvider | 待实现 | ⏳ |
| **UI 页面** | `lib/screens/` | ✅ 40% |
|  - 登录页 | `auth/login_screen.dart` | ✅ |
|  - 主页（3 Tab） | `home/main_screen.dart` | ✅ |
|  - 主页 Tab | `home/home_tab.dart` | ✅ |
|  - 绑定 Tab | `home/binding_tab.dart` | ✅ |
|  - 设置 Tab | `home/settings_tab.dart` | ✅ |
| **工具模块** | `lib/utils/` | ✅ 100% |
|  - 日志 | `logger.dart` | ✅ |
|  - 常量 | `constants.dart` | ✅ |

#### 待实现模块

| 模块 | 说明 | 预计工作量 |
|------|------|-----------|
| 路线规划页 | 高德地图集成 + 路线预览 | 1-2 天 |
| 导航页 | 高德导航组件 + 前台保活 | 2-3 天 |
| 位置查看页 | 地图显示接收者位置 | 0.5 天 |
| 二维码生成/扫描 | qr_flutter + mobile_scanner | 0.5 天 |
| BindingProvider | 绑定状态管理 | 0.5 天 |
| TaskProvider | 任务状态管理 | 0.5 天 |

---

## 📁 项目结构

```
qintu/
├── functions/qintu-api/          # 云函数（后端）
│   ├── index.js                  # Express 入口
│   ├── routes/                   # 路由（21 个接口）
│   ├── lib/                      # 工具库
│   ├── middleware/               # 中间件
│   └── README.md                 # 部署文档
├── database/                     # 数据库
│   ├── init_schema.sql           # 建表脚本
│   └── README.md                 # 数据库文档
├── lib/                          # Flutter 代码
│   ├── main.dart                 # 应用入口
│   ├── models/                   # 数据模型
│   ├── services/                 # API 服务
│   ├── providers/                # 状态管理
│   ├── screens/                  # UI 页面
│   └── utils/                    # 工具类
├── docs/                         # 文档
│   ├── DEPLOYMENT_GUIDE.md       # 后端部署指南
│   ├── DEPLOY_STEPS.md           # 快速部署步骤
│   ├── flutter_implementation.md # Flutter 实现文档
│   ├── binding_limits.md         # 绑定限制说明
│   ├── LOGGER_GUIDE.md           # 日志使用指南
│   └── IMPLEMENTATION_SUMMARY.md # 实现总结
└── README.md                     # 本文件
```

---

## 🚀 快速开始

### 后端部署

1. **打包云函数**
   ```bash
   cd functions/qintu-api
   npm install
   ```

2. **上传到 CloudBase 控制台**
   - 环境：`qintu-cloudebase-5f5bpuj13bc6467`
   - 函数名：`qintu-api`
   - 运行环境：`Nodejs 16.13`

3. **配置环境变量**
   ```
   ENV_ID=qintu-cloudebase-5f5bpuj13bc6467
   DB_HOST=<MySQL 主机>
   DB_USER=<用户名>
   DB_PASSWORD=<密码>
   DB_NAME=qintu
   ```

4. **执行数据库脚本**
   - 复制 `database/init_schema.sql` 内容
   - 在 CloudBase MySQL 控制台执行

详见：`docs/DEPLOYMENT_GUIDE.md`

### Flutter 运行

1. **安装依赖**
   ```bash
   flutter pub get
   ```

2. **生成模型代码**（如需要）
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **运行应用**
   ```bash
   flutter run
   ```

---

## 🎨 UI 架构

```
底部导航栏（3 个 Tab）：
┌─────────────────────────────┐
│  🏠 主页  |  🔗 绑定  |  ⚙️ 设置  │
└─────────────────────────────┘
```

### 发送者端
- 主页：显示绑定接收者列表 + 发送路线按钮
- 绑定：管理绑定关系 + 生成绑定码/扫码
- 设置：个人资料 + 通知设置 + 退出登录

### 接收者端
- 主页：显示等待状态或导航任务
- 绑定：查看绑定信息
- 设置：个人资料 + 退出登录

---

## 📡 API 接口文档

详见：`functions/qintu-api/README.md`

### 核心接口示例

```dart
// 用户注册
await apiService.registerUser(
  openid: 'xxx',
  phone: '+86 13800138000',
  nickname: '张三',
  userType: 'both',
);

// 生成绑定码
await apiService.generateBindCode(
  receiverPhone: '+86 13800138000',
  remark: '给父亲的绑定',
);

// 创建导航任务
await apiService.createNavigationTask(
  receiverOpenid: 'xxx',
  endName: '北京站',
  endLatitude: 39.9042,
  endLongitude: 116.4074,
  routeData: {...},
);
```

---

## 🛠️ 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| **前端框架** | Flutter | 3.x |
| **状态管理** | Provider | 6.1.2 |
| **网络请求** | http + dio | 1.2.0 + 5.4.0 |
| **后端** | Node.js + Express | 16+ |
| **数据库** | MySQL | 5.7+ |
| **云平台** | CloudBase | - |

---

## 📊 开发里程碑

### 阶段一：基础通信 ✅（已完成）
- [x] 登录注册
- [x] 绑定关系管理
- [x] 后端 API 完成

### 阶段二：地图与导航 ⏳（进行中）
- [ ] 高德地图集成
- [ ] 路线规划
- [ ] 导航任务 UI

### 阶段三：前台保活 ⏳
- [ ] Android 前台服务
- [ ] iOS 后台定位

### 阶段四：优化与测试 ⏳
- [ ] UI 优化
- [ ] 完整流程测试
- [ ] 性能优化

---

## 📝 文档索引

| 文档 | 路径 | 说明 |
|------|------|------|
| 后端部署指南 | `docs/DEPLOYMENT_GUIDE.md` | 详细部署步骤 |
| 快速部署步骤 | `DEPLOY_STEPS.md` | 精简版部署清单 |
| Flutter 实现文档 | `docs/flutter_implementation.md` | UI 设计规范 |
| 绑定限制说明 | `docs/binding_limits.md` | 绑定人数限制 |
| 日志使用指南 | `docs/LOGGER_GUIDE.md` | Logger 模块文档 |
| 实现总结 | `docs/IMPLEMENTATION_SUMMARY.md` | 完成度总结 |
| 云函数文档 | `functions/qintu-api/README.md` | API 接口文档 |
| 数据库文档 | `database/README.md` | 数据库部署指南 |

---

## ⚠️ 注意事项

### 权限配置

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>此应用需要访问位置用于导航</string>
<key>NSCameraUsageDescription</key>
<string>此应用需要访问相机用于扫描二维码</string>
```

---

## 🤝 贡献指南

1. 后端代码：`functions/qintu-api/`
2. Flutter 代码：`lib/`
3. 数据库脚本：`database/`
4. 文档：`docs/`

---

## 📞 联系方式

- **CloudBase 环境**: `qintu-cloudebase-5f5bpuj13bc6467`
- **项目版本**: v1.0.0
- **更新日期**: 2026-04-04

---

**亲途** - 让导航更简单，让关爱更直接。 ❤️
