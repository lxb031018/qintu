# CloudBase Auth 配置指南

> 本文档指导你如何配置 CloudBase Auth 以支持手机号验证码登录功能。

---

## 📋 方案选择

### ✅ 推荐方案：使用 CloudBase 官方 Auth API

**架构**：
```
Flutter 前端
    ↓
CloudBase 官方 Auth API（认证）
    ↓
自己的云函数 qintu-api（业务逻辑）
```

**优势**：
- ✅ 无需自己维护认证后端
- ✅ 官方提供安全保障（验证码防刷、Token 加密等）
- ✅ 代码简洁，易于维护

---

## 🔧 配置步骤

### 步骤 1：启用手机号登录

1. 登录 [CloudBase 控制台](https://console.cloud.tencent.com/tcb)
2. 选择环境：`qintu-cloudebase-5f5bpuj13bc6467`
3. 进入 **身份验证** → **登录方式**
4. 找到 **手机号登录**，点击 **启用**

### 步骤 2：配置短信服务

#### 方式 A：使用默认短信服务（推荐）

1. 在手机号登录配置页面
2. 选择 **默认短信服务**
3. 系统会自动配置短信通道

#### 方式 B：使用自定义短信签名和模板

1. 在腾讯云控制台申请：
   - **短信签名**：需要审核通过
   - **短信模板**：创建验证码模板
2. 记录签名 ID 和模板 ID
3. 在云函数环境变量中配置：
   ```env
   SMS_SIGN_ID=你的短信签名ID
   SMS_TEMPLATE_ID=你的短信模板ID
   ```

### 步骤 3：配置 Publishable Key

在 `.env` 文件中添加：
```env
CLOUDBASE_PUBLISHABLE_KEY=你的密钥
```

> **获取方式**：通过 MCP 工具 `queryFunctions(action="getFunctionDetail")` 读取云函数环境变量

### 步骤 4：验证配置

#### 通过 MCP 工具检查

```
MCP 工具：queryAppAuth
action：listProviders
```

确认返回中包含 `PhoneNumberLogin` 且状态为启用。

#### 通过代码测试

```dart
import 'package:qintu/services/auth_service.dart';

// 发送验证码
final result = await AuthService.sendSmsCode('+86 13800138000');
if (result.success) {
  print('验证码发送成功');
}
```

---

## 🚀 前端使用方法

### 1. 发送验证码

```dart
import 'package:qintu/services/auth_service.dart';

final result = await AuthService.sendSmsCode(phoneNumber);
if (result.success) {
  // 开始倒计时
}
```

### 2. 验证码登录

```dart
final result = await AuthService.loginWithSmsCode(
  phoneNumber: phoneNumber,
  code: verificationCode,
);

if (result.success) {
  // 登录成功，跳转到主页
}
```

### 3. 退出登录

```dart
await AuthService.logout();
// 清除本地状态
```

---

## 📊 认证配置说明

### Token 管理

- **Access Token**：用于 API 请求认证，自动注入到 `Authorization` Header
- **Refresh Token**：用于刷新 Access Token，过期前自动刷新
- **存储方式**：`SecureStorage`（Android EncryptedSharedPreferences / iOS Keychain）

### 自动刷新机制

`TokenRefreshInterceptor` 自动处理 401 错误：
1. 捕获 401 响应
2. 使用 Refresh Token 请求新 Access Token
3. 重试失败的请求
4. 刷新失败则清除本地状态并跳转到登录页

### 角色相关 Token 有效期

| 角色 | Access Token | Refresh Token |
|------|-------------|---------------|
| 发送者 | 7 天 | 30 天 |
| 接收者 | 30 天 | 90 天 |

---

## 🔍 常见问题

### 问题 1：验证码发送失败

**原因**：手机号格式错误或短信额度不足

**解决**：
1. 检查手机号格式（应包含国家码，如 `+86 13800138000`）
2. 检查 CloudBase 控制台短信服务状态

### 问题 2：登录失败 401

**原因**：Publishable Key 未配置或过期

**解决**：
1. 检查 `.env` 中 `CLOUDBASE_PUBLISHABLE_KEY` 是否正确
2. 通过 MCP 工具重新获取最新密钥

### 问题 3：Token 刷新失败

**原因**：Refresh Token 已过期

**解决**：用户需要重新登录

---

## ✅ 配置检查清单

- [ ] 手机号登录已启用
- [ ] 短信服务已配置（默认或自定义）
- [ ] Publishable Key 已填入 `.env`
- [ ] 前端代码已使用 `AuthService`
- [ ] 发送验证码测试通过
- [ ] 验证码登录测试通过

---

**最后更新**：2026-04-09
