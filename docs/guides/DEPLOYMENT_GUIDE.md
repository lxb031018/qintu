# 亲途后端部署指南

## 📋 部署清单

- [x] 云函数代码已就绪（`functions/qintu-api/`）
- [x] 数据库脚本已就绪（`database/init_schema.sql`）
- [x] 环境变量配置示例已提供

---

## 🚀 第一步：部署云函数

### 方式一：使用 CloudBase CLI（推荐）

```bash
# 1. 安装 CLI（如果未安装）
npm install -g @cloudbase/cli

# 2. 登录
tcb login

# 3. 进入云函数目录
cd D:\AllCodes\qintu\functions\qintu-api

# 4. 安装依赖
npm install

# 5. 部署函数
tcb fn deploy qintu-api --force
```

### 方式二：使用 CloudBase 控制台

#### 1. 打包代码

```bash
# Windows PowerShell
cd D:\AllCodes\qintu\functions\qintu-api

# 确保已安装依赖
npm install

# 打包为 zip（排除不需要的文件）
Compress-Archive -Path * -DestinationPath ..\qintu-api.zip -Force
```

#### 2. 上传到控制台

1. 登录 [CloudBase 控制台](https://tcb.cloud.tencent.com/)
2. 选择环境：`qintu-cloudebase-5f5bpuj13bc6467`
3. 点击左侧 **云函数**
4. 点击 **新建云函数**
5. 填写信息：
   - **函数名称**：`qintu-api`
   - **运行环境**：`Nodejs 16.13`
   - **超时时间**：`30 秒`
   - **内存**：`512 MB`
6. 点击 **创建**
7. 创建完成后，进入函数详情页
8. 点击 **函数代码** → **本地上传zip**
9. 选择 `D:\AllCodes\qintu\functions\qintu-api.zip`
10. 点击 **上传**

---

## ⚙️ 第二步：配置环境变量

### 在控制台配置

1. 云函数详情页 → **函数配置**
2. 找到 **环境变量** 区域
3. 添加以下变量：

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `ENV_ID` | `qintu-cloudebase-5f5bpuj13bc6467` | CloudBase 环境 ID |
| `DB_HOST` | `<MySQL 主机地址>` | 从控制台获取 |
| `DB_PORT` | `3306` | MySQL 端口 |
| `DB_USER` | `<数据库用户名>` | 从控制台获取 |
| `DB_PASSWORD` | `<数据库密码>` | 从控制台获取 |
| `DB_NAME` | `qintu` | 数据库名称 |
| `NODE_ENV` | `production` | 运行环境 |

### 如何获取 MySQL 连接信息

1. CloudBase 控制台 → **MySQL 数据库**
2. 点击 **连接信息**
3. 复制主机地址、端口、用户名

---

## 🗄️ 第三步：配置 HTTP 访问

### 创建 HTTP 访问路径

1. 云函数详情页 → **触发管理** 或 **HTTP 访问**
2. 点击 **创建 HTTP 访问**
3. 填写：
   - **访问路径**：`/qintu-api`
   - **请求方法**：`ALL`
4. 点击 **确定**

### 获取访问地址

创建成功后，您会获得类似这样的地址：
```
https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api
```

**保存这个地址**，Flutter 端需要配置。

---

## 📊 第四步：初始化数据库

### 执行建表脚本

1. CloudBase 控制台 → **MySQL 数据库**
2. 点击 **SQL 查询** 或 **在线 SQL 编辑器**
3. 打开项目中的 `database/init_schema.sql`
4. 复制全部内容
5. 粘贴到 SQL 编辑器
6. 点击 **执行**
7. 等待执行完成

### 验证表创建成功

执行以下 SQL：

```sql
-- 查看所有表
SHOW TABLES;

-- 应该看到 5 个表：
-- users
-- user_bindings
-- navigation_tasks
-- real_time_locations
-- operation_logs

-- 查看视图
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- 应该看到 2 个视图：
-- v_active_bindings
-- v_pending_tasks
```

---

## 🧪 第五步：测试云函数

### 测试健康检查

使用 curl 或浏览器访问：

```bash
curl https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/health
```

**预期响应**：
```json
{
  "status": "ok",
  "timestamp": "2026-04-04T10:00:00.000Z",
  "service": "qintu-api"
}
```

### 测试用户注册

```bash
curl -X POST https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/api/users/register \
  -H "Content-Type: application/json" \
  -H "X-User-OpenID: test_openid_123" \
  -d '{
    "openid": "test_openid_123",
    "phone": "+86 13800138000",
    "nickname": "测试用户",
    "user_type": "both"
  }'
```

**预期响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "openid": "test_openid_123",
    "phone": "+86 13800138000",
    "nickname": "测试用户",
    "user_type": "both",
    "created_at": "2026-04-04T10:00:00.000Z"
  }
}
```

### 测试手机号绑定

```bash
curl -X POST https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/api/bindings/generate \
  -H "Content-Type: application/json" \
  -H "X-User-OpenID: test_openid_123" \
  -d '{
    "receiver_phone": "+86 13800138001",
    "remark": "测试绑定"
  }'
```

**预期响应**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "message": "绑定成功"
  }
}
```

---

## 🔧 第六步：更新 Flutter 配置

### 修改 Base URL

编辑 `lib/utils/constants.dart`：

```dart
static const String cloudFunctionBaseUrl = 
    'https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api';
```

**替换为您的实际访问地址**。

---

## ⚠️ 常见问题

### 问题 1：云函数启动失败

**原因**：依赖未安装或环境变量配置错误

**解决**：
1. 检查 `node_modules` 是否存在
2. 检查环境变量是否正确配置
3. 查看云函数日志

### 问题 2：数据库连接失败

**原因**：DB_HOST 等配置错误

**解决**：
1. 检查 MySQL 是否已开启
2. 检查主机地址、用户名、密码是否正确
3. 确保云函数与 MySQL 在同一 VPC

### 问题 3：HTTP 访问 404

**原因**：HTTP 访问路径未配置

**解决**：
1. 检查是否创建了 HTTP 访问
2. 检查访问路径是否正确（应为 `/qintu-api`）

---

## 📊 部署检查清单

部署完成后，确认以下项目：

- [ ] 云函数部署成功，状态为正常
- [ ] 环境变量配置正确（DB_HOST、DB_USER 等）
- [ ] HTTP 访问路径已创建（`/qintu-api`）
- [ ] 健康检查接口返回正常
- [ ] 用户注册接口测试通过
- [ ] 手机号绑定接口测试通过
- [ ] 数据库表全部创建成功
- [ ] Flutter 配置已更新 Base URL

---

## 🎉 部署完成

部署成功后，您将拥有：

✅ 完整的后端 API 服务（21 个接口）  
✅ MySQL 数据库（5 张表 + 2 个视图）  
✅ 绑定人数限制（发送者 5 人，接收者 3 人）  
✅ 完整的错误处理和日志记录  

---

**部署日期**：2026-04-04  
**云函数版本**：v1.0.0  
**环境 ID**：`qintu-cloudebase-5f5bpuj13bc6467`
