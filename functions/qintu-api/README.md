# 亲途云函数部署指南

## 📋 云函数概览

### 基本信息

| 项目 | 值 |
|------|-----|
| **函数名称** | qintu-api |
| **函数类型** | HTTP Function |
| **运行时** | Node.js 16+ |
| **监听端口** | 9000 |
| **框架** | Express.js |
| **数据库** | CloudBase MySQL |

### 功能模块

| 模块 | 路由前缀 | 功能描述 |
|------|----------|----------|
| 用户管理 | `/api/users` | 用户注册、登录、信息查询 |
| 绑定关系 | `/api/bindings` | 生成绑定码、确认绑定、解绑 |
| 导航任务 | `/api/tasks` | 创建任务、接受/开始/完成/取消任务、更新路线 |
| 实时位置 | `/api/locations` | 上传位置、查询位置、切换共享状态 |

---

## 🗂️ 文件结构

```
functions/qintu-api/
├── index.js                 # 入口文件（Express 应用）
├── package.json             # 依赖配置
├── scf_bootstrap            # 启动脚本（必需）
├── .env.example             # 环境变量示例
├── lib/
│   ├── database.js          # 数据库连接池
│   └── response.js          # 统一响应工具
├── middleware/
│   └── auth.js              # 认证中间件
└── routes/
    ├── api.js               # 路由总入口
    ├── users.js             # 用户管理路由
    ├── bindings.js          # 绑定关系路由
    ├── tasks.js             # 导航任务路由
    └── locations.js         # 实时位置路由
```

---

## 🚀 部署步骤

### 第一步：安装依赖

在云函数根目录执行：

```bash
cd functions/qintu-api
npm install
```

这会在本地创建 `node_modules` 目录。

> **注意**：CloudBase 云函数支持自动安装依赖（通过 `package.json`），但为了确保部署成功，建议先在本地安装并测试。

### 第二步：配置环境变量

复制 `.env.example` 为 `.env`（仅用于本地测试，部署时通过 CloudBase 控制台配置）：

```bash
cp .env.example .env
```

编辑 `.env` 文件，填入实际值：

```env
# CloudBase 环境 ID
ENV_ID=qintu-cloudebase-5f5bpuj13bc6467

# MySQL 数据库配置（从 CloudBase 控制台获取）
DB_HOST=your-mysql-host.ap-shanghai.tdsql.db.tencentcs.com
DB_PORT=3306
DB_USER=your-db-username
DB_PASSWORD=your-db-password
DB_NAME=qintu

# Node 环境
NODE_ENV=production
```

> **重要**：部署到 CloudBase 后，需要在控制台的"环境变量"页面配置这些变量。

### 第三步：部署云函数

有两种部署方式：

#### 方式一：使用 CloudBase CLI（推荐）

1. 安装 CloudBase CLI：
   ```bash
   npm install -g @cloudbase/cli
   ```

2. 登录 CloudBase：
   ```bash
   tcb login
   ```

3. 在项目根目录执行部署：
   ```bash
   cd D:\AllCodes\qintu
   tcb fn deploy qintu-api --force
   ```

#### 方式二：使用 CloudBase 控制台

1. 登录 CloudBase 控制台：https://tcb.cloud.tencent.com/
2. 进入环境 `qintu-cloudebase-5f5bpuj13bc6467`
3. 点击左侧菜单 **"云函数"**
4. 点击 **"新建云函数"**
5. 填写信息：
   - **函数名称**：`qintu-api`
   - **运行环境**：Nodejs 16.13
   - **超时时间**：30 秒
   - **内存**：512 MB
6. 点击 **"创建"**
7. 创建完成后，点击函数名称进入详情页
8. 点击 **"函数代码"** → **"本地上传zip"**
9. 将 `functions/qintu-api` 目录打包为 zip：
   ```bash
   cd functions/qintu-api
   zip -r ../qintu-api.zip . -x "*.env" "node_modules/.cache"
   ```
10. 上传 zip 文件
11. 配置环境变量（在"函数配置"页面）：
    - `ENV_ID` = `qintu-cloudebase-5f5bpuj13bc6467`
    - `DB_HOST` = 你的 MySQL 主机地址
    - `DB_PORT` = `3306`
    - `DB_USER` = 数据库用户名
    - `DB_PASSWORD` = 数据库密码
    - `DB_NAME` = `qintu`
    - `NODE_ENV` = `production`

### 第四步：配置 HTTP 访问路径

云函数创建后，需要配置 HTTP 访问路径（API 网关）：

1. 在云函数详情页，点击 **"触发管理"** 或 **"HTTP 访问"**
2. 点击 **"创建 HTTP 访问"**
3. 填写信息：
   - **访问路径**：`/qintu-api`
   - **请求方法**：`ALL`（或根据需要选择 `GET,POST,PUT,DELETE`）
4. 点击 **"确定"**

创建完成后，你会获得一个访问地址，例如：
```
https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api
```

### 第五步：测试云函数

使用 curl 或 Postman 测试健康检查接口：

```bash
curl https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/health
```

预期响应：
```json
{
  "status": "ok",
  "timestamp": "2026-04-04T10:00:00.000Z",
  "service": "qintu-api"
}
```

---

## 📡 完整 API 接口文档

### 基础信息

- **Base URL**：`https://<你的访问地址>/qintu-api/api`
- **认证方式**：请求头 `X-User-OpenID: <openid>`
- **响应格式**：
  ```json
  {
    "code": "SUCCESS",
    "message": "操作成功",
    "data": { ... }
  }
  ```

---

### 1. 用户管理 (`/api/users`)

#### 1.1 用户注册

**接口**：`POST /api/users/register`

**请求体**：
```json
{
  "openid": "cloudbase_auth_openid",
  "phone": "+86 13800138000",
  "nickname": "张三",
  "user_type": "both"
}
```

**响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "openid": "cloudbase_auth_openid",
    "phone": "+86 13800138000",
    "nickname": "张三",
    "user_type": "both",
    "created_at": "2026-04-04T10:00:00.000Z"
  }
}
```

#### 1.2 获取当前用户信息

**接口**：`GET /api/users/me`

**请求头**：
```
X-User-OpenID: <openid>
```

**响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "openid": "...",
    "phone": "+86 13800138000",
    "nickname": "张三",
    "user_type": "both",
    "status": "active",
    "last_login_at": "2026-04-04T10:00:00.000Z",
    "created_at": "2026-04-04T10:00:00.000Z"
  }
}
```

#### 1.3 更新用户信息

**接口**：`PUT /api/users/me`

**请求头**：
```
X-User-OpenID: <openid>
```

**请求体**：
```json
{
  "nickname": "新昵称",
  "user_type": "sender"
}
```

---

### 2. 绑定关系管理 (`/api/bindings`)

#### 2.1 生成绑定码

**接口**：`POST /api/bindings/generate`

**说明**：发送者生成绑定码，用于与接收者建立绑定关系

**请求头**：
```
X-User-OpenID: <sender_openid>
```

**请求体**：
```json
{
  "receiver_phone": "+86 13800138000",  // 可选，如果知道接收者手机号
  "remark": "给父亲的绑定"                // 可选
}
```

**响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "bind_code": "ABC12345",
    "expires_at": "2026-04-05T10:00:00.000Z",
    "message": "请将此绑定码告知接收者，接收者输入后即可建立绑定关系"
  }
}
```

#### 2.2 确认绑定

**接口**：`POST /api/bindings/confirm`

**说明**：接收者输入绑定码，确认绑定关系

**请求头**：
```
X-User-OpenID: <receiver_openid>
```

**请求体**：
```json
{
  "bind_code": "ABC12345"
}
```

**响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "message": "绑定关系已确认",
    "binding": {
      "id": 1,
      "bind_code": "ABC12345",
      "status": "active",
      "sender_nickname": "张三",
      "sender_phone": "+86 13800138000"
    }
  }
}
```

#### 2.3 获取我的绑定关系

**接口**：`GET /api/bindings/my`

**请求头**：
```
X-User-OpenID: <openid>
```

**响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "total": 2,
    "as_sender": 1,
    "as_receiver": 1,
    "bindings": [
      {
        "id": 1,
        "bind_code": "ABC12345",
        "status": "active",
        "my_role": "sender",
        "partner_nickname": "李四",
        "partner_phone": "+86 13900139000"
      }
    ]
  }
}
```

#### 2.4 解除绑定

**接口**：`DELETE /api/bindings/:id`

**请求头**：
```
X-User-OpenID: <openid>
```

---

### 3. 导航任务管理 (`/api/tasks`)

#### 3.1 创建导航任务

**接口**：`POST /api/tasks`

**说明**：发送者规划路线并发送给接收者

**请求头**：
```
X-User-OpenID: <sender_openid>
```

**请求体**：
```json
{
  "receiver_openid": "receiver_openid_here",
  "start_name": "当前位置",
  "start_latitude": 39.9042,
  "start_longitude": 116.4074,
  "end_name": "北京站",
  "end_latitude": 39.9042,
  "end_longitude": 116.4074,
  "end_address": "北京市东城区毛家湾1号",
  "route_data": {...},
  "route_summary": {
    "distance": "15.3km",
    "duration": "32分钟"
  },
  "transport_mode": "drive",
  "distance_meters": 15300,
  "duration_seconds": 1920
}
```

**响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "message": "导航任务已创建并发送给接收者",
    "task": {
      "task_id": "uuid-here",
      "status": "waiting",
      "end_name": "北京站",
      ...
    }
  }
}
```

#### 3.2 获取待处理任务

**接口**：`GET /api/tasks/pending`

**说明**：接收者查看等待中的任务

**请求头**：
```
X-User-OpenID: <receiver_openid>
```

**响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "total": 1,
    "tasks": [
      {
        "task_id": "...",
        "sender_nickname": "张三",
        "end_name": "北京站",
        "status": "waiting",
        "minutes_waiting": 5
      }
    ]
  }
}
```

#### 3.3 接受任务

**接口**：`POST /api/tasks/:taskId/accept`

**说明**：接收者点击"接受导航"

**请求头**：
```
X-User-OpenID: <receiver_openid>
```

#### 3.4 开始导航

**接口**：`POST /api/tasks/:taskId/start`

**说明**：接收者点击"开始导航"

**请求头**：
```
X-User-OpenID: <receiver_openid>
```

#### 3.5 完成任务

**接口**：`POST /api/tasks/:taskId/finish`

**说明**：接收者到达目的地，完成任务

**请求头**：
```
X-User-OpenID: <receiver_openid>
```

#### 3.6 取消任务

**接口**：`POST /api/tasks/:taskId/cancel`

**说明**：发送者或接收者取消任务

**请求头**：
```
X-User-OpenID: <openid>
```

**请求体**：
```json
{
  "reason": "计划变更"
}
```

#### 3.7 更新路线

**接口**：`PUT /api/tasks/:taskId/route`

**说明**：发送者中途修改路线

**请求头**：
```
X-User-OpenID: <sender_openid>
```

**请求体**：
```json
{
  "route_data": {...},
  "route_summary": {...},
  "distance_meters": 16000,
  "duration_seconds": 2000
}
```

---

### 4. 实时位置管理 (`/api/locations`)

#### 4.1 更新位置

**接口**：`POST /api/locations/update`

**说明**：接收者上传实时位置（仅在共享位置时更新）

**请求头**：
```
X-User-OpenID: <receiver_openid>
```

**请求体**：
```json
{
  "task_id": "task_uuid",
  "latitude": 39.9042,
  "longitude": 116.4074,
  "accuracy": 10.5,
  "speed": 45.5,
  "bearing": 180.0,
  "is_navigating": true
}
```

**响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "message": "位置已更新",
    "is_sharing": true
  }
}
```

#### 4.2 查询位置

**接口**：`GET /api/locations/:receiverOpenid`

**说明**：发送者查看接收者实时位置

**请求头**：
```
X-User-OpenID: <sender_openid>
```

**响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "receiver_openid": "...",
    "latitude": 39.9042,
    "longitude": 116.4074,
    "speed": 45.5,
    "bearing": 180.0,
    "is_navigating": 1,
    "is_sharing": 1,
    "updated_at": "2026-04-04T10:00:00.000Z",
    "task_status": "navigating",
    "end_name": "北京站",
    "distance_to_destination": 5300
  }
}
```

#### 4.3 切换位置共享

**接口**：`POST /api/locations/sharing/toggle`

**说明**：接收者开启/停止位置共享

**请求头**：
```
X-User-OpenID: <receiver_openid>
```

**请求体**：
```json
{
  "is_sharing": true
}
```

---

## 🔐 认证说明

### 当前实现

云函数使用简化的认证方式：
- 通过请求头 `X-User-OpenID` 传递用户身份
- 在真实生产环境中，应该：
  1. 使用 CloudBase Auth 生成 Access Token
  2. 客户端在请求头传递 `Authorization: Bearer <token>`
  3. 云函数验证 Token 有效性（调用 CloudBase Auth API）

### Flutter 端集成

在 Flutter 中，每次登录 CloudBase Auth 后会获得 `openid`，将其传递到云函数：

```dart
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://<你的云函数访问地址>/qintu-api/api';
  final String openid; // 从 CloudBase Auth 获取

  ApiService(this.openid);

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-OpenID': openid,
      },
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-OpenID': openid,
      },
      body: json.encode(body),
    );
    return json.decode(response.body);
  }
}
```

---

## ⚠️ 注意事项

### 1. 数据库连接

- 云函数与 MySQL 数据库必须在同一 VPC 内
- 使用 CloudBase 提供的内网地址连接
- 连接池默认配置为 10 个连接，可根据并发调整

### 2. 冷启动

- 云函数首次调用会有冷启动延迟（约 1-3 秒）
- 可以通过"定时预热"减少冷启动影响

### 3. 超时时间

- 默认超时时间 30 秒
- 如果涉及复杂查询或大量数据，可适当增加超时时间

### 4. 并发限制

- CloudBase 云函数默认并发数 1000
- 如果预估并发较高，可申请提升限额

### 5. 安全规则

- 所有接口都通过 `openid` 验证用户身份
- 绑定关系验证确保用户只能操作已绑定的对象
- 建议在 API 网关层配置 IP 白名单或限流规则

---

## 🛠️ 本地开发调试

### 1. 安装依赖

```bash
cd functions/qintu-api
npm install
```

### 2. 配置环境变量

复制 `.env.example` 为 `.env` 并填入实际值。

### 3. 启动服务

```bash
npm start
```

服务会在 `http://localhost:9000` 启动。

### 4. 测试接口

```bash
# 健康检查
curl http://localhost:9000/health

# 用户注册
curl -X POST http://localhost:9000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"openid":"test123","phone":"+86 13800138000","nickname":"测试用户"}'
```

---

## 📊 监控与日志

### 查看云函数日志

1. 登录 CloudBase 控制台
2. 进入云函数详情页
3. 点击 **"日志查询"**
4. 可查看调用日志和错误信息

### 关键日志

云函数会输出以下关键日志：

```
✅ MySQL 数据库连接成功
✅ qintu-api 服务已启动，监听端口: 9000
[2026-04-04T10:00:00.000Z] POST /api/tasks
```

---

## 🔄 后续优化建议

1. **WebSocket 实时推送**：当前使用 HTTP 轮询，可升级为 WebSocket 实现实时通知
2. **Token 验证**：集成 CloudBase Auth SDK 验证 Access Token
3. **缓存优化**：对频繁查询的数据（如用户信息）使用 Redis 缓存
4. **消息队列**：使用 CloudBase 消息队列处理高并发位置上传
5. **CDN 加速**：静态资源使用 CDN 加速
6. **限流与防刷**：在 API 网关层配置限流规则

---

**文档更新日期**：2026-04-04  
**云函数版本**：v1.0.0  
**CloudBase 环境**：`qintu-cloudebase-5f5bpuj13bc6467`
