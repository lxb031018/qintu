# Qwen Code 项目规则

> 每次对话自动加载，AI 必须遵守以下规则。

---

## 📖 文档定位

`docs/` 目录是给 AI 看的**交互/UI 参考和开发规范**，不是项目档案馆。

- **写 UI/交互时** → 查 `docs/features/`
- **写接口时** → 遵守 `docs/guides/API_CONTRACT.md`（以后端路由为准）
- **状态管理时** → 遵守本文件中的架构规则
- **部署时** → 查 `docs/operations/DEPLOY_GUIDE.md`

---

## 🏗️ 架构规则

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
