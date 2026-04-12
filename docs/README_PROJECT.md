# 亲途 (Qintu) - Flutter 移动应用

## 📱 项目简介

"亲途"是一款解决老年群体"导航难"痛点的 Flutter 移动应用。通过"远程代操作"模式，将复杂的路径规划、路线修改等操作转移给子女，长辈仅需"一键接受"即可享受导航服务。

**设计理念**：所有人使用同一套界面，不再区分"发送者"和"接收者"角色。会用的年轻人自然使用所有功能，不会用的老人不接触看不懂的按钮即可。

---

## ✅ 当前完成状态

### 1. 后端（云函数）- 100% ✅

**位置**: `functions/qintu-api/`

| 模块 | 接口数 | 状态 |
|------|--------|------|
| 用户管理 | 4 | ✅ 完成 |
| 绑定关系 | 9 | ✅ 完成（含人数限制、双向对等） |
| 导航任务 | 9 | ✅ 完成 |
| 实时位置 | 3 | ✅ 完成 |
| **合计** | **25** | **✅ 全部完成** |

### 2. 数据库 - 100% ✅

| 表名 | 用途 | 状态 |
|------|------|------|
| users | 用户信息 | ✅ |
| user_bindings | 绑定关系 | ✅ |
| navigation_tasks | 导航任务 | ✅ |
| real_time_locations | 实时位置 | ✅ |
| operation_logs | 操作日志 | ✅ |
| v_active_bindings | 视图：活跃绑定 | ✅ |
| v_pending_tasks | 视图：待处理任务 | ✅ |

### 3. Flutter 前端 - 75% ✅

#### 已完成模块

| 模块 | 状态 | 说明 |
|------|------|------|
| **认证系统** | ✅ 100% | 手机号验证码登录，Token 持久化（一次登录永久保持） |
| **统一主页** | ✅ 100% | 顶部 3 Tab 架构（路线规划/关系绑定/设置），不区分角色 |
| **绑定管理** | ✅ 100% | 双向对等绑定，通知中心管理请求状态 |
| **主题系统** | ✅ 100% | 浅色/深色模式，字体缩放，双击切换 Tab |
| **路由守卫** | ✅ 100% | GoRouter + 认证检查 redirect |
| **环境管理** | ✅ 100% | 多环境切换（Local/Test/Prod） |
| **设置页** | ✅ 100% | 主题、字体、Tab 切换模式、退出登录、环境切换 |
| 路线规划 | ⏳ 50% | 高德地图基础集成，UI 完成 |
| 导航功能 | ⏳ 0% | 待实现 |

---

## 📁 项目结构

```
qintu/
├── functions/qintu-api/          # 云函数（后端）
│   ├── index.js                  # Express 入口
│   ├── routes/                   # 路由（25 个接口）
│   │   ├── users.js              # 用户管理
│   │   ├── bindings-memory.js    # 绑定关系（内存版，本地开发用）
│   │   ├── bindings.js           # 绑定关系（MySQL 版，生产用）
│   │   ├── tasks.js              # 导航任务
│   │   └── locations.js          # 位置管理
│   ├── lib/                      # 工具库
│   ├── middleware/               # 中间件（auth 认证）
│   └── README.md                 # 部署文档
├── database/                     # 数据库
│   ├── init_schema.sql           # 建表脚本
│   └── README.md                 # 数据库文档
├── lib/                          # Flutter 代码
│   ├── main.dart                 # 应用入口
│   ├── config/                   # 配置管理
│   │   ├── environments/         # 多环境管理
│   │   ├── auth_config.dart      # Token 有效期配置
│   │   ├── amap_config.dart      # 高德地图配置
│   │   └── ui_config.dart        # UI 布局配置
│   ├── constants/                # 常量定义
│   │   ├── api_endpoints.dart    # API 端点路径
│   │   ├── app_colors.dart       # 颜色系统（珊瑚橙主色调）
│   │   ├── app_strings.dart      # 所有界面文字
│   │   └── storage_keys.dart     # 存储键名
│   ├── features/                 # 功能模块
│   │   ├── auth/                 # 认证模块（登录/注册）
│   │   ├── binding/              # 绑定关系模块
│   │   │   ├── binding_page.dart         # 绑定管理页
│   │   │   ├── requests/                 # 请求管理
│   │   │   │   ├── notification_center_page.dart  # 通知中心
│   │   │   │   └── widgets/              # 请求卡片组件
│   │   │   └── widgets/                  # 绑定对话框等
│   │   ├── home/                 # 主页模块
│   │   │   ├── unified_home_page.dart    # 统一主页（顶部Tab）
│   │   │   └── tabs/                     # 三个Tab页面
│   │   │       ├── route_planning_tab.dart  # 路线规划Tab
│   │   │       └── widgets/              # 地图等组件
│   │   ├── settings/             # 设置模块
│   │   │   ├── settings_page.dart         # 设置主页
│   │   │   └── widgets/                   # 设置卡片组件
│   │   └── common/               # 通用组件
│   │       └── splash_screen.dart         # 启动页
│   ├── models/                   # 数据模型（Freezed）
│   ├── providers/                # 状态管理（Provider）
│   │   ├── auth_state_manager.dart   # 认证状态
│   │   ├── binding_provider.dart     # 绑定状态
│   │   ├── settings_manager.dart     # 设置状态
│   │   └── theme_manager.dart        # 主题管理
│   ├── router/                   # 路由配置（GoRouter）
│   ├── services/                 # 服务层
│   │   ├── api_client.dart           # HTTP客户端（Dio单例）
│   │   ├── auth_service.dart         # 认证服务
│   │   ├── secure_storage.dart       # 安全存储
│   │   └── token_refresh_interceptor.dart # Token刷新
│   ├── theme/                    # 主题配置
│   └── utils/                    # 工具类
├── docs/                         # 文档
│   ├── CHECKLIST.md              # 上线前检查清单
│   ├── guides/                   # 开发指南
│   │   ├── API_CONTRACT.md       # API契约规范
│   │   ├── AUTH_CONFIG.md        # 认证配置
│   │   └── AMAP_GUIDE.md         # 高德地图集成
│   ├── architecture/             # 架构文档
│   │   ├── PROJECT_ARCHITECTURE.md  # 项目架构
│   │   └── FRONTEND_DEVELOPMENT.md  # 前端开发规范
│   ├── features/                 # 功能文档
│   │   ├── binding_limits.md     # 绑定限制说明
│   │   └── BINDING_TAB_FEATURES.md  # 绑定Tab功能
│   └── operations/               # 运维文档
│       └── DEPLOY_GUIDE.md       # 部署指南
└── pubspec.yaml                  # Flutter 依赖
```

---

## 🚀 快速开始

### 后端部署

1. **本地开发（推荐）**
   ```bash
   cd functions/qintu-api
   npm install
   node index.js
   ```

2. **CloudBase 部署**
   - 环境：`qintu-cloudebase-5f5bpuj13bc6467`
   - 函数名：`qintu-api`
   - 运行环境：`Nodejs 16.13`
   - **必须通过 CloudBase 控制台手动创建 HTTP 类型云函数**

详见：`docs/operations/DEPLOY_GUIDE.md`

### Flutter 运行

1. **安装依赖**
   ```bash
   flutter pub get
   ```

2. **运行应用**
   ```bash
   flutter run
   ```

---

## 🎨 UI 架构

### 顶部 Tab Bar 架构（防止老人误触）

```
┌─────────────────────────────┐
│  🗺️路线规划 | 🔗关系绑定 | ⚙️设置  │  ← 顶部Tab
├─────────────────────────────┤
│                             │
│        内容区域              │
│    (TabBarView 切换)         │
│                             │
└─────────────────────────────┘
```

**双击切换机制**：
- 默认开启双击切换 Tab（防止老人误触）
- 单击时显示提示"💡 双击顶部标签切换页面"
- 双击才切换到对应 Tab
- 设置中可关闭双击模式，改为单击切换

### 三个 Tab 页面

| Tab | 内容 | 状态 |
|-----|------|------|
| 路线规划 | 高德地图 + 起点终点输入 | ⏳ 基础完成 |
| 关系绑定 | 绑定列表 + 通知中心 | ✅ 完成 |
| 设置 | 主题、字体、退出登录 | ✅ 完成 |

---

## 🔐 认证系统

### 登录流程

```
输入手机号 → 获取验证码 → 输入验证码 → 自动登录/注册
```

- 固定验证码：`123456`（本地开发环境）
- Token 持久化：一次登录，永久保持（Refresh Token 10年有效期）
- 自动刷新：`TokenRefreshInterceptor` 自动处理 401 错误

### 主题颜色

| 元素 | 浅色模式 | 深色模式 |
|------|---------|---------|
| 主色调 | 珊瑚橙 `#FF8C69` | 珊瑚橙 `#FF8C69` |
| 背景 | 奶油白 `#FFF8F0` | 深蓝灰 `#121212` |
| 卡片 | 纯白 `#FFFFFF` | 深灰 `#242424` |

---

## 🔄 绑定关系

### 双向对等绑定

```
A 发送绑定请求给 B → B 确认 → A 和 B 互相绑定
```

- A 绑定 B 确认后，A 和 B 自动互相绑定
- 不再区分"发送者"和"接收者"角色
- 每个人都能看到所有功能

### 绑定请求状态

| 状态 | 说明 | 显示位置 |
|------|------|---------|
| pending | 等待对方确认 | 发出请求Tab |
| active | 已生效 | 绑定列表 |
| revoked | 已取消/被拒绝 | 被拒绝请求Tab |
| expired | 已过期 | 发出请求Tab |

### 通知中心

三个 Tab 管理所有绑定请求：

| Tab | 内容 |
|-----|------|
| 发出请求 | 我发出的绑定请求（pending/active/expired） |
| 收到请求 | 待确认的绑定请求（可确认/拒绝） |
| 被拒绝 | 我发出的请求被对方拒绝 |

### 绑定限制

- 每个用户最多绑定 **5** 人（作为发送者）
- 每个用户最多被绑定 **3** 人（作为接收者）
- pending 请求 7 天自动过期

---

## 🛠️ 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| **前端框架** | Flutter | 3.x |
| **状态管理** | Provider | 6.x |
| **网络请求** | Dio | 5.x |
| **路由** | GoRouter | 14.x |
| **数据模型** | Freezed + JsonSerializable | - |
| **安全存储** | flutter_secure_storage | 9.x |
| **后端** | Node.js + Express | 16+ |
| **数据库** | MySQL | 5.7+ |
| **云平台** | CloudBase | - |
| **地图** | 高德地图 | - |

---

## 📊 开发里程碑

### 阶段一：基础通信 ✅（已完成）
- [x] 登录注册（Token 持久化）
- [x] 绑定关系管理（双向对等）
- [x] 通知中心（请求状态管理）
- [x] 主题系统（浅色/深色）
- [x] 统一主页（顶部Tab架构）

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
| 上线前检查 | `docs/CHECKLIST.md` | 发布前必查清单 |
| API 契约 | `docs/guides/API_CONTRACT.md` | 前后端接口对齐 |
| 认证配置 | `docs/guides/AUTH_CONFIG.md` | 登录认证详解 |
| 高德地图 | `docs/guides/AMAP_GUIDE.md` | 地图集成指南 |
| 项目架构 | `docs/architecture/PROJECT_ARCHITECTURE.md` | 架构设计 |
| 前端开发 | `docs/architecture/FRONTEND_DEVELOPMENT.md` | 开发规范 |
| 绑定限制 | `docs/features/binding_limits.md` | 绑定人数限制 |
| 部署指南 | `docs/operations/DEPLOY_GUIDE.md` | 后端部署 |
| 双设备测试 | `docs/TWO_DEVICE_TEST_GUIDE.md` | 本地测试指南 |

---

## ⚠️ 注意事项

### CloudBase 云函数部署

- **必须通过 CloudBase 控制台手动创建 HTTP 类型云函数**
- CLI 工具无法正确创建 HTTP 类型函数
- 网关配置后需等待 90 秒传播
- 详见：`docs/operations/DEPLOY_GUIDE.md`

### 环境管理

- 所有服务器地址通过 `EnvironmentManager` 统一管理
- 禁止硬编码 URL
- 支持 4 种环境：Local / Test / CloudBaseTest / CloudBaseProd

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
- **更新日期**: 2026-04-11

---

**亲途** - 让导航更简单，让关爱更直接。 ❤️
