# Flutter 前端调用 CloudBase 云函数指南

本文档记录了从 Flutter 前端调用 CloudBase 云函数的完整流程，基于 hello-api 测试函数的实际验证经验。

---

## 架构概览

Flutter（原生应用）**不使用 CloudBase SDK**，而是通过 **HTTP API** 直接访问 CloudBase 云函数。

```
Flutter App (Dio HTTP Client)
    |
    v
CloudBase 服务网关
    |  URL 格式: https://{envId}.service.tcloudbase.com/{函数名}/{路径}
    v
HTTP 云函数 (Express on Node.js, port 9000)
    |
    v
数据库 / 其他服务
```

### 两种访问地址

| 用途 | URL 格式 | 示例 |
|------|----------|------|
| 业务 API（云函数） | `https://{envId}.service.tcloudbase.com/{函数名}` | `https://qintu-...com/qintu-api` |
| 认证 API（CloudBase Auth） | `https://{envId}.api.tcloudbasegateway.com` | `https://qintu-...com/auth/v1/...` |

---

## 完整流程：从创建到调用

### 第一步：创建云函数

在 `functions/` 目录下创建云函数目录，包含以下文件：

**`functions/hello-api/index.js`**：

```javascript
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// 定义路由
app.get('/hello', (req, res) => {
  res.json({
    message: 'Hello World!',
    timestamp: new Date().toISOString(),
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// 必须监听 9000 端口（CloudBase 要求）
const PORT = process.env.PORT || 9000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`服务启动: 0.0.0.0:${PORT}`);
});

// 导出云函数入口
exports.main = app;
```

**`functions/hello-api/package.json`**：

```json
{
  "name": "hello-api",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
```

### 第二步：注册函数配置

在 `cloudbaserc.json` 中添加函数配置：

```json
{
  "name": "hello-api",
  "runtime": "Nodejs18.15",
  "handler": "index.main",
  "installDependency": true,
  "functionCodePath": "hello-api",
  "type": "HTTP",
  "timeout": 10,
  "memorySize": 256
}
```

关键字段说明：
- `type: "HTTP"` — HTTP 云函数，可通过 URL 直接访问（Event 类型只能通过 SDK 调用）
- `runtime` — 运行时，创建后不可更改
- `handler: "index.main"` — 入口为 `exports.main`

### 第三步：部署云函数

使用 CloudBase MCP 工具部署：

```
manageFunctions(action="createFunction", func={name:"hello-api", ...}, functionRootPath="d:/AllCodes/qintu/functions")
```

如果函数已存在，使用 `updateFunctionCode` 更新代码。

### 第四步：配置网关访问路径

**这一步很容易遗漏！** HTTP 云函数需要在网关注册访问路径，否则外部无法访问。

```
manageGateway(action="createAccess", targetName="hello-api", targetType="function", path="/hello-api", type="HTTP")
```

参数说明：
- `path` — URL 中的路径前缀，如 `/hello-api`
- `type: "HTTP"` — 必须与函数类型匹配
- `auth: false` — 不需要 CloudBase 鉴权（公开访问）

**重要：网关路由传播需要 30 秒到 3 分钟，不要立即测试！**

验证网关配置：

```
queryGateway(action="getAccess", targetName="hello-api", targetType="function")
```

返回的 `urls` 字段即为可访问的完整 URL。

### 第五步：验证云函数

```bash
# 测试 hello 端点
curl https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/hello-api/hello

# 预期响应
# {"message":"Hello World!","timestamp":"2026-04-09T05:09:03.302Z","env":"production"}

# 测试健康检查
curl https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/hello-api/health

# 预期响应
# {"status":"ok"}
```

### 第六步：Flutter 前端调用

Flutter 中使用 Dio 发起 HTTP 请求：

```dart
import 'package:dio/dio.dart';

// 构造请求 URL
// 格式：https://{envId}.service.tcloudbase.com/{函数名}/{路由路径}
final url = 'https://$envId.service.tcloudbase.com/hello-api/hello';

// 发起 GET 请求
final dio = Dio();
final response = await dio.get<Map<String, dynamic>>(url);

// 解析响应
final message = response.data?['message']; // "Hello World!"
```

**为什么不用共享的 ApiClient 单例？**

项目中的 `ApiClient` 单例 baseUrl 指向 `qintu-api` 函数，且自动注入 token。调用不同云函数时，需要：
- 创建独立的 Dio 实例（如上面的示例）
- 或者临时修改 ApiClient 的 baseUrl

---

## URL 路径映射规则

CloudBase HTTP 云函数的 URL 映射：

```
https://{envId}.service.tcloudbase.com/{网关path}/{Express路由}
                                                    |
                                                    v
                                              云函数内的路由路径
```

以 hello-api 为例：

| 网关 path | Express 路由 | 完整 URL |
|-----------|-------------|----------|
| `/hello-api` | `/hello` | `https://...com/hello-api/hello` |
| `/hello-api` | `/health` | `https://...com/hello-api/health` |

以 qintu-api 为例（网关 path 为 `/api`）：

| 网关 path | Express 路由 | 完整 URL |
|-----------|-------------|----------|
| `/api` | `/api/users/me` | `https://...com/api/api/users/me` |

> 注意：qintu-api 的网关 path 是 `/api`，而 Express 内部路由也以 `/api` 开头，所以最终 URL 包含两次 `/api`。这也是为什么 Flutter 配置中 `serviceUrl` 是 `https://...com/qintu-api` 而不是 `https://...com/api`——实际工作的是另一种访问方式。

---

## 踩坑记录（必读！）

### 坑 1：CLI 工具创建的 HTTP 服务类型错误

**问题**：使用 `cloudbase service create` 命令创建的 HTTP 访问服务，其触发器类型显示为 **"Cloud hosting"** 而不是 **"Cloud function"**。

**症状**：
```bash
# 使用 CLI 创建
cloudbase service create -e <envId> -p /hello-api -f hello-api

# 查看服务列表，发现类型错误
cloudbase service list -e <envId>
# 显示：Trigger type: Cloud hosting  ← 错误！应该是 Cloud function
```

**解决方案**：
使用 **MCP 工具** `manageGateway` 而不是 CLI 命令：
```
manageGateway(action="createAccess", targetName="hello-api", targetType="function", path="/hello-api", type="HTTP")
```

---

### 坑 2：云函数类型一旦创建不可更改

**问题**：CloudBase 的云函数类型（HTTP vs Event）在创建后**无法修改**。

**症状**：
- 云函数被错误创建为 Event 类型
- 即使配置了网关访问路径，访问时仍返回 `FUNCTION_PARAM_INVALID` 错误
- 云函数日志显示 `Invoking task timed out after 30 seconds`

**解决方案**：
1. 删除错误的云函数：`tcb fn delete <functionName> -e <envId>`
2. **通过 CloudBase 控制台手动创建 HTTP 云函数**（CLI 不可靠）
3. 上传代码包（functions/qintu-api 目录内容）
4. 使用 MCP 工具配置网关：`manageGateway(action="createAccess", ...)`

**重要**：
- ⚠️ 部署时 `type: "HTTP"` 必须写在 `cloudbaserc.json` 中
- ⚠️ 已部署的 Event 函数无法通过更新代码变为 HTTP 函数
- ⚠️ 必须删除后重新创建
- ⚠️ **CLI 的 `--httpFn` 参数不可靠**，即使使用 `tcb fn deploy --httpFn --path /xxx` 也会创建为 Event 函数
- ⚠️ **唯一可靠的方法是通过 CloudBase 控制台手动创建 HTTP 云函数**

---

### 坑 3：网关传播时间比预期长

**问题**：文档说网关传播需要 30 秒到 3 分钟，但实际测试中：
- 35 秒：仍返回 `INVALID_PATH`
- 60 秒：仍返回 `INVALID_PATH`
- **90 秒**：终于成功 ✅

**建议等待时间**：**至少等待 90 秒** 再进行测试，不要过早放弃。

**验证方法**：
```bash
# 等待 90 秒后测试
sleep 90 && curl https://<envId>.service.tcloudbase.com/<path>/health
```

---

### 坑 4：错误代码对照表

| 错误代码 | 原因 | 解决方法 |
|---------|------|---------|
| `INVALID_PATH` | 网关未配置或传播中 | 检查网关配置，等待 90 秒 |
| `FUNCTION_PARAM_INVALID` | 函数类型错误（Event vs HTTP） | 删除函数，重新创建为 HTTP 类型 |
| 超时 30 秒 | 函数以 Event 模式运行 | 同 `FUNCTION_PARAM_INVALID` |

---

## 踩坑记录（必读！）

### 坑 1：CLI 工具创建的 HTTP 服务类型错误

**问题**：使用 `cloudbase service create` 命令创建的 HTTP 访问服务，其触发器类型显示为 **"Cloud hosting"** 而不是 **"Cloud function"**。

**症状**：
```bash
# 使用 CLI 创建
cloudbase service create -e <envId> -p /hello-api -f hello-api

# 查看服务列表，发现类型错误
cloudbase service list -e <envId>
# 显示：Trigger type: Cloud hosting  ← 错误！应该是 Cloud function
```

**解决方案**：
使用 **MCP 工具** `manageGateway` 而不是 CLI 命令：
```
manageGateway(action="createAccess", targetName="hello-api", targetType="function", path="/hello-api", type="HTTP")
```

---

### 坑 2：云函数类型一旦创建不可更改

**问题**：CloudBase 的云函数类型（HTTP vs Event）在创建后**无法修改**。

**症状**：
- 云函数被错误创建为 Event 类型
- 即使配置了网关访问路径，访问时仍返回 `FUNCTION_PARAM_INVALID` 错误
- 云函数日志显示 `Invoking task timed out after 30 seconds`

**解决方案**：
1. 删除错误的云函数：`tcb fn delete <functionName> -e <envId>`
2. **通过 CloudBase 控制台手动创建 HTTP 云函数**（CLI 不可靠）
3. 上传代码包（functions/qintu-api 目录内容）
4. 使用 MCP 工具配置网关：`manageGateway(action="createAccess", ...)`

**重要**：
- ⚠️ 部署时 `type: "HTTP"` 必须写在 `cloudbaserc.json` 中
- ⚠️ 已部署的 Event 函数无法通过更新代码变为 HTTP 函数
- ⚠️ 必须删除后重新创建
- ⚠️ **CLI 的 `--httpFn` 参数不可靠**，即使使用 `tcb fn deploy --httpFn --path /xxx` 也会创建为 Event 函数
- ⚠️ **唯一可靠的方法是通过 CloudBase 控制台手动创建 HTTP 云函数**

---

### 坑 3：网关传播时间比预期长

**问题**：文档说网关传播需要 30 秒到 3 分钟，但实际测试中：
- 35 秒：仍返回 `INVALID_PATH`
- 60 秒：仍返回 `INVALID_PATH`
- **90 秒**：终于成功 ✅

**建议等待时间**：**至少等待 90 秒** 再进行测试，不要过早放弃。

**验证方法**：
```bash
# 等待 90 秒后测试
sleep 90 && curl https://<envId>.service.tcloudbase.com/<path>/health
```

---

### 坑 4：错误代码对照表

| 错误代码 | 原因 | 解决方法 |
|---------|------|---------|
| `INVALID_PATH` | 网关未配置或传播中 | 检查网关配置，等待 90 秒 |
| `FUNCTION_PARAM_INVALID` | 函数类型错误（Event vs HTTP） | 删除函数，重新创建为 HTTP 类型 |
| 超时 30 秒 | 函数以 Event 模式运行 | 同 `FUNCTION_PARAM_INVALID` |

---

## 关键经验总结

### 1. HTTP 云函数 vs Event 云函数

| 特性 | HTTP 云函数 | Event 云函数 |
|------|-----------|-------------|
| 访问方式 | HTTP URL 直接访问 | SDK `callFunction()` 调用 |
| 框架 | Express/Koa 等 | 纯函数 `exports.main` |
| 端口 | 监听 9000 端口 | 无需监听 |
| 网关配置 | **必须**配置网关路径 | 不需要 |
| 适用场景 | REST API、Web 服务 | 异步任务、定时触发 |

### 2. 网关配置是必须步骤

创建 HTTP 云函数后，**必须**通过 `manageGateway(createAccess)` 注册网关路径，否则外部请求会返回 `INVALID_PATH` 错误。

### 3. 网关传播延迟

网关配置后需要等待 30 秒到 3 分钟才能生效。在此期间访问会返回 `INVALID_PATH`。

### 4. Flutter 不支持 CloudBase SDK

Flutter 属于原生应用，**不能**使用 `@cloudbase/js-sdk`。所有交互都通过 HTTP API 完成。

### 5. CORS 处理

云函数使用 Express 时，必须添加 `cors()` 中间件：

```javascript
const cors = require('cors');
app.use(cors());
```

### 6. 端口必须为 9000

CloudBase HTTP 云函数要求监听 `0.0.0.0:9000`（或使用 `process.env.PORT`）。

---

## 相关文件索引

| 文件 | 说明 |
|------|------|
| `functions/hello-api/index.js` | Hello World 云函数代码 |
| `functions/hello-api/package.json` | 云函数依赖配置 |
| `cloudbaserc.json` | CloudBase 函数注册配置 |
| `lib/config/cloudbase_config.dart` | Flutter CloudBase 环境配置 |
| `lib/services/api_client.dart` | HTTP 客户端（Dio 单例） |
| `lib/features/dev/hello_api_test_page.dart` | 云函数调用测试页面 |
| `lib/router/app_router.dart` | 路由配置（含测试页面路由） |

---

## 测试页面使用方法

1. 启动 Flutter 应用
2. 在浏览器/调试器中导航到 `/dev/hello-api-test`
3. 点击「调用 Hello API」按钮
4. 查看响应结果

在代码中跳转：

```dart
context.goNamed('hello-api-test');
// 或
context.go('/dev/hello-api-test');
```
