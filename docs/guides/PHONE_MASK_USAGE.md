# 手机号脱敏模块使用指南

## 📋 概述

`PhoneUtils` 是项目统一的手机号脱敏工具类，用于保护用户隐私。根据项目规范，**所有日志打印和 UI 显示中的手机号必须脱敏**。

## 🔧 模块位置

```
lib/utils/phone_utils.dart
```

## 📖 可用方法

### 1. `maskPhone(String phone)` - UI 显示脱敏

将手机号中间 4 位替换为 `****`

```dart
PhoneUtils.maskPhone('13812345678')       // → '138****5678'
PhoneUtils.maskPhone('+86 13812345678')  // → '138****5678'
PhoneUtils.maskPhone('13800138000')      // → '138****8000'
```

**使用场景**：UI 界面显示、列表项、对话框等

---

### 2. `maskForLog(String phone)` - 日志脱敏

带 `[脱敏]` 标记，便于日志审查时快速识别

```dart
PhoneUtils.maskForLog('13812345678')  // → '[脱敏]138****5678'
```

**使用场景**：所有 `Logs.xxx` 日志打印

---

### 3. `maskList(List<String> phones)` - 批量脱敏

用于列表显示等需要批量处理的场景

```dart
PhoneUtils.maskList(['13812345678', '13987654321'])  
// → ['138****5678', '139****4321']
```

---

### 4. `isValidPhone(String phone)` - 手机号验证

检查是否为有效的中国大陆 11 位手机号

```dart
PhoneUtils.isValidPhone('13812345678')  // → true
PhoneUtils.isValidPhone('123456')       // → false
PhoneUtils.isValidPhone('10123456789')  // → false (10x 开头无效)
```

---

### 5. `formatPhone(String phone)` - 格式化

将手机号格式化为 `3-4-4` 格式

```dart
PhoneUtils.formatPhone('13812345678')  // → '138 1234 5678'
```

---

## ✅ 正确使用示例

### UI 显示

```dart
// ✅ 正确：脱敏显示
Text(PhoneUtils.maskPhone(userPhone))

// ❌ 错误：直接显示完整手机号
Text(userPhone)
```

### 日志打印

```dart
// ✅ 正确：日志脱敏
Logs.auth.info('登录成功: ${PhoneUtils.maskForLog(phone)}');
Logs.api.info('请求体: phone_number=${PhoneUtils.maskForLog(phone)}');

// ❌ 错误：打印完整手机号
Logs.auth.info('登录成功: $phone');
```

### 列表显示

```dart
// ✅ 正确：列表项脱敏
ListView.builder(
  itemCount: users.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(PhoneUtils.maskPhone(users[index].phone)),
    );
  },
)
```

---

## 🚨 脱敏红线（必须遵守）

根据项目文档 `FRONTEND_DEVELOPMENT.md` 和 `INTERACTION_FLOWS.md`：

| 场景 | 要求 |
|------|------|
| **日志打印** | ❌ 绝对禁止打印完整手机号，必须脱敏后打印 |
| **UI 显示** | ✅ 所有界面展示的手机号必须脱敏：`138****5678` |
| **接收者可见** | 🔒 接收者只能看到发送者的脱敏手机号，无法获取完整号码 |
| **发送者可见** | 👁️ 发送者只能看到自己输入的完整号码，列表中也显示脱敏号码 |

---

## 📝 已脱敏的文件清单

| 文件 | 说明 |
|------|------|
| `lib/services/auth_service.dart` | 认证服务日志 |
| `lib/features/auth/widgets/code_input_card.dart` | 验证码发送提示 |
| `lib/features/receiver/receiver_home_page.dart` | 接收者主页绑定列表 |
| `lib/features/binding/binding_page.dart` | 绑定管理页面 |
| `lib/models/user_credentials.dart` | 用户凭据 toString() |
| `lib/models/login_info.dart` | 登录信息 toString() |

---

## 🔍 检查方法

提交代码前，搜索以下关键词确认是否遗漏脱敏：

```
phone    # 检查所有包含 phone 的变量
phoneNumber
receiver_phone
sender_phone
```

确保所有日志和 UI 显示都使用了 `PhoneUtils.maskPhone()` 或 `PhoneUtils.maskForLog()`。
