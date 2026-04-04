# 亲途 (Qintu) 项目开发规则与最佳实践

> **版本**：v1.0.0  
> **日期**：2026-04-04  
> **说明**：本文档是项目开发的最高指导原则，所有代码编写、功能实现必须遵守。

---

## 📋 目录
- [1. 文档驱动开发](#1-文档驱动开发)
- [2. 日志与隐私](#2-日志与隐私)
- [3. 架构与解耦](#3-架构与解耦)
- [4. 异常处理](#4-异常处理)
- [5. 代码规范与质量](#5-代码规范与质量)
- [6. 测试与发布](#6-测试与发布)
- [7. CloudBase 后端开发规范](#7-cloudbase-后端开发规范)

---

## 1. 文档驱动开发

### 1.1 文档先行
- **规划优先**：所有核心功能在编码前必须在 `docs/archive/` 下有线框图 (`WIREFRAMES.md`) 和交互流程 (`INTERACTION_FLOWS.md`)。
- **同步更新**：修改代码逻辑时，必须同步更新对应文档。如果文档与代码不符，视为 Bug。

### 1.2 经验沉淀
- **踩坑记录**：开发中遇到的环境配置、第三方库兼容性问题，必须记录到文档的 `技术实现要点` 章节，作为后续开发的避坑指南。

---

## 2. 日志与隐私

### 2.1 必须添加日志
- 关键路径（登录、绑定、网络请求、状态切换）必须打印日志。
- 使用分级日志工具（如 `Logs.app.info()`, `Logs.app.error()`）。
- **日志格式**：`[模块名] 操作描述, 关键参数: 值`。

### 2.2 隐私脱敏（红线）
- **日志脱敏**：绝对禁止在日志中打印完整手机号、密码、Token。必须使用脱敏函数（如 `138****5678`）。
- **UI 脱敏**：所有界面展示的敏感信息默认隐藏，支持“点击眼睛图标短暂显示”。
- **传输加密**：所有敏感数据传输必须通过 HTTPS。

---

## 3. 架构与解耦

### 3.1 严格分层
| 层级 | 职责 | 禁止事项 |
|------|------|----------|
| **View/UI** | 显示、布局、响应用户点击 | 禁止包含 API 调用、数据库操作、复杂计算 |
| **Provider/State** | 状态管理、调度业务逻辑 | 禁止直接操作 UI 组件实例 |
| **Service/Repo** | 网络请求、本地存储、SDK 封装 | 禁止包含 Flutter Widget 代码 |

### 3.2 组件化
- **拒绝巨型文件**：如果一个 UI 文件（Widget）超过 300 行，或者包含多个独立逻辑块（如：登录表单、验证码逻辑），必须拆分为更小的私有组件。
- **常量集中**：所有颜色、字体、字符串、API 路径必须从 `lib/constants/` 或 `lib/config/` 引用，禁止写死（Hardcode）。

---

## 4. 异常处理

### 4.1 不静默失败
- `try-catch` 捕获异常后：
  1.  **打印日志**：记录错误原因（Error Level）。
  2.  **用户反馈**：必须向用户展示明确的提示（如 SnackBar/Dialog）。
  3.  **状态恢复**：确保页面不会卡在 Loading 状态。

### 4.2 降级策略
- 网络请求失败时，提供重试机制或引导用户检查网络。
- 关键服务（如定位）不可用时，提供明确的引导设置入口。

---

## 5. 代码规范与质量

### 5.1 静态分析
- **强制命令**：每次功能开发完成后，提交前必须运行 `flutter analyze` 并通过。
- **代码清理**：消除所有 Unused import、Unused variable。

### 5.2 命名规范
- **类名**：大驼峰 (`ReceiverHomePage`)。
- **变量/方法**：小驼峰 (`fetchUserInfo`)。
- **私有成员**：下划线开头 (`_isLoading`)。
- **文件命名**：全小写下划线 (`user_repository.dart`)。

### 5.3 页面主题一致性（重要）
- **统一 AppBar 样式**：所有页面的顶部导航栏必须保持一致的高度、背景色和阴影效果。
- **统一颜色方案**：所有页面必须使用 `lib/constants/app_colors.dart` 定义的颜色常量，禁止硬编码颜色值。
- **统一字体大小**：相同类型的文本（标题、正文、按钮等）在所有页面中使用相同的字号。
- **统一间距规范**：页面边距、卡片间距、组件间距必须统一（如：页面内边距 16px，卡片间距 12px）。
- **统一圆角风格**：卡片、按钮、输入框的圆角大小必须保持一致（如：8px 或 12px）。
- **统一深色/浅色适配**：所有页面必须同时适配深色和浅色主题，使用 `Theme.of(context)` 动态获取颜色。

---

## 6. 测试与发布

### 6.1 开发者自测
- 编码完成后，必须确保代码可以成功编译（无语法错误）。
- 使用模拟数据或 Mock 验证业务逻辑闭环。

### 6.2 真机验收
- 核心功能（如：定位、导航、扫码、保活）必须在真机上进行验证。
- **提交节点**：每当完成一个 CheckList 节点（如阶段一），应生成一个可运行的构建供用户真机测试。

---

## 7. CloudBase 后端开发规范

### 7.0 优先使用 CloudBase 官方 API（重要原则）

**核心原则**：能使用 CloudBase 官方 API 实现的功能，绝不自己写后端。

**官方 API 优先的原因**：
- ✅ **官方维护**：由腾讯云开发团队维护，稳定性和安全性有保障
- ✅ **开箱即用**：无需自己实现复杂逻辑（如验证码防刷、Token 管理等）
- ✅ **成本更低**：减少云函数调用次数，降低服务器压力
- ✅ **更安全**：官方提供企业级安全防护（加密、限流、审计等）
- ✅ **易维护**：减少代码量，降低维护成本

**必须使用官方 API 的场景**：
| 功能 | 官方 API | 说明 |
|------|----------|------|
| **手机号验证码登录** | `/auth/v1/verification` | 发送验证码、验证、登录/注册 |
| **微信授权登录** | 官方 Auth 微信登录 | 自动获取 OpenID |
| **邮箱验证码登录** | 官方 Auth Email 登录 | 邮件验证码 |
| **Token 管理** | 官方 Auth Token API | 生成、刷新、验证 Token |
| **匿名登录** | 官方 Auth 匿名登录 | 临时用户身份 |

**适合自己实现云函数的场景**：
| 功能 | 说明 |
|------|------|
| **业务逻辑** | 用户管理、绑定关系、任务管理等 |
| **数据库操作** | MySQL 数据查询、更新、事务处理 |
| **自定义业务** | 导航路线计算、位置共享等 |

**错误示例**（❌ 不推荐）：
```javascript
// ❌ 错误：自己实现短信验证码登录
router.post('/api/auth/send-code', async (req, res) => {
  // 自己实现验证码生成、存储、发送...
});
```

**正确示例**（✅ 推荐）：
```dart
// ✅ 正确：直接调用 CloudBase 官方 Auth API
final response = await http.post(
  Uri.parse('https://$envId.api.tcloudbasegateway.com/auth/v1/verification'),
  headers: {'Authorization': 'Bearer $publishableKey'},
  body: jsonEncode({'phone_number': '+86 13800138000'}),
);
```

### 7.0.1 CloudBase 官方 Auth API 使用经验

**实际踩坑经验**（2026-04-05 验证）：

#### 发送验证码 API

**正确请求体**：
```json
{
  "phone_number": "+86 13800138000"
}
```

**⚠️ 关键注意事项**：
1. **只需 `phone_number` 字段**，不需要其他参数
2. ❌ **不要传 `target` 参数** - 会报错 `invalid value for enum type: "any"`
3. ❌ **不要传 `type` 参数** - 官方 API 不需要此字段
4. ✅ **手机号格式必须为 `"+86 13800138000"`**（带 "+86 " 前缀和空格）

**错误示例**（❌ 会失败）：
```dart
// ❌ 错误：多余的参数会导致 400 错误
body: jsonEncode({
  'phone_number': phoneNumber,
  'target': 'any',              // ❌ 错误：不支持此参数
  'type': 'phoneNumberLogin',   // ❌ 错误：不需要此参数
})
```

**正确示例**（✅ 已验证）：
```dart
// ✅ 正确：只包含必需的 phone_number 字段
body: jsonEncode({
  'phone_number': phoneNumber,  // 格式: "+86 13800138000"
})
```

#### 错误响应处理

官方 API 返回的错误格式：
```json
{
  "code": "INVALID_ARGUMENT",
  "error": "invalid_argument",
  "error_code": 3,
  "error_description": "详细的错误描述",
  "requestId": "xxx"
}
```

**处理建议**：
- 使用 `error['code']` 判断错误类型（如 `"INVALID_ARGUMENT"`）
- 使用 `error['error_description']` 获取详细错误信息
- 不要依赖 `error['error_code']` 数字码，可能不稳定

#### 成功响应格式

发送验证码成功返回：
```json
{
  "verification_id": "xxx",
  "expires_in": 600
}
```

验证验证码成功返回：
```json
{
  "verification_token": "xxx"
}
```

登录/注册成功返回：
```json
{
  "access_token": "xxx",
  "refresh_token": "xxx",
  "expires_in": 7200,
  "refresh_expires_in": 2592000,
  "uid": "xxx"
}
```

### 7.1 CloudBase CLI 部署流程
- **部署命令**：`cloudbase fn code update <函数名> --dir ./functions/<函数名>`
- **配置要求**：必须在 `cloudbaserc.json` 中正确配置函数信息：
  ```json
  {
    "functions": [
      {
        "name": "qintu-api",
        "runtime": "Nodejs18.15",
        "handler": "index.main",
        "installDependency": true,
        "functionCodePath": "qintu-api"
      }
    ]
  }
  ```
- **部署后验证**：部署完成后应立即检查云函数日志，确认无启动错误。

### 7.2 云函数开发规范
- **Express 框架**：使用 Express 作为 Web 框架，监听 9000 端口。
- **数据库操作**：使用 `mysql2/promise` 连接池，所有查询必须通过 `query()` 函数执行。
- **认证中间件**：所有需要认证的接口必须使用 `authMiddleware`，从请求头 `X-User-OpenID` 获取用户身份。
- **响应格式**：统一使用 `lib/response.js` 中的辅助函数（`success()`, `error()`, `validationError()` 等）。

### 7.3 数据库表结构管理
- **表名规范**：使用小写下划线（如 `users`, `user_bindings`, `navigation_tasks`）。
- **时间字段**：使用 `NOW()` 自动填充，避免手动传入时间戳。
- **软删除**：使用状态字段（如 `status = 'revoked'`）代替物理删除。

### 7.4 环境配置
- **环境变量**：敏感配置（数据库密码、密钥等）必须通过 CloudBase 环境变量管理，不得硬编码。
- **本地调试**：本地开发时设置 `useLocalServer = true`，指向 `localhost:9000`。

---

**文档版本**：v1.3.0
**更新日期**：2026-04-05
**维护人员**：开发团队
