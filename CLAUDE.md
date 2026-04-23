# 项目规则

> 每次对话自动加载，AI 必须遵守以下规则。

***

## 📖 文档定位

`docs/` 目录是给 AI 看的**交互/UI 参考和开发规范**，不是项目档案馆。

### 文档导航

| 场景       | 查阅文档                                   |
| -------- | -------------------------------------- |
| 写 UI/交互  | `docs/features/`                       |
| 写接口      | `docs/guides/API_CONTRACT.md`（以后端路由为准） |
| 状态管理     | 本文件中的架构规则                              |
| 部署       | `docs/operations/DEPLOY_GUIDE.md`      |
| 认证配置     | `docs/guides/AUTH_CONFIG.md`           |
| 高德地图     | `docs/guides/AMAP_GUIDE.md`            |
| MCP 工具技巧 | `docs/MCP_TIPS.md`                     |
| 上线前检查    | `docs/CHECKLIST.md`                    |

***

## 🏗️ 架构规则

### 前后端分离与环境解耦

- **环境管理唯一入口**：所有服务器地址切换必须通过 `EnvironmentManager`（`config/environments/environment_manager.dart`）
- **禁止硬编码 URL**：业务代码中禁止出现 `http://` 或 `https://` 开头的服务器地址，必须使用 `EnvironmentManager.baseUrl` 或 `ApiEndpoints`
- **API 端点统一**：所有网络请求路径必须在 `constants/api_endpoints.dart` 中定义，禁止在业务代码中拼接 URL 字符串
- **CloudBase 解耦**：
  - `CloudBaseConfig` 仅保留 `envId`、`baseUrl`、`gatewayUrl`、`publishableKey` 4 个属性
  - 禁止在业务代码中直接依赖 CloudBase SDK 进行数据请求，必须通过 `ApiClient`（HTTP API）
  - 前端业务逻辑（`features/`）不应感知底层是 CloudBase 还是自建 Node.js 服务器
- **配置职责分离**：
  - `config/environments/`：管理不同部署环境（Local/Test/Prod）的 URL 和调试开关
  - `constants/api_endpoints.dart`：管理 HTTP 路径常量
  - `constants/`：管理颜色、字符串、布局常量
- **后端可替换性**：更换服务器时，只需修改 `environments/` 下的环境配置，前端业务代码零改动

### Feature 模块四层架构

`features/` 下的功能模块统一遵循以下分层：

```
api 层      features/<name>/api/      纯 HTTP/原生 SDK 调用，无状态，无 Flutter 依赖
service 层 features/<name>/service/  纯业务逻辑，无状态，不继承 ChangeNotifier
provider 层 features/<name>/provider/  ChangeNotifier，持有 UI 状态，编排 service
ui 层       features/<name>/widgets/  纯 UI 渲染，只读 provider 状态，只调 provider 方法
```

**各层职责边界：**

- **api 层**：封装外部调用（高德 API、后端 HTTP），返回数据模型，不感知业务
- **service 层**：业务逻辑函数，输入数据 → 输出数据，不持有状态，不调用 `notifyListeners()`
- **provider 层**：持有 UI 所需状态，调用 service 编排流程，通过 `notifyListeners()` 驱动 UI 更新
- **ui 层**：`TextEditingController`、`FocusNode` 等本地 UI 状态可保留；跨 provider 协调（如同时调两个 provider）属于 UI 层职责

**模块自包含原则**：每个 feature 模块应包含该功能所需的全部资源（api、service、provider、widgets），避免跨 features 跳转。

**Provider 注入：** 在 feature 入口 widget（如 `auth_page.dart`）用 `MultiProvider` 注入，不在 `main.dart` 全局注册功能级 provider

**禁止：**
- service 层继承 `ChangeNotifier`
- ui 层包含业务判断逻辑（如"关键词长度 >= 2 才搜索"应在 service 层）
- provider 层直接调用 `lib/core/` 的 api（必须经过 service 层）

### 认证状态管理

- **唯一认证源**：`authStateProvider`（`providers/auth_state_manager.dart`）
- **已删除**：`UserProvider`，不要使用或重新创建
- **Token 安全**：Token 不存储在 Provider 状态中，仅存在于 `SecureStorage` 中

### Auth Feature 模块结构

```
lib/features/auth/
├── api/                      # API 层：HTTP 调用
│   ├── auth_api.dart        # 发送验证码、验证、登录注册
│   └── secure_storage.dart  # Token 安全存储
├── service/                  # Service 层：业务逻辑编排
│   └── auth_service.dart
├── provider/                  # Provider 层：UI 状态管理
│   └── auth_provider.dart
├── widgets/                   # UI 层
│   ├── auth_button.dart
│   ├── phone_input_card.dart
│   └── ...
└── auth_page.dart            # 入口 widget
```

### 依赖管理

- **已删除**：`geolocator`（位置服务）、`amap_flutter_map_plus_x`、`amap_flutter_base_plus`（高德 Flutter 插件）
- **已删除**：`lib/services/location_service.dart`、`lib/utils/coordinate_transform.dart`
- **定位实现**：直接使用高德 Android 原生 SDK（`AMapLocationClient`），通过 `AmapMapPlugin.kt` 桥接
- **地图显示**：使用 `AndroidView` + `PlatformViewFactory` 嵌入高德原生 `MapView`
- **蓝点定位**：使用高德原生 `MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER` 实现箭头蓝点
- **路线规划**：高德 Web REST API（`/v3/direction/driving`）
- **导航功能**：使用官方 `AmapNaviPage` 组件启动完整导航界面
- **禁止**：重新引入 `geolocator` 或任何 Flutter 地图插件

### 数据层

- **HTTP 客户端**：统一使用 `ApiClient`（`lib/core/http/api_client.dart`），基于 Dio
- **API 调用**：前端直接通过 `ApiClient` 调用后端，不经过 Repository 层
- **禁止**：在项目中重新引入 `http` 包或创建新的 HTTP 客户端

### Provider 注册

功能级 provider 在各自 feature 模块的入口 widget 中通过 `MultiProvider` 注入，**不再在 `main.dart` 全局注册**。

### Android 原生插件注册

- `MainActivity.configureFlutterEngine()` 中注册：
  - `AmapNavigationPlugin`（导航组件桥接）
  - `AmapMapPlugin`（地图显示 + 定位）
- **禁止**：在业务代码中直接调用 Platform Channel

### 主题管理

- **注册方式**：通过 `ChangeNotifierProvider.value` 注入
- **获取方式**：使用 `Provider.of<ThemeManager>(context, listen: false)`

### 错误处理

- **全局错误边界**：`main.dart` 中使用 `ErrorBoundary` 包裹整个应用
- **Widget 构建错误**：使用 `SafeErrorWidget` 处理构建异常
- **禁止**：让应用因未处理异常而白屏

### Token 刷新

- **自动刷新**：`TokenRefreshInterceptor` 自动处理 401 错误
- **实现位置**：`lib/core/http/token_refresh_interceptor.dart`
- **刷新接口**：`POST /api/auth/refresh-token`
- **禁止**：手动实现 Token 刷新逻辑

***

## 📡 API 契约规则

**以后端路由为准。** 写接口时遵守 `docs/guides/API_CONTRACT.md`。

核心三条：

1. 前端 `endpoint` 必须与后端 `routes/*.js` 路径逐字匹配
2. 查询参数/请求体字段名与后端读取的一致
3. 新增接口先对齐再写代码

***

## 🚀 云函数部署规则

### 使用 MCP 工具

**必须使用 MCP 工具或 CloudBase 控制台** 管理云函数和网关：

| 操作          | 正确方式                                        | 错误方式                                             |
| ----------- | ------------------------------------------- | ------------------------------------------------ |
| 创建 HTTP 云函数 | **CloudBase 控制台手动创建**                       | `cloudbase fn deploy` 或 `tcb fn deploy --httpFn` |
| 更新云函数代码     | `tcb fn deploy <name> --force`              | -                                                |
| 创建网关访问路径    | `manageGateway(action="createAccess", ...)` | `cloudbase service create`                       |
| 查询网关配置      | `queryGateway(action="getAccess", ...)`     | `cloudbase service list`                         |

### ⚠️ 重要发现

CloudBase CLI **无法正确创建 HTTP 类型的云函数**：

- 即使 `cloudbaserc.json` 中设置了 `"type": "HTTP"`
- 即使使用 `tcb fn deploy --httpFn --path /xxx`
- 创建的函数仍然是 Event 类型，返回 `FUNCTION_PARAM_INVALID` 错误

**唯一可靠的方法**：通过 CloudBase 控制台手动创建 HTTP 云函数

### HTTP 云函数部署要求

1. **函数类型**：`cloudbaserc.json` 中必须设置 `"type": "HTTP"`
2. **网关配置**：必须使用 `manageGateway(createAccess)` 注册访问路径
3. **传播等待**：网关配置后**至少等待 90 秒**才能测试
4. **类型不可变**：HTTP/Event 类型创建后不可更改，错误必须删除重建

### 常见错误处理

| 错误                       | 原因             | 解决                 |
| ------------------------ | -------------- | ------------------ |
| `INVALID_PATH`           | 网关未配置或传播中      | 检查网关，等待 90 秒       |
| `FUNCTION_PARAM_INVALID` | 函数类型错误         | 删除函数，重新创建为 HTTP 类型 |
| 超时 30 秒                  | 函数以 Event 模式运行 | 同上                 |

### 详细文档

完整部署流程和踩坑经验见：`docs/guides/flutter-call-cloud-function.md`

***

## 📝 文档规范

- docs 中的文档是**给 AI 看的开发指南**，不是历史档案馆
- 不写"修复总结"类的历史文档，写"以后怎么做"的规范文档
- 上线前清单放在 `docs/CHECKLIST.md`
- **文档自动更新规则**：遵守 `docs/DOC_UPDATE_RULES.md`
  - 重大重构（行数变化 >30%、架构变化、新增测试 >5 个）→ 自动更新文档
  - 小修改（样式、文案、注释）→ 不更新文档
  - 更新后立即验证代码无 issue

## Git 工作流规则

### Add 与 Commit 原则

**每修改一个文件就 add，但只有完成一件完整的小事时才 commit。**

一件完整的小事指：实现一个新功能、修复一个 bug、重构一段代码、添加一个新组件等不可分割的工作单元。

### 操作节奏

1. 事件A开始，涉及文件0、文件1、文件2
2. 每修改完一个文件，立即 `git add <file>`
3. 文件0、1、2 全部 add 完毕 → 事件A完成 → `git commit`
4. 开始事件B

### Commit 信息规范

Commit 信息描述**做的事**，而非改了什么文件：
- ✅ `refactor: 将 location_category_list 的 Service 调用下沉到 Provider 层`
- ✅ `fix: 修复登录后无法跳转的问题`
- ❌ `修改了 3 个文件`

### 为什么这样做

- **保持工作目录干净**：staging 区反映"正在进行"的工作
- **commit 信息准确**：所有相关文件都已 add，可以纵观全局后写准确的 message
- **方便临时搁置**：如果中途需要切换任务，工作目录状态清晰

## Added Memories

- 【上线前清单已迁移至文件】上线前检查清单已移至 docs/CHECKLIST.md，无需再从记忆读取。上线前让 AI 阅读该文件即可。
- 项目架构决策：完全统一发送者和接收者端页面，不再区分角色。统一主界面包含顶部Tab Bar（路线规划/关系绑定/设置），删除角色选择机制。绑定关系改为双向对等（A发送绑定请求给B，B确认后，两人自动互相绑定）。导航消息传递功能暂缓实现，先完善现有功能。
- 【架构更新 2026-04-21】Feature 模块采用自包含结构：`features/<name>/api/`、`features/<name>/service/`、`features/<name>/provider/`、`features/<name>/widgets/`。`lib/core/` 仅保留跨模块共享的基础设施（如 `ApiClient`、`http/`）。

