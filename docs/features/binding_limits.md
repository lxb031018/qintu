# 亲途 - 绑定人数限制说明

## 📋 核心概念

### 手机号绑定（远程绑定）
- **用途**：建立长期或短期绑定关系的唯一方法
- **场景**：发送者知道对方手机号，远程建立绑定关系
- **流程**：输入对方手机号 → 发送绑定请求 → 接收者确认 → 建立绑定关系
- **限制**：发送者最多 5 个接收者，接收者最多被 3 个发送者绑定
- **有效期设置**：
  - **永久绑定**：长期关系（如家庭成员）
  - **有限时间绑定**：自定义有效期（如旅游团导游带团 7 天）
  - 由发送者定义，过期后自动解除绑定
- **特点**：绑定后可随时查看对方位置、发送导航任务

### 二维码分享路线（临时分享）
- **用途**：一次性分享路线，**无需绑定关系**
- **场景**：面对面时，发送者生成路线二维码，多人可扫码接受同一路线
- **限制**：无限制，任何人都可以扫码接受导航
- **特点**：
  - 每次规划路线生成一个二维码
  - 一个二维码可被多人扫描使用
  - 临时性、无需注册、无需绑定

---

## 🔒 位置共享权限控制

### 双向控制权
- **发送者**：可以随时允许/拒绝他人查看自己的位置
- **接收者**：可以随时允许/拒绝他人查看自己的位置

### 控制时机
- **导航开始前**：在规划路线后、导航启动前设置
- **导航进行中**：在导航过程中随时切换

### 权限选项
- **允许查看**：其他人可以看到实时位置
- **拒绝查看**：隐藏自己的位置信息

---

## 📋 限制策略

根据家庭场景定位，系统对绑定人数进行了合理限制：

### 限制规则

| 角色 | 限制类型 | 上限 | 说明 |
|------|---------|------|------|
| **发送者** | 最多绑定接收者 | **5 人** | 一个子女最多管理 5 个长辈的导航 |
| **接收者** | 最多被发送者绑定 | **3 人** | 一个长辈最多被 3 个子女监护 |

### 设计理由

**发送者限制（5 人）**：
- ✅ 覆盖典型家庭场景（1 个子女照顾多个父母/祖父母）
- ✅ 避免资源过度占用（导航任务、位置上传等）
- ✅ 保证服务质量（过多绑定会导致管理混乱）

**接收者限制（3 人）**：
- ✅ 典型家庭结构（2-3 个子女共同监护父母）
- ✅ 避免过度监护（太多子女同时查看会造成干扰）
- ✅ 降低服务器负载（位置查询、推送通知等）

---

## 🔒 限制验证点

### 1. 发送者输入手机号发送绑定请求时

**接口**：`POST /api/bindings/request-phone`

**验证逻辑**：
```javascript
// 检查发送者当前绑定数量
const senderBindingsCount = await query(
  `SELECT COUNT(*) as count FROM user_bindings
   WHERE sender_openid = ? AND status = 'active'`,
  [senderOpenid]
);

if (senderBindingsCount[0].count >= 5) {
  return error(res, '绑定人数已达上限（最多5个接收者）', 'BINDING_LIMIT_EXCEEDED', 409);
}
```

**错误响应**：
```json
{
  "code": "BINDING_LIMIT_EXCEEDED",
  "message": "绑定人数已达上限（最多5个接收者）"
}
```

---

### 2. 发送者绑定已知接收者时

**接口**：`POST /api/bindings/request-phone`（带 `receiver_phone`）

**额外验证**：
```javascript
// 检查接收者被绑定数量
const receiverBindingsCount = await query(
  `SELECT COUNT(*) as count FROM user_bindings
   WHERE receiver_openid = ? AND status IN ('active', 'pending')`,
  [receiverOpenid]
);

if (receiverBindingsCount[0].count >= 3) {
  return error(res, '该用户已被 3 个发送者绑定，无法继续绑定', 'RECEIVER_BINDING_FULL', 409);
}
```

**错误响应**：
```json
{
  "code": "RECEIVER_BINDING_FULL",
  "message": "该用户已被 3 个发送者绑定，无法继续绑定"
}
```

---

### 3. 接收者确认绑定时

**接口**：`POST /api/bindings/confirm-request`

**验证逻辑**：
```javascript
// 确认绑定时再次检查接收者绑定数量
const receiverBindingsCount = await query(
  `SELECT COUNT(*) as count FROM user_bindings
   WHERE receiver_openid = ? AND status = 'active'`,
  [receiverOpenid]
);

if (receiverBindingsCount[0].count >= 3) {
  return error(res, '绑定人数已达上限（最多3个发送者）', 'BINDING_LIMIT_EXCEEDED', 409);
}

// 检查发送者绑定数量
const senderBindingsCount = await query(
  `SELECT COUNT(*) as count FROM user_bindings
   WHERE sender_openid = ? AND status = 'active'`,
  [binding.sender_openid]
);

if (senderBindingsCount[0].count >= 5) {
  return error(res, '该发送者绑定人数已达上限（最多5个）', 'SENDER_BINDING_FULL', 409);
}
```

---

## 📊 绑定场景示例

### 场景 1：典型家庭（正常）

```
张三（发送者）
├─ 绑定 → 父亲（接收者）✅
├─ 绑定 → 母亲（接收者）✅
└─ 绑定 → 奶奶（接收者）✅

当前绑定数：3/5 ✅ 可以继续绑定
```

### 场景 2：发送者达到上限

```
李四（发送者）
├─ 绑定 → 父亲 ✅
├─ 绑定 → 母亲 ✅
├─ 绑定 → 爷爷 ✅
├─ 绑定 → 奶奶 ✅
└─ 绑定 → 外公 ❌ 已达上限（5/5）

错误提示："绑定人数已达上限（最多5个接收者）"
```

### 场景 3：接收者达到上限

```
王父（接收者）
├─ 被 王大 绑定 ✅
├─ 被 王二 绑定 ✅
└─ 被 王三 绑定 ✅

当前绑定数：3/3 ✅ 已达上限

王四尝试绑定 → ❌ 错误提示："该用户已被 3 个发送者绑定，无法继续绑定"
```

---

## 🔍 查询绑定数量

### 获取我的绑定关系

**接口**：`GET /api/bindings/my`

**响应示例**：
```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "total": 3,
    "as_sender": 2,      // 作为发送者绑定了 2 个接收者
    "as_receiver": 1,    // 作为接收者被 1 个发送者绑定
    "bindings": [...]
  }
}
```

### Flutter 端显示绑定数量

```dart
// 显示绑定数量
Text('作为发送者：${data.as_sender}/5 个绑定');
Text('作为接收者：${data.as_receiver}/3 个绑定');

// 达到上限时禁用绑定按钮
ElevatedButton(
  onPressed: data.as_sender >= 5 ? null : _bindByPhone,
  child: Text(data.as_sender >= 5 ? '绑定人数已达上限' : '绑定新用户'),
);
```

---

## ⚙️ 修改限制（可选）

如果未来需要调整限制数量，只需修改一处：

**文件**：`functions/qintu-api/routes/bindings.js`

```javascript
const BINDING_LIMITS = {
  MAX_RECEIVERS_PER_SENDER: 5,   // 修改此数字调整发送者上限
  MAX_SENDERS_PER_RECEIVER: 3    // 修改此数字调整接收者上限
};
```

修改后重新部署云函数即可。

---

## 🧪 测试用例

### 测试 1：发送者绑定 5 个接收者

```bash
# 循环绑定 5 次
for i in {1..5}; do
  curl -X POST http://localhost:9000/api/bindings/request-phone \
    -H "Content-Type: application/json" \
    -H "X-User-OpenID: sender_openid" \
    -d "{\"receiver_phone\": \"+86 1380013800$i\", \"sender_name\": \"发送者\"}"
done

# 第 6 次绑定应失败
curl -X POST http://localhost:9000/api/bindings/request-phone \
  -H "Content-Type: application/json" \
  -H "X-User-OpenID: sender_openid" \
  -d "{\"receiver_phone\": \"+86 13800138006\", \"sender_name\": \"发送者\"}"

# 预期响应：
# {"code": "BINDING_LIMIT_EXCEEDED", "message": "绑定人数已达上限（最多5个接收者）"}
```

### 测试 2：接收者被 3 个发送者绑定

```bash
# 3 个发送者分别向同一接收者发送绑定请求
for sender in sender1 sender2 sender3; do
  # 发送绑定请求
  curl -X POST http://localhost:9000/api/bindings/request-phone \
    -H "Content-Type: application/json" \
    -H "X-User-OpenID: $sender" \
    -d "{\"receiver_phone\": \"+86 13800138000\", \"sender_name\": \"$sender\"}"

  # 接收者确认绑定
  curl -X POST http://localhost:9000/api/bindings/confirm-request \
    -H "Content-Type: application/json" \
    -H "X-User-OpenID: receiver_openid" \
    -d "{\"request_id\": \"请求ID\"}"
done

# 第 4 个发送者尝试绑定时应失败
curl -X POST http://localhost:9000/api/bindings/request-phone \
  -H "Content-Type: application/json" \
  -H "X-User-OpenID: sender4" \
  -d "{\"receiver_phone\": \"+86 13800138000\", \"sender_name\": \"sender4\"}"

# 预期响应：
# {"code": "RECEIVER_BINDING_FULL", "message": "该用户已被 3 个发送者绑定，无法继续绑定"}
```

---

## 📝 数据库索引优化

为支持高效的绑定数量查询，数据库已创建以下索引：

```sql
-- 查询发送者的绑定数量
KEY `idx_sender_openid` (`sender_openid`)

-- 查询接收者的绑定数量
KEY `idx_receiver_openid` (`receiver_openid`)

-- 查询活跃绑定关系
KEY `idx_status` (`status`)
```

这些索引确保 `COUNT(*)` 查询可以在毫秒级完成。

---

## 🎯 总结

| 特性 | 值 |
|------|-----|
| 发送者上限 | 5 个接收者 |
| 接收者上限 | 3 个发送者 |
| 验证时机 | 输入手机号绑定时、确认绑定时 |
| 错误代码 | `BINDING_LIMIT_EXCEEDED`, `RECEIVER_BINDING_FULL`, `SENDER_BINDING_FULL` |
| HTTP 状态码 | 409 (Conflict) |
| 是否可配置 | 是（修改 `BINDING_LIMITS` 常量即可） |

---

**文档更新日期**：2026-04-04  
**版本**：v1.0.0
