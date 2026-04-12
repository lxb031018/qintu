# Qwen Code 项目规则

> 每次对话自动加载，AI 必须遵守以下规则。

---

## 📖 文档定位

`docs/` 目录是给 AI 看的**交互/UI 参考和开发规范**，不是项目档案馆。

### 文档导航

| 场景 | 查阅文档 |
|------|---------|
| 写 UI/交互 | `docs/features/` |
| 写接口 | `docs/guides/API_CONTRACT.md`（以后端路由为准） |
| 状态管理 | 本文件中的架构规则 |
| 部署 | `docs/operations/DEPLOY_GUIDE.md` |
| 认证配置 | `docs/guides/AUTH_CONFIG.md` |
| 高德地图 | `docs/guides/AMAP_GUIDE.md` |
| MCP 工具技巧 | `docs/MCP_TIPS.md` |
| 上线前检查 | `docs/CHECKLIST.md` |

---

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

### 认证状态管理
- **唯一认证源**：`AuthStateManager`（`managers/auth_state_manager.dart`）
- **已删除**：`UserProvider`，不要使用或重新创建
- **注册方式**：`main.dart` 中通过 `ChangeNotifierProvider.value` 注入
- **Token 安全**：Token 不存储在 Provider 状态中，仅存在于 `SecureStorage` 中
- **禁止**：通过 ServiceLocator 获取 AuthStateManager

### 依赖注入
- **已删除**：`GetIt`/`ServiceLocator`（未使用，增加认知负担）
- **状态管理**：使用 `Provider` 进行依赖注入
- **单例服务**：`ApiClient` 使用私有构造函数实现单例
- **禁止**：重新引入 `GetIt` 或创建新的 ServiceLocator

### 数据层
- **已删除**：`lib/data/` 目录（RepositoryManager 及空壳 Repository）
- **API 调用**：前端直接通过 `ApiClient`（基于 Dio）调用后端，不经过 Repository 层
- **HTTP 客户端**：统一使用 `ApiClient`（`services/api_client.dart`），基于 Dio，已删除 `ApiService`（http）
- **禁止**：在项目中重新引入 `http` 包或创建新的 HTTP 客户端

### Provider 注册
- `main.dart` 的 `MultiProvider` 中注册：
  - `BindingProvider`
  - `AuthStateManager`（通过 `.value`）
  - `ThemeManager`（通过 `.value`）
- 不要再添加 `UserProvider`

### 主题管理
- **已移除单例**：`ThemeManager` 不再使用单例模式
- **注册方式**：通过 `ChangeNotifierProvider.value` 注入
- **获取方式**：使用 `Provider.of<ThemeManager>(context, listen: false)`
- **禁止**：使用 `ThemeManager.instance`

### 错误处理
- **全局错误边界**：`main.dart` 中使用 `ErrorBoundary` 包裹整个应用
- **Widget 构建错误**：使用 `SafeErrorWidget` 处理构建异常
- **禁止**：让应用因未处理异常而白屏

### Token 刷新
- **自动刷新**：`TokenRefreshInterceptor` 自动处理 401 错误
- **实现位置**：`lib/services/token_refresh_interceptor.dart`
- **刷新接口**：`POST /api/auth/refresh-token`
- **禁止**：手动实现 Token 刷新逻辑

---

## 📡 API 契约规则

**以后端路由为准。** 写接口时遵守 `docs/guides/API_CONTRACT.md`。

核心三条：
1. 前端 `endpoint` 必须与后端 `routes/*.js` 路径逐字匹配
2. 查询参数/请求体字段名与后端读取的一致
3. 新增接口先对齐再写代码

---

## 🚀 云函数部署规则

### 使用 MCP 工具（不要用 CLI）

**必须使用 MCP 工具或 CloudBase 控制台** 管理云函数和网关，CLI 工具不可靠：

| 操作 | 正确方式 | 错误方式 |
|------|---------|---------|
| 创建 HTTP 云函数 | **CloudBase 控制台手动创建** | `cloudbase fn deploy` 或 `tcb fn deploy --httpFn` |
| 更新云函数代码 | `tcb fn deploy <name> --force` | - |
| 创建网关访问路径 | `manageGateway(action="createAccess", ...)` | `cloudbase service create` |
| 查询网关配置 | `queryGateway(action="getAccess", ...)` | `cloudbase service list` |

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

| 错误 | 原因 | 解决 |
|------|------|------|
| `INVALID_PATH` | 网关未配置或传播中 | 检查网关，等待 90 秒 |
| `FUNCTION_PARAM_INVALID` | 函数类型错误 | 删除函数，重新创建为 HTTP 类型 |
| 超时 30 秒 | 函数以 Event 模式运行 | 同上 |

### 详细文档

完整部署流程和踩坑经验见：`docs/guides/flutter-call-cloud-function.md`

---

## 📝 文档规范

- docs 中的文档是**给 AI 看的开发指南**，不是历史档案馆
- 不写"修复总结"类的历史文档，写"以后怎么做"的规范文档
- 上线前清单放在 `docs/CHECKLIST.md`
- **文档自动更新规则**：遵守 `docs/DOC_UPDATE_RULES.md`
  - 重大重构（行数变化 >30%、架构变化、新增测试 >5 个）→ 自动更新文档
  - 小修改（样式、文案、注释）→ 不更新文档
  - 更新后立即验证代码无 issue

## Qwen Added Memories
- 【上线前清单已迁移至文件】上线前检查清单已移至 docs/CHECKLIST.md，无需再从记忆读取。上线前让 AI 阅读该文件即可。
- 项目架构决策：完全统一发送者和接收者端页面，不再区分角色。统一主界面包含顶部Tab Bar（路线规划/关系绑定/设置），删除角色选择机制。绑定关系改为双向对等（A绑定B确认后，两人自动互相绑定）。导航消息传递功能暂缓实现，先完善现有功能。
