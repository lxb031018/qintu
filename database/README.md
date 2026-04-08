# 亲途数据库部署指南

## 📋 数据库概览

本项目使用 **CloudBase MySQL 数据库**存储所有用户数据和导航任务数据。

### 核心数据表

| 表名 | 用途 | 关键字段 |
|------|------|----------|
| `users` | 用户信息 | openid（主键）、手机号、角色类型 |
| `user_bindings` | 绑定关系 | 发送者-接收者配对、绑定状态 |
| `navigation_tasks` | 导航任务 | 路线数据、任务状态、高德路线 JSON |
| `real_time_locations` | 实时位置 | 接收者当前位置、共享状态 |
| `operation_logs` | 操作日志 | 审计和调试 |

### 数据流动示意

```
用户登录（手机验证码）
    ↓
创建 users 记录（自动）
    ↓
用户选择角色（发送者/接收者）
    ↓
发送者输入接收者手机号 → 发送绑定请求
    ↓
接收者确认绑定 → 创建 user_bindings 记录（status = 'active'）
    ↓
发送者规划路线 → 创建 navigation_tasks 记录
    ↓
接收者收到通知 → 更新 task status = 'accepted'
    ↓
开始导航 → 更新 real_time_locations
    ↓
发送者可查看实时位置
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

-- 应该看到以下 5 个表：
-- operation_logs
-- real_time_locations
-- navigation_tasks
-- user_bindings
-- users

-- 查看 users 表结构
DESC users;

-- 查看绑定关系表结构
DESC user_bindings;

-- 查看视图
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- 应该看到：
-- v_active_bindings
-- v_pending_tasks
```

---

## 📊 数据表详细说明

### 1. users（用户表）

**用途**：存储所有登录用户的基本信息和角色

**关键字段**：
- `openid`：CloudBase Auth 返回的用户唯一标识（主键）
- `phone`：手机号（带国家码，如 `+86 13800138000`）
- `user_type`：角色类型
  - `sender`：只能作为发送者
  - `receiver`：只能作为接收者
  - `both`：两者皆可（**推荐默认值**）

**示例数据**：
```sql
INSERT INTO users (openid, phone, nickname, user_type) VALUES (
    'openid_from_cloudbase_auth',
    '+86 13800138000',
    '张三',
    'both'
);
```

---

### 2. user_bindings（绑定关系表）

**用途**：建立发送者与接收者之间的配对关系

**核心逻辑**：
- 只有互相绑定的用户才能发送/接收导航指令
- 通过手机号建立绑定关系，需要接收者确认
- 支持一个发送者绑定多个接收者，反之亦然

**关键字段**：
- `sender_openid`：发送者的 openid
- `receiver_openid`：接收者的 openid
- `bind_code`：绑定码字段（已废弃，可为空，向后兼容）
- `status`：绑定状态
  - `pending`：待确认（发送者已发请求，接收者未确认）
  - `active`：生效中
  - `expired`：已过期
  - `revoked`：已撤销
- `remark`：备注信息（存储发送者名称等）

**示例数据**：
```sql
-- 子女（发送者）绑定父母（接收者）
INSERT INTO user_bindings (sender_openid, receiver_openid, status, remark) VALUES (
    'openid_child',
    'openid_parent',
    'active',
    '给父亲的绑定关系'
);
```

**绑定流程**：
1. 发送者输入接收者手机号，发送绑定请求
2. 系统创建 `user_bindings` 记录，状态为 `pending`
3. 接收者查看待确认请求列表
4. 接收者确认绑定，状态更新为 `active`
5. 绑定关系生效

---

### 3. navigation_tasks（导航任务表）

**用途**：存储发送者下发给接收者的导航任务和路线数据

**核心逻辑**：
- 发送者规划路线后创建任务
- 接收者收到通知后点击"接受"
- 开始导航后更新状态和实时位置
- 支持中途修改路线和远程结束

**关键字段**：
- `task_id`：任务唯一 ID（UUID）
- `status`：任务状态流转
  ```
  waiting → accepted → navigating → finished
                      ↓
                  cancelled
  ```
- `route_data`：高德地图返回的完整路线 JSON（重要！）
- `route_summary`：路线摘要（总距离、预计时间等）

**示例数据**：
```sql
INSERT INTO navigation_tasks (
    task_id,
    sender_openid,
    receiver_openid,
    status,
    start_name,
    end_name,
    end_latitude,
    end_longitude,
    end_address,
    route_data,
    route_summary,
    transport_mode,
    distance_meters,
    duration_seconds
) VALUES (
    'task_uuid_here',
    'openid_sender',
    'openid_receiver',
    'waiting',
    '当前位置',
    '北京站',
    39.9042,
    116.4074,
    '北京市东城区毛家湾1号',
    '{"paths": [...]}',  -- 高德地图返回的路线 JSON
    '{"distance": "15.3km", "duration": "32分钟"}',
    'drive',
    15300,
    1920
);
```

---

### 4. real_time_locations（实时位置表）

**用途**：存储接收者在导航过程中的实时位置

**核心逻辑**：
- 仅当发送者点击"查看位置"时更新
- 节省资源，避免持续高频写入
- 支持位置共享开关

**关键字段**：
- `receiver_openid`：接收者 openid（主键）
- `is_navigating`：是否正在导航
- `is_sharing`：是否正在共享位置
- `updated_at`：最后更新时间

**示例数据**：
```sql
INSERT INTO real_time_locations (
    receiver_openid,
    task_id,
    latitude,
    longitude,
    speed,
    bearing,
    is_navigating,
    is_sharing
) VALUES (
    'openid_receiver',
    'task_uuid',
    39.9080,
    116.3970,
    45.5,
    180.0,
    1,
    1
) ON DUPLICATE KEY UPDATE
    latitude = VALUES(latitude),
    longitude = VALUES(longitude),
    speed = VALUES(speed),
    bearing = VALUES(bearing),
    is_navigating = VALUES(is_navigating),
    is_sharing = VALUES(is_sharing),
    updated_at = NOW();
```

---

## 🔍 常用查询示例

### 查询某用户的所有绑定关系
```sql
SELECT * FROM v_active_bindings 
WHERE sender_openid = 'openid_here' 
   OR receiver_openid = 'openid_here';
```

### 查询接收者待处理的导航任务
```sql
SELECT * FROM v_pending_tasks 
WHERE receiver_openid = 'openid_here';
```

### 查询某发送者发出的所有任务
```sql
SELECT task_id, status, end_name, created_at 
FROM navigation_tasks 
WHERE sender_openid = 'openid_here' 
ORDER BY created_at DESC;
```

### 查询某接收者的导航历史
```sql
SELECT task_id, status, end_name, created_at, finished_at 
FROM navigation_tasks 
WHERE receiver_openid = 'openid_here' 
ORDER BY created_at DESC 
LIMIT 20;
```

### 统计某发送者的绑定数量
```sql
SELECT 
    COUNT(*) as total_bindings,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_bindings
FROM user_bindings 
WHERE sender_openid = 'openid_here';
```

---

## ⚠️ 注意事项

### 1. 外键约束
- 删除用户时，会自动删除相关的绑定关系和导航任务
- 如果 CloudBase MySQL 不支持外键，可以移除 `CONSTRAINT` 语句，改用应用层保证数据一致性

### 2. 坐标系统
- 高德地图使用 **GCJ-02** 坐标系（火星坐标系）
- 存储的经纬度坐标应与高德地图返回的一致
- 如需转换为 WGS-84 或其他坐标系，需在应用层处理

### 3. 路线数据存储
- `route_data` 字段存储高德地图返回的完整 JSON（可能较大）
- `route_summary` 字段存储摘要信息，便于快速查询列表
- 建议定期清理已完成的过期任务数据

### 4. 实时位置更新频率
- 建议：仅在发送者查看时更新，间隔 5-10 秒
- 发送者退出查看后，停止更新位置
- 可使用 `is_sharing` 字段控制是否更新位置

### 5. 权限控制
- 数据库层面：通过 CloudBase 安全规则限制访问
- 应用层面：云函数/HTTP API 中验证用户身份和操作权限
- 确保用户只能访问自己的数据和已绑定的关系

---

## 🛠️ 后续开发步骤

1. ✅ **数据库表创建**（本步骤）
2. ⏳ **创建云函数**：处理用户绑定、导航指令下发等业务逻辑
3. ⏳ **Flutter 端开发**：
   - 用户登录（手机验证码）
   - 绑定关系管理（生成/输入绑定码）
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
- 检查 CloudBase MySQL 版本是否支持外键约束
- 如果不支持，移除 `CONSTRAINT` 语句后重新执行

### 问题 2：无法创建视图
- 检查是否有足够的权限
- 确认基础表已创建成功

### 问题 3：插入数据时外键约束失败
- 确保 `users` 表中已存在对应的 openid
- 检查 openid 是否与 CloudBase Auth 返回的一致

---

**文档更新日期**：2026-04-04  
**数据库版本**：MySQL 5.7+  
**CloudBase 环境**：`qintu-cloudebase-5f5bpuj13bc6467`
