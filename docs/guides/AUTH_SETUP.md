# 手机号验证码登录 - 配置指南

## 📋 方案选择

### ✅ 推荐方案：使用 CloudBase 官方 Auth API

**优势**：
- ✅ 无需自己维护认证后端
- ✅ 官方提供安全保障（验证码防刷、Token 加密等）
- ✅ 代码简洁，易于维护
- ✅ 已经实现过且能用

**架构**：
```
Flutter 前端
    ↓
CloudBase 官方 Auth API（认证）
    ↓
自己的云函数 qintu-api（业务逻辑）
```

---

## 🔧 配置步骤

### 步骤 1：确认 CloudBase 控制台配置

1. 登录 [CloudBase 控制台](https://console.cloud.tencent.com/tcb)
2. 选择环境：`qintu-cloudebase-5f5bpuj13bc6467`
3. 进入 **身份验证** → **登录方式**
4. 确保 **手机号登录** 已启用

### 步骤 2：检查 Publishable Key

`.env` 文件中已配置：
```env
CLOUDBASE_PUBLISHABLE_KEY=eyJhbGci...（你的密钥）
```

### 步骤 3：前端代码配置（已完成 ✅）

以下文件已更新为使用 CloudBase 官方 Auth API：

- ✅ `lib/config/cloudbase_config.dart` - 配置正确的 authBaseUrl
- ✅ `lib/constants/api_endpoints.dart` - 使用官方 API 路径
- ✅ `lib/services/auth_service.dart` - 更新请求参数和错误处理

---

## 🚀 使用方法

### 方式 1：真实模式（生产环境）

```dart
// lib/features/auth/auth_page.dart
const bool useMockAuth = false;  // 默认值
```

**流程**：
1. 输入真实手机号
2. 接收真实短信验证码
3. 输入验证码完成登录

### 方式 2：模拟模式（开发测试）

```dart
// lib/features/auth/auth_page.dart
const bool useMockAuth = true;
```

**流程**：
1. 输入任意 11 位手机号
2. 使用固定验证码 `123456`
3. 完成登录

---

## 📝 API 端点说明

### CloudBase 官方 Auth API

| 端点 | 用途 | 完整 URL |
|------|------|----------|
| `/auth/v1/verification` | 发送验证码 | `https://qintu-cloudebase-5f5bpuj13bc6467.api.tcloudbasegateway.com/auth/v1/verification` |
| `/auth/v1/verification/verify` | 验证验证码 | `.../auth/v1/verification/verify` |
| `/auth/v1/signin` | 登录 | `.../auth/v1/signin` |
| `/auth/v1/signup` | 注册 | `.../auth/v1/signup` |
| `/auth/v1/refreshtoken` | 刷新令牌 | `.../auth/v1/refreshtoken` |
| `/auth/v1/signout` | 登出 | `.../auth/v1/signout` |

### 自己的云函数（业务逻辑）

| 端点 | 用途 |
|------|------|
| `/api/users/register` | 用户注册（业务数据） |
| `/api/users/me` | 用户信息管理 |
| `/api/bindings/*` | 绑定关系管理 |
| `/api/tasks/*` | 导航任务管理 |
| `/api/locations/*` | 实时位置共享 |

---

## ⚠️ 注意事项

### 1. 手机号格式

必须使用国际格式，**包含 "+86 "（带空格）**：
```dart
final formattedPhone = '+86 13800138000';  // ✅ 正确
final wrongPhone = '13800138000';          // ❌ 错误
```

### 2. Publishable Key 安全

- ✅ 可以暴露在前端代码中
- ✅ 用于匿名访问和公共请求
- ⚠️ 不能用于管理操作

### 3. Token 管理

CloudBase 官方返回的 Token 格式：
```json
{
  "access_token": "eyJhbG...",
  "refresh_token": "eyJhbG...",
  "expires_in": 7200,
  "refresh_expires_in": 2592000
}
```

---

## 🧪 测试流程

### 测试 1：模拟登录

```bash
# 1. 启用模拟模式
# lib/features/auth/auth_page.dart
const bool useMockAuth = true;

# 2. 运行 Flutter 应用
flutter run

# 3. 测试
# - 输入手机号：13800138000
# - 点击"获取验证码"
# - 输入验证码：123456
# - 点击"登录"
```

### 测试 2：真实登录

```bash
# 1. 关闭模拟模式
const bool useMockAuth = false;

# 2. 确保 CloudBase Auth 已配置
# - 手机号登录已启用
# - 短信服务已配置

# 3. 运行测试
flutter run

# 4. 测试
# - 输入真实手机号
# - 接收真实短信
# - 输入验证码
# - 完成登录
```

---

## 📊 代码对比

### 旧配置（错误）

```dart
// ❌ 错误：指向云函数地址
static String get authBaseUrl => functionBaseUrl;
// = https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com

static const String sendVerificationCode = '/api/auth/send-code';
// 完整路径：https://...service.tcloudbase.com/api/auth/send-code
```

### 新配置（正确）

```dart
// ✅ 正确：指向 CloudBase 官方 Auth API
static String get authBaseUrl => 'https://$envId.api.tcloudbasegateway.com';
// = https://qintu-cloudebase-5f5bpuj13bc6467.api.tcloudbasegateway.com

static const String sendVerificationCode = '/auth/v1/verification';
// 完整路径：https://...api.tcloudbasegateway.com/auth/v1/verification
```

---

## 🔍 故障排查

### 问题 1：验证码发送失败

**错误信息**：`手机号格式错误`

**解决方案**：
```dart
// 确保格式为 "+86 13800138000"（带空格）
final formattedPhone = '+86 ${phoneController.text.trim()}';
```

### 问题 2：未加载 Publishable Key

**错误信息**：`Publishable Key: 未加载 (空字符串)`

**解决方案**：
```bash
# 检查 .env 文件是否存在
cat .env

# 确保格式正确
CLOUDBASE_PUBLISHABLE_KEY=你的密钥
```

### 问题 3：登录失败

**可能原因**：
- 验证码错误
- 验证码过期
- verification_token 无效

**解决方案**：
1. 检查日志输出
2. 重新获取验证码
3. 确保在有效期内完成登录

---

## 📚 参考资源

- [CloudBase 认证文档](https://docs.cloudbase.net/authentication/)
- [HTTP API 文档](https://docs.cloudbase.net/authentication/http-api/)
- [手机号登录配置](https://docs.cloudbase.net/authentication/phone/)

---

## ✅ 检查清单

部署前确认：

- [ ] CloudBase 控制台已启用手机号登录
- [ ] `.env` 文件包含有效的 Publishable Key
- [ ] 前端代码使用正确的 API 端点
- [ ] 手机号格式为 `+86 13800138000`
- [ ] 测试模拟模式登录
- [ ] 测试真实短信验证码

---

## 🎯 下一步

1. **测试登录功能** - 使用模拟模式或真实短信
2. **完善用户同步** - 登录同步到数据库
3. **添加角色选择** - 登录后选择用户角色
4. **完善业务逻辑** - 绑定关系、任务管理等
