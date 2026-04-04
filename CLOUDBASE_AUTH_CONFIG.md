# CloudBase Auth 配置指南

## 概述

本文档指导你如何配置 CloudBase Auth 以支持手机号验证码登录功能。

---

## 前置条件

- ✅ CloudBase 环境 ID：`qintu-cloudebase-5f5bpuj13bc6467`
- ✅ Publishable Key：已在 `.env` 文件中配置
- ⚠️ 短信签名和模板 ID：需要在腾讯云控制台申请

---

## 配置步骤

### 步骤 1：登录 CloudBase 控制台

1. 访问 [CloudBase 控制台](https://console.cloud.tencent.com/tcb)
2. 选择环境：`qintu-cloudebase-5f5bpuj13bc6467`

### 步骤 2：启用手机号登录

1. 进入 **身份验证** → **登录方式**
2. 找到 **手机号登录**
3. 点击 **启用**

### 步骤 3：配置短信服务

有两种方式：

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

### 步骤 4：配置 Publishable Key

1. 进入 **环境** → **API Key 管理**
2. 找到类型为 `publish_key` 的密钥
3. 复制密钥到 `.env` 文件：
   ```env
   CLOUDBASE_PUBLISHABLE_KEY=你的publishable_key
   ```

### 步骤 5：配置云函数环境变量

在 CloudBase 控制台 → 云函数 → `qintu-api` → 配置 → 环境变量：

```env
# CloudBase 环境 ID
TCB_ENV=qintu-cloudebase-5f5bpuj13bc6467
CLOUDBASE_ENV_ID=qintu-cloudebase-5f5bpuj13bc6467

# 短信配置（如果使用自定义短信）
SMS_SIGN_ID=你的短信签名ID
SMS_TEMPLATE_ID=你的短信模板ID

# 数据库配置
DB_HOST=你的数据库主机地址
DB_USER=数据库用户名
DB_PASSWORD=数据库密码
DB_NAME=qintu
```

---

## 验证配置

### 方法 1：使用 CloudBase CLI

```bash
# 查看登录配置
cloudbase run --action DescribeLoginConfig --param EnvId=qintu-cloudebase-5f5bpuj13bc6467
```

期望输出：
```json
{
  "PhoneNumberLogin": true,
  "SmsVerificationConfig": {
    "Type": "default",
    "SmsDayLimit": 30
  }
}
```

### 方法 2：测试发送验证码

使用 curl 测试：

```bash
curl -X POST "https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/api/auth/send-code" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_PUBLISHABLE_KEY" \
  -d '{"phone_number": "+86 你的手机号"}'
```

---

## 当前状态

### ✅ 已完成

1. **后端云函数** - 所有认证路由已实现
   - `POST /api/auth/send-code` - 发送验证码
   - `POST /api/auth/verify-code` - 验证验证码
   - `POST /api/auth/sign-in` - 用户登录
   - `POST /api/auth/sign-up` - 用户注册
   - `POST /api/auth/refresh-token` - 刷新令牌
   - `POST /api/auth/sign-out` - 用户登出

2. **前端服务** - 完整的认证流程
   - `auth_service.dart` - 认证服务
   - `auth_page.dart` - 登录页面
   - 模拟模式支持

3. **数据库** - 用户表已创建
   - `users` 表包含必要字段

### ⚠️ 待配置

1. CloudBase Auth 提供者（手机号登录）
2. 短信签名和模板（或使用默认服务）
3. 云函数环境变量

---

## 两种运行模式

### 模拟模式（开发测试）

**适用场景**：开发阶段，不需要真实短信

**配置**：
- 不配置 `SMS_SIGN_ID` 和 `SMS_TEMPLATE_ID`
- 前端设置 `useMockAuth = true`

**使用**：
1. 输入任意 11 位手机号
2. 点击发送验证码
3. 使用固定验证码 `123456`
4. 完成登录

### 真实模式（生产环境）

**适用场景**：生产环境，需要真实发送短信

**配置**：
1. 配置短信签名和模板 ID
2. 在 CloudBase 控制台启用手机号登录
3. 前端设置 `useMockAuth = false`

**使用**：
1. 输入真实手机号
2. 接收真实短信验证码
3. 输入验证码完成登录

---

## 故障排查

### 问题 1：验证码发送失败

**可能原因**：
- 未配置短信签名/模板
- 手机号格式错误
- 超出每日限制

**解决方案**：
- 检查云函数日志
- 确认环境变量配置
- 验证手机号格式为 `+86 13800138000`

### 问题 2：用户注册失败

**可能原因**：
- 数据库未连接
- 用户已存在
- 字段约束冲突

**解决方案**：
- 检查数据库连接
- 查看云函数错误日志
- 验证数据库表结构

### 问题 3：Token 验证失败

**可能原因**：
- Token 已过期
- Token 格式错误
- 存储问题

**解决方案**：
- 重新登录获取新 Token
- 检查请求头格式
- 清除本地存储重试

---

## 下一步

配置完成后：

1. 部署云函数到 CloudBase
2. 测试完整登录流程
3. 验证用户数据保存到数据库
4. 测试 Token 刷新和登出功能

---

## 参考资源

- [CloudBase 认证文档](https://docs.cloudbase.net/authentication/)
- [短信服务文档](https://docs.cloudbase.net/authentication/sms/)
- [API Key 管理](https://tcb.cloud.tencent.com/dev?#/identity/token-management)
