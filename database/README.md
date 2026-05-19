# 亲途数据库部署指南

## 📋 数据库概览

本项目使用 **CloudBase MySQL 数据库**存储用户数据和绑定关系。

### 核心数据表

| 表名 | 用途 | 关键字段 |
|------|------|----------|
| `users` | 用户信息 | user_ID（主键）、手机号、昵称、头像 |
| `user_bindings` | 绑定关系 | user_A、user_B（关系平等，双向可发导航任务） |

### 数据流动示意

```
用户登录（手机验证码）
    ↓
创建 users 记录（自动）
    ↓
用户 A 输入用户 B 的手机号 → 发起绑定请求
    ↓
用户 B 确认绑定 → 创建 user_bindings 记录
    ↓
绑定成功，双方均可向对方发送导航任务
```

---

## 🚀 部署步骤

### 第一步：登录 CloudBase 控制台

1. 访问：https://tcb.cloud.tencent.com/
2. 登录您的腾讯云账号
3. 找到环境：`qintu-cloudebase-5f5bpuj13bc6467`

### 第二步：开启 MySQL 数据库

如果还未开启 MySQL 数据库：

1. 进入环境后，点击左侧菜单 **"MySQL 数据库"**
2. 点击 **"开启 MySQL 数据库"**
3. 等待初始化完成（约 1-2 分钟）
4. 进入数据库管理页面

### 第三步：执行 SQL 脚本

有两种方式执行脚本：

#### 方式一：使用在线 SQL 编辑器（推荐）

1. 在 MySQL 数据库页面，点击 **"SQL 查询"** 或 **"在线 SQL 编辑器"**
2. 打开项目中的 `database/init_schema.sql` 文件
3. 复制整个文件内容
4. 粘贴到 SQL 编辑器中
5. 点击 **"执行"** 按钮
6. 查看执行结果，确保无错误

#### 方式二：使用命令行工具

如果您安装了 MySQL 客户端：

```bash
mysql -h <MySQL_HOST> -u <USERNAME> -p<PASSWORD> qintu_cloudbase < database/init_schema.sql
```

> 注意：CloudBase MySQL 的连接信息可以在控制台获取

### 第四步：验证表创建成功

执行以下 SQL 验证：

```sql
-- 查看所有表
SHOW TABLES;

-- 应该看到以下 2 个表：
-- user_bindings
-- users
```

---

## 📊 数据表详细说明

### 1. users（用户表）

**用途**：存储所有登录用户的基本信息

**字段说明**：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| `user_ID` | VARCHAR(64) | 用户唯一标识（UUID），主键 |
| `phone` | VARCHAR(20) | 手机号（带国家码，如 `+86 13800138000`），唯一 |
| `nickname` | VARCHAR(50) | 用户昵称 |
| `avatar_url` | VARCHAR(500) | 头像 URL |
| `last_login_at` | TIMESTAMP | 最后登录时间 |
| `created_at` | TIMESTAMP | 创建时间 |

**索引**：

| 索引类型 | 索引名 | 作用 |
|----------|--------|------|
| 主键 | `PRIMARY KEY` | 基于 `user_ID` |
| 唯一索引 | `uk_phone` | 手机号唯一 |
| 普通索引 | `idx_created_at` | 按创建时间排序 |

**示例数据**：
```sql
INSERT INTO users (user_ID, phone, nickname) VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    '+86 13800138000',
    '张三'
);
```

---

### 2. user_bindings（绑定关系表）

**用途**：记录用户之间的绑定关系，关系平等，双向可发导航任务

**核心逻辑**：
- 绑定关系平等，双方均可向对方发送导航任务
- 存储规则：`user_A < user_B`（字符串比较，较小的 user_ID 在前）
- 解除绑定即删除记录，无状态标识

**字段说明**：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| `user_A` | VARCHAR(64) | 用户A的 user_ID（较小者） |
| `user_B` | VARCHAR(64) | 用户B的 user_ID（较大者） |

**索引**：

| 索引类型 | 索引名 | 作用 |
|----------|--------|------|
| 主键 | `PRIMARY KEY` | 基于 (`user_A`, `user_B`) |
| 普通索引 | `idx_user_A` | 查询某用户的绑定关系 |
| 普通索引 | `idx_user_B` | 查询某用户的绑定关系 |

**示例数据**：
```sql
-- 用户 A 和用户 B 建立绑定关系
INSERT INTO user_bindings (user_A, user_B) VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    '660e8400-e29b-41d4-a716-446655440001'
);
```

**绑定流程**：
1. 用户 A 输入用户 B 的手机号，发送绑定请求
2. 用户 B 确认绑定请求
3. 系统自动比较两个 user_ID，将较小的存入 `user_A`
4. 创建 `user_bindings` 记录
5. 绑定关系生效，双方均可向对方发送导航任务

---

## 🔍 常用查询示例

### 查询某用户的所有绑定关系
```sql
SELECT * FROM user_bindings
WHERE user_A = 'user_ID_here' OR user_B = 'user_ID_here';
```

### 查询两个用户之间是否存在绑定关系
```sql
SELECT * FROM user_bindings
WHERE (user_A = 'user_ID_A' AND user_B = 'user_ID_B')
   OR (user_A = 'user_ID_B' AND user_B = 'user_ID_A');
```

### 统计某用户的绑定数量
```sql
SELECT COUNT(*) as binding_count
FROM user_bindings
WHERE user_A = 'user_ID_here' OR user_B = 'user_ID_here';
```

---

## ⚠️ 注意事项

### 1. 关系平等设计
- 两个用户绑定后，双方均可向对方发送导航任务
- 无发送者/接收者角色区分
- 解除绑定即删除记录

### 2. user_ID 排序规则
- `user_A` 始终是 user_ID 字符串比较较小的一方
- `user_B` 是 user_ID 字符串比较较大的一方
- 应用层需确保插入时正确排序

### 3. 权限控制
- 数据库层面：通过 CloudBase 安全规则限制访问
- 应用层面：云函数/HTTP API 中验证用户身份和操作权限
- 确保用户只能访问自己的数据和已绑定的关系

---

## 🛠️ 后续开发步骤

1. ✅ **数据库表创建**（本步骤）
2. ⏳ **创建云函数**：处理用户绑定、导航指令下发等业务逻辑
3. ⏳ **Flutter 端开发**：
   - 用户登录（手机验证码）
   - 绑定关系管理
   - 路线规划与下发
   - 导航执行与实时位置共享
4. ⏳ **高德地图集成**：
   - 路线规划 API
   - 导航组件集成
   - 位置采集与上传
5. ⏳ **测试与部署**

---

## 📞 问题排查

### 问题 1：执行 SQL 脚本报错
- 检查 CloudBase MySQL 版本是否支持 UTF-8 字符集
- 确认 SQL 语句语法正确

### 问题 2：绑定关系查询不到
- 确认 user_ID 排序正确（user_A < user_B）
- 检查索引是否创建成功

### 问题 3：插入数据时唯一键冲突
- 确保 `users` 表中已存在对应的 user_ID
- 检查手机号是否已被其他用户使用

---

**文档更新日期**：2026-05-19
**数据库版本**：MySQL 5.7+
**CloudBase 环境**：`qintu-cloudebase-5f5bpuj13bc6467`
