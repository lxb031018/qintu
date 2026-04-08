# 部署与运维指南

## 📋 云函数部署

### 准备工作

- 云函数代码已测试通过
- 依赖已安装（`npm install`）
- 已打包为 zip 文件：`functions/qintu-api.zip`

### 部署步骤

#### 1. 上传云函数

1. 打开 [CloudBase 控制台](https://tcb.cloud.tencent.com/)
2. 选择环境：`qintu-cloudebase-5f5bpuj13bc6467`
3. 点击左侧菜单：**云函数** → **新建云函数**
4. 填写信息：
   - **函数名称**：`qintu-api`
   - **运行环境**：`Nodejs 16.13`
   - **超时时间**：`30 秒`
   - **内存**：`512 MB`

#### 2. 上传代码

1. 进入函数详情页 → **函数代码**
2. 选择：**本地上传zip**
3. 选择文件：`functions/qintu-api.zip`
4. 等待上传完成

#### 3. 配置环境变量

在函数配置页面添加以下环境变量：

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `ENV_ID` | `qintu-cloudebase-5f5bpuj13bc6467` | CloudBase 环境 ID |
| `DB_HOST` | `<从控制台获取>` | MySQL 主机地址 |
| `DB_PORT` | `3306` | MySQL 端口 |
| `DB_USER` | `<从控制台获取>` | 数据库用户名 |
| `DB_PASSWORD` | `<从控制台获取>` | 数据库密码 |
| `DB_NAME` | `qintu` | 数据库名称 |
| `NODE_ENV` | `production` | 运行环境 |

> **获取 MySQL 连接信息**：CloudBase 控制台 → MySQL 数据库 → 连接信息

#### 4. 创建 HTTP 访问

1. 云函数详情页 → **触发管理** → **创建 HTTP 访问**
2. 访问路径：`/qintu-api`
3. 请求方法：`ALL`

#### 5. 验证部署

```bash
curl https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/health
```

预期响应：
```json
{ "status": "ok" }
```

---

## 🗄️ 数据库初始化

1. CloudBase 控制台 → MySQL 数据库 → SQL 查询
2. 执行 `database/init_schema.sql` 全部内容
3. 验证：`SHOW TABLES;` 应看到 5 张表

---

## 🔍 故障排查

### 健康检查返回 404/500

| 检查项 | 操作 |
|--------|------|
| 函数是否存在 | 云函数列表确认 `qintu-api` 存在且状态为"已部署" |
| HTTP 触发器 | 函数详情 → 触发管理，确认访问路径为 `/qintu-api` |
| 环境变量 | 函数配置 → 环境变量，确认 7 个变量全部配置 |
| 函数日志 | 函数详情 → 日志查询，查看具体错误 |

### 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| `Cannot find module 'express'` | 依赖未安装 | 重新 `npm install` 后打包上传 |
| `ECONNREFUSED` | 数据库连接信息错误 | 检查 DB_HOST 等环境变量。注意：CloudBase MySQL 默认数据库名可能是 `default` |
| `EADDRINUSE :::9000` | 端口冲突 | 确保代码监听 9000 端口 |

### 快速修复步骤

```bash
# 1. 重新安装依赖并打包
cd functions/qintu-api
npm install
# Windows 打包
Compress-Archive -Path * -DestinationPath ..\qintu-api.zip -Force

# 2. 重新上传到 CloudBase 控制台
```

---

## ✅ 部署检查清单

- [ ] 云函数状态为"已部署"
- [ ] 环境变量配置正确
- [ ] HTTP 访问路径已创建（`/qintu-api`）
- [ ] 健康检查接口返回正常
- [ ] 数据库表全部创建成功
