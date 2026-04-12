# 部署与运维指南

> 本文档涵盖云函数部署、数据库初始化、故障排查等完整流程。

---

## 📋 部署前准备

- [ ] 云函数代码已测试通过（`functions/qintu-api/`）
- [ ] 数据库脚本已就绪（`database/init_schema.sql`）
- [ ] 本地依赖已安装（`npm install`）

---

## 🚀 方式一：CloudBase 控制台部署（推荐）

### 1. 打包代码

```bash
# Windows PowerShell
cd D:\AllCodes\qintu\functions\qintu-api

# 确保已安装依赖
npm install

# 打包为 zip
Compress-Archive -Path * -DestinationPath ..\qintu-api.zip -Force
```

### 2. 上传云函数

1. 登录 [CloudBase 控制台](https://tcb.cloud.tencent.com/)
2. 选择环境：`qintu-cloudebase-5f5bpuj13bc6467`
3. 点击左侧菜单：**云函数** → **新建云函数**
4. 填写信息：
   - **函数名称**：`qintu-api`
   - **运行环境**：`Nodejs 18.15`（推荐）
   - **超时时间**：`30 秒`
   - **内存**：`512 MB`
   - **函数类型**：**HTTP**（⚠️ 必须选择 HTTP 类型）
5. 点击 **创建**

### 3. 上传代码

1. 进入函数详情页 → **函数代码**
2. 选择：**本地上传 zip**
3. 选择文件：`functions/qintu-api.zip`
4. 等待上传完成

### 4. 配置环境变量

在函数配置页面添加以下环境变量：

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `ENV_ID` | `qintu-cloudebase-5f5bpuj13bc6467` | CloudBase 环境 ID |
| `DB_HOST` | `<从控制台获取>` | MySQL 主机地址 |
| `DB_PORT` | `3306` | MySQL 端口 |
| `DB_USER` | `<从控制台获取>` | 数据库用户名 |
| `DB_PASSWORD` | `<安全方式注入>` | 数据库密码 |
| `DB_NAME` | `qintu` | 数据库名称 |
| `PUBLISHABLE_KEY` | `<从控制台获取>` | CloudBase Publishable Key |
| `NODE_ENV` | `production` | 运行环境 |

> **获取 MySQL 连接信息**：CloudBase 控制台 → MySQL 数据库 → 连接信息  
> **获取 PUBLISHABLE_KEY**：通过 MCP 工具 `queryFunctions(action="getFunctionDetail")` 读取

### 5. 创建 HTTP 访问

1. 云函数详情页 → **触发管理** → **创建 HTTP 访问**
2. 访问路径：`/qintu-api`
3. 请求方法：`ALL`
4. 点击 **确定**

---

## 🛠️ 方式二：CLI 部署（适合快速更新）

```bash
# 1. 登录
tcb login

# 2. 进入云函数目录
cd functions/qintu-api

# 3. 安装依赖并部署
npm install
tcb fn deploy qintu-api --force
```

> ⚠️ 注意：CLI 无法创建 HTTP 类型的云函数，首次部署请使用控制台方式。

---

## 🗄️ 数据库初始化

### 执行建表脚本

1. CloudBase 控制台 → **MySQL 数据库** → **SQL 查询**
2. 打开项目中的 `database/init_schema.sql`
3. 复制全部内容并粘贴到 SQL 编辑器
4. 点击 **执行**

### 验证表创建成功

```sql
-- 查看所有表
SHOW TABLES;
-- 应看到 5 个表：users, user_bindings, navigation_tasks, real_time_locations, operation_logs

-- 查看视图
SHOW FULL TABLES WHERE Table_type = 'VIEW';
-- 应看到 2 个视图：v_active_bindings, v_pending_tasks
```

---

## 🧪 验证部署

### 测试健康检查

```bash
curl https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/health
```

**预期响应**：
```json
{ "status": "ok" }
```

### 测试用户注册

```bash
curl -X POST https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/api/users/register \
  -H "Content-Type: application/json" \
  -H "X-User-OpenID: test_openid_123" \
  -d '{
    "openid": "test_openid_123",
    "phone": "+86 13800138000",
    "user_type": "both"
  }'
```

---

## 🔍 故障排查

### 健康检查返回 404/500

| 检查项 | 操作 |
|--------|------|
| 函数是否存在 | 云函数列表确认 `qintu-api` 存在且状态为"已部署" |
| HTTP 触发器 | 函数详情 → 触发管理，确认访问路径为 `/qintu-api` |
| 环境变量 | 函数配置 → 环境变量，确认所有变量已配置 |
| 函数日志 | 函数详情 → 日志查询，查看具体错误 |

### 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| `FUNCTION_PARAM_INVALID` | 函数类型错误（Event 而非 HTTP） | 删除函数，重新创建为 HTTP 类型 |
| `INVALID_PATH` | 网关未配置或传播中 | 检查网关，等待 90 秒后重试 |
| `Cannot find module 'express'` | 依赖未安装 | 重新 `npm install` 后打包上传 |
| `ECONNREFUSED` | 数据库连接信息错误 | 检查 DB_HOST 等环境变量 |
| 超时 30 秒 | 函数以 Event 模式运行 | 删除函数，重新创建为 HTTP 类型 |

### 快速修复步骤

```bash
# 1. 重新安装依赖并打包
cd functions/qintu-api
npm install
Compress-Archive -Path * -DestinationPath ..\qintu-api.zip -Force

# 2. 重新上传到 CloudBase 控制台
```

---

## ✅ 部署检查清单

- [ ] 云函数类型为 **HTTP**
- [ ] 云函数状态为"已部署"
- [ ] 环境变量配置正确（含 PUBLISHABLE_KEY）
- [ ] HTTP 访问路径已创建（`/qintu-api`）
- [ ] 健康检查接口返回正常
- [ ] 数据库表全部创建成功（5 表 + 2 视图）

---

## 📝 重要提示

### ⚠️ HTTP 云函数部署规则

1. **函数类型**：必须选择 HTTP 类型，Event 类型会导致超时
2. **网关配置**：必须创建 HTTP 访问路径
3. **传播等待**：网关配置后**至少等待 90 秒**才能测试
4. **类型不可变**：HTTP/Event 类型创建后不可更改，错误必须删除重建

### 🔑 获取敏感信息

- **PUBLISHABLE_KEY**：通过 MCP 工具 `queryFunctions(action="getFunctionDetail")` 读取
- **DB_PASSWORD**：通过 CloudBase 控制台安全变量注入，不要硬编码

---

**最后更新**：2026-04-09
