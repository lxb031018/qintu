# API 契约规范

> 前后端接口契约对齐规则，避免"写了调不通"的问题。

---

## 📌 核心原则

**以后端路由定义为准。**

后端 `routes/*.js` 定义了真实的路由路径和参数名。前端 `api_client.dart` 中的路径和参数**必须与后端一致**。

---

## 🔧 命名规则

### 路径命名

前端方法中的 `endpoint` 必须与后端 `routes/*.js` 中的路由路径**逐字匹配**：

```dart
// ✅ 正确：与后端 POST /api/tasks/:taskId/finish 一致
endpoint: '/api/tasks/$taskId/finish'

// ❌ 错误：自己造路径
endpoint: '/api/tasks/$taskId/complete'
```

### 查询参数命名

分页等查询参数使用后端定义的参数名：

```dart
// ✅ 正确：后端使用 limit
endpoint: '/api/tasks/my?status=$status&page=$page&limit=$limit'

// ❌ 错误：自己造参数名
endpoint: '/api/tasks/my?status=$status&page=$page&page_size=$pageSize'
```

### 请求体字段命名

请求体字段名必须与后端 `req.body` 中读取的字段名一致：

```dart
// ✅ 正确：后端读取 req.body.bearing
'speed': speed,
'bearing': bearing,

// ❌ 错误：自己造字段名
'speed': speed,
'heading': heading,
```

---

## ✅ 新增接口流程

1. **后端先定义路由**（`routes/*.js`）
2. **前端对照后端路径写 `endpoint`**
3. **逐字段核对参数名**
4. 不确定时，直接看后端代码确认

---

## 📋 已对齐的接口清单

### 用户管理（users.js）

| 功能 | 前端方法 | 后端路由 | 状态 |
|------|---------|---------|------|
| 同步用户 | `syncUser()` | `POST /api/users/sync` | ✅ 已对齐 |
| 注册用户 | `registerUser()` | `POST /api/users/register` | ✅ 已对齐 |
| 获取用户 | `getCurrentUser()` | `GET /api/users/me` | ✅ 已对齐 |
| 更新用户 | `updateUser()` | `PUT /api/users/me` | ✅ 已对齐 |

### 绑定管理（bindings.js / bindings-memory.js）

**绑定流程说明**：
发送者输入接收者手机号 + 对对方的称呼 + 对方对自己的称呼 → 发送绑定请求 → 接收者确认/拒绝 → 建立绑定关系

| 功能 | 前端方法 | 后端路由 | 状态 |
|------|---------|---------|------|
| 发送绑定请求 | `requestPhoneBinding()` | `POST /api/bindings/request-phone` | ✅ 已对齐 |
| 获取我的绑定 | `loadBindings()` | `GET /api/bindings/my` | ✅ 已对齐 |
| 获取待确认请求 | `loadPendingRequests()` | `GET /api/bindings/pending` | ✅ 已对齐 |
| 确认绑定请求 | `confirmRequest()` | `POST /api/bindings/confirm-request` | ✅ 已对齐 |
| 拒绝绑定请求 | `rejectRequest()` | `POST /api/bindings/reject-request` | ✅ 已对齐 |
| 获取发出请求 | `loadSentRequests()` | `GET /api/bindings/sent` | ✅ 已对齐 |
| 取消发出请求 | `cancelSentRequest()` | `DELETE /api/bindings/:id` | ✅ 已对齐 |

**请求体字段说明**：

```dart
// POST /api/bindings/request-phone
{
  'receiver_phone': '+86 13800138000',  // 对方手机号
  'sender_name': '儿子',                // 对方对您的称呼
  'receiver_name': '老妈',              // 您对对方的称呼
}
```

**说明**：
- 不再使用绑定码机制，手机号即为唯一标识
- 所有绑定均通过 `request-phone` 发起，接收者确认后才生效
- pending 请求 7 天自动过期
- 发送者取消 pending 请求时，记录直接删除（不留痕迹）
- 解除已生效绑定时，状态改为 `revoked`
- 双向对等：A 绑定 B 确认后，A 和 B 自动互相绑定

### 任务管理（tasks.js）

| 功能 | 前端方法 | 后端路由 | 状态 |
|------|---------|---------|------|
| 创建任务 | `createNavigationTask()` | `POST /api/tasks` | ✅ 已对齐 |
| 获取任务列表 | `getMyTasks()` | `GET /api/tasks/my` | ✅ 已对齐 |
| 获取待处理任务 | `getPendingTasks()` | `GET /api/tasks/pending` | ✅ 已对齐 |
| 获取任务详情 | `getTaskDetail()` | `GET /api/tasks/:taskId` | ✅ 已对齐 |
| 接受任务 | `acceptTask()` | `POST /api/tasks/:taskId/accept` | ✅ 已对齐 |
| 开始任务 | `startTask()` | `POST /api/tasks/:taskId/start` | ✅ 已对齐 |
| 完成任务 | `completeTask()` | `POST /api/tasks/:taskId/finish` | ✅ 已对齐 |
| 取消任务 | `cancelTask()` | `POST /api/tasks/:taskId/cancel` | ✅ 已对齐 |
| 更新路线 | `updateRoute()` | `PUT /api/tasks/:taskId/route` | ✅ 已对齐 |

### 位置管理（locations.js）

| 功能 | 前端方法 | 后端路由 | 状态 |
|------|---------|---------|------|
| 上传位置 | `uploadLocation()` | `POST /api/locations/update` | ✅ 已对齐 |
| 获取位置 | `getReceiverLocation()` | `GET /api/locations/:receiverOpenid` | ✅ 已对齐 |
| 切换共享 | `toggleLocationSharing()` | `POST /api/locations/sharing/toggle` | ✅ 已对齐 |

---

## 🧪 自动化测试

| 系统 | 测试脚本 | 用例数 | 状态 |
|------|---------|--------|------|
| 绑定系统 | `test-binding-flow.js` | 11 | ✅ 就绪 |
| 导航任务 | `test-task-flow.js` | 18 | ✅ 就绪 |
| 位置共享 | 集成在导航测试中 | - | ✅ 就绪 |

**运行测试：**
```bash
cd functions/qintu-api
node test-binding-flow.js
node test-task-flow.js
```

---

**最后更新**: 2026-04-09
