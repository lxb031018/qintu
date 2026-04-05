# 资源引用规范

> **版本**：v1.0.0
> **日期**：2026-04-05
> **说明**：本文档说明项目中所有可引用的资源文件、常量、字符串等，避免硬编码。

---

## 📋 目录

- [1. 字符串资源](#1-字符串资源)
- [2. 颜色资源](#2-颜色资源)
- [3. 配置资源](#3-配置资源)
- [4. 常量资源](#5-常量资源)
- [6. 使用规范](#6-使用规范)

---

## 1. 字符串资源

**文件位置**: `lib/constants/app_strings.dart`

**导入方式**:
```dart
import 'constants/app_strings.dart';
// 或
import 'package:qintu/constants/app_strings.dart';
```

### 1.1 应用基本信息

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.appName` | 亲途 | 应用名称 |
| `AppStrings.appSubtitle` | 指尖即是爱的方向 | 应用副标题 |

### 1.2 启动页

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.loading` | 加载中... | 加载中提示 |
| `AppStrings.loadingText` | 加载中... | 加载中提示（备用） |

### 1.3 认证页面

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.welcomeTitle` | 欢迎来到亲途 | 欢迎标题 |
| `AppStrings.loginSubtitle` | 使用手机号验证码登录 | 登录副标题 |
| `AppStrings.phoneHint` | 请输入 11 位手机号 | 手机号输入提示 |
| `AppStrings.phoneLabel` | 手机号 | 手机号标签 |
| `AppStrings.codeHint` | 请输入 6 位验证码 | 验证码输入提示 |
| `AppStrings.codeLabel` | 验证码 | 验证码标签 |
| `AppStrings.getVerificationCode` | 获取验证码 | 获取验证码按钮 |
| `AppStrings.login` | 登录 | 登录按钮 |
| `AppStrings.enterApp` | 进入应用 | 进入应用按钮 |
| `AppStrings.relogin` | 重新登录 | 重新登录 |
| `AppStrings.codeSent` | 验证码已发送至 | 验证码已发送 |
| `AppStrings.resendCode` | 重新发送验证码 | 重新发送验证码 |
| `AppStrings.loginSuccess` | 登录成功！ | 登录成功提示 |
| `AppStrings.userInfo` | 用户信息 | 用户信息 |

### 1.4 角色选择

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.roleSelectionTitle` | 欢迎使用亲途 | 角色选择标题 |
| `AppStrings.iAmReceiver` | 我是接收者 | 接收者角色按钮 |
| `AppStrings.iAmSender` | 我是发送者 | 发送者角色按钮 |
| `AppStrings.receiverRoleDescription` | 接收导航指引，轻松出行 | 接收者描述 |
| `AppStrings.senderRoleDescription` | 发送导航指引，帮助他人 | 发送者描述 |
| `AppStrings.roleSetSuccess` | 角色设置成功 | 角色设置成功 |

### 1.5 绑定管理

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.refreshSuccess` | 刷新成功 | 刷新成功提示 |
| `AppStrings.refresh` | 刷新 | 刷新按钮 |
| `AppStrings.revokeBinding` | 解除绑定 | 解除绑定按钮/对话框标题 |
| `AppStrings.revokeBindingConfirm` | 确定要解除这个绑定关系吗？ | 解除绑定确认 |
| `AppStrings.revokeBindingSuccess` | 解除绑定成功 | 解除绑定成功 |
| `AppStrings.revokeBindingFailed` | 解除绑定失败 | 解除绑定失败 |
| `AppStrings.currentBinding` | 当前绑定 | 当前绑定标题 |
| `AppStrings.asSender` | 作为发送者 | 作为发送者统计 |
| `AppStrings.asReceiver` | 作为接收者 | 作为接收者统计 |
| `AppStrings.limitReached` | 已达上限 | 达到上限提示 |
| `AppStrings.noBinding` | 暂无绑定关系 | 空绑定提示 |
| `AppStrings.addNewBinding` | 绑定新用户 | 绑定新用户按钮/提示 |
| `AppStrings.bindingLimitReached` | 绑定人数已达上限 | 绑定人数上限 |
| `AppStrings.sendBindingRequest` | 发送绑定请求 | 发送绑定请求 |
| `AppStrings.yourName` | 您的姓名（必填） | 姓名输入标签 |
| `AppStrings.partnerPhone` | 对方手机号（必填） | 手机号输入标签 |
| `AppStrings.sendRequest` | 发送请求 | 发送请求按钮 |
| `AppStrings.bindingRequestSent` | 绑定请求已发送，等待对方确认 | 请求已发送 |
| `AppStrings.pleaseFillName` | 请填写您的姓名 | 姓名为空提示 |
| `AppStrings.invalidPhone` | 请输入正确的手机号 | 手机号格式错误 |
| `AppStrings.loadFailed` | 加载失败 | 加载失败提示 |
| `AppStrings.retry` | 重试 | 重试按钮 |
| `AppStrings.receiver` | 接收者 | 接收者标签 |
| `AppStrings.sender` | 发送者 | 发送者标签 |
| `AppStrings.remark` | 备注 | 备注标签 |
| `AppStrings.unknownUser` | 未知用户 | 未知用户 |
| `AppStrings.active` | 生效中 | 生效中状态 |
| `AppStrings.pending` | 待确认 | 待确认状态 |
| `AppStrings.expired` | 已过期 | 已过期状态 |
| `AppStrings.revoked` | 已解除 | 已解除状态 |

### 1.6 设置与角色切换

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.settings` | 设置 | 设置页面标题 |
| `AppStrings.currentRole` | 当前角色 | 当前角色卡片标题 |
| `AppStrings.switchRole` | 切换角色 | 切换角色对话框标题 |
| `AppStrings.switchText` | 切换 | 切换按钮文字 |
| `AppStrings.switchRoleHint` | 点击右侧按钮切换角色 | 切换角色提示 |
| `AppStrings.roleReceiver` | 接收者端 | 接收者角色名称 |
| `AppStrings.roleSender` | 发送者端 | 发送者角色名称 |

### 1.7 退出登录

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.logout` | 退出 | 退出按钮 |
| `AppStrings.logoutConfirmTitle` | 您确定退出嘛？>_< | 退出确认标题 |
| `AppStrings.confirmLogout` | 确定 | 确定按钮 |
| `AppStrings.cancelLogout` | 取消 | 取消按钮 |

### 1.8 主题设置

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.themeLight` | 浅色 | 浅色主题 |
| `AppStrings.themeDark` | 深色 | 深色主题 |
| `AppStrings.themeSystem` | 跟随系统 | 跟随系统主题 |

### 1.9 位置权限

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.locationPermissionTitle` | 需要位置权限 | 位置权限标题 |
| `AppStrings.locationPermissionMessage` | 亲途需要获取您的位置信息以提供导航服务，请授权位置权限 | 位置权限说明 |
| `AppStrings.locationPermissionDenied` | 位置权限被拒绝，部分功能可能受限 | 位置权限拒绝 |
| `AppStrings.locationServiceDisabled` | 位置服务未开启，请在设置中开启 | 位置服务未开启 |
| `AppStrings.openLocation` | 点击开启定位 | 开启定位按钮 |
| `AppStrings.locationEnabled` | 定位已开启 | 定位已开启 |
| `AppStrings.locationDisabled` | 定位未开启 | 定位未开启 |
| `AppStrings.goToSettings` | 前往设置 | 前往设置按钮 |
| `AppStrings.later` | 稍后再说 | 稍后再说按钮 |

### 1.10 发送者端

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.senderHomeTitle` | 发送导航指引 | 发送者主页标题 |
| `AppStrings.inputStartPoint` | 输入起点 | 输入起点提示 |
| `AppStrings.inputEndPoint` | 输入终点 | 输入终点提示 |
| `AppStrings.startPointLabel` | 起点 | 起点标签 |
| `AppStrings.endPointLabel` | 终点 | 终点标签 |
| `AppStrings.planRoute` | 规划路线 | 规划路线按钮 |
| `AppStrings.sendNavigation` | 发送导航 | 发送导航按钮 |
| `AppStrings.selectReceiver` | 选择接收者 | 选择接收者 |

### 1.11 底部导航

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.tabHome` | 主页 | 主页 Tab |
| `AppStrings.tabBinding` | 绑定 | 绑定 Tab |
| `AppStrings.tabSettings` | 设置 | 设置 Tab |

### 1.12 错误提示

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.invalidPhoneNumber` | 请输入正确的 11 位手机号 | 手机号格式错误 |
| `AppStrings.invalidVerificationCode` | 请输入 6 位验证码 | 验证码格式错误 |
| `AppStrings.pleaseGetCodeFirst` | 请先获取验证码 | 请先获取验证码 |
| `AppStrings.codeSendFailed` | 验证码发送失败，请检查手机号是否正确 | 验证码发送失败 |
| `AppStrings.codeInvalidOrExpired` | 验证码错误或已过期，请重新获取 | 验证码错误或过期 |
| `AppStrings.codeInvalid` | 验证码错误，请重新输入 | 验证码错误 |
| `AppStrings.loginFailed` | 登录失败，请稍后重试 | 登录失败 |
| `AppStrings.registerFailed` | 注册失败，请稍后重试 | 注册失败 |
| `AppStrings.networkError` | 网络连接失败，请检查网络设置 | 网络连接失败 |
| `AppStrings.networkException` | 网络异常，请检查网络连接 | 网络异常 |
| `AppStrings.operationFailed` | 操作失败，请稍后重试 | 操作失败 |
| `AppStrings.codeSendTooFrequent` | 验证码发送过于频繁，请稍后再试 | 验证码发送频繁 |
| `AppStrings.settingFailed` | 设置失败 | 设置失败 |
| `AppStrings.saveFailed` | 保存失败，请重试 | 保存失败 |
| `AppStrings.saveRoleFailed` | 保存角色信息失败，请重试 | 保存角色失败 |

### 1.13 通用操作

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStrings.confirm` | 确定 | 确定按钮 |
| `AppStrings.cancel` | 取消 | 取消按钮 |
| `AppStrings.save` | 保存 | 保存按钮 |
| `AppStrings.delete` | 删除 | 删除按钮 |
| `AppStrings.edit` | 编辑 | 编辑按钮 |
| `AppStrings.back` | 返回 | 返回按钮 |

### 1.14 动态字符串方法

| 方法名 | 参数 | 返回值示例 | 说明 |
|--------|------|-----------|------|
| `resendCodeCountdown(seconds)` | `int seconds` | `重新发送 (30 秒)` | 验证码倒计时 |
| `roleSetSuccessMessage(role)` | `String role` | `您已选择接收者端，即将进入主页` | 角色设置成功消息 |

---

## 2. 颜色资源

**文件位置**: `lib/constants/app_colors.dart`

**导入方式**:
```dart
import 'constants/app_colors.dart';
```

### 2.1 品牌色

| 常量名 | 色值 | 说明 |
|--------|------|------|
| `AppColors.brandGreen` | `#4CAF50` | 品牌主色（绿色） |
| `AppColors.primaryColor` | `#4CAF50` | 主色调 |

### 2.2 功能色

| 常量名 | 色值 | 说明 |
|--------|------|------|
| `AppColors.successColor` | 绿色 | 成功状态色 |
| `AppColors.errorColor` | 红色 | 错误/危险状态色 |
| `AppColors.warningColor` | 橙色 | 警告状态色 |
| `AppColors.infoColor` | 蓝色 | 信息状态色 |

### 2.3 浅色主题颜色

| 常量名 | 说明 |
|--------|------|
| `AppColors.backgroundColor` | 背景色 |
| `AppColors.cardBackground` | 卡片背景色 |
| `AppColors.textColor` | 文本颜色 |
| `AppColors.lightTextColor` | 次要文本颜色 |
| `AppColors.borderColor` | 边框颜色 |
| `AppColors.focusBorderColor` | 聚焦边框颜色 |

### 2.4 深色主题颜色

| 常量名 | 说明 |
|--------|------|
| `AppColors.darkBackgroundColor` | 深色背景色 |
| `AppColors.darkCardBackground` | 深色卡片背景色 |
| `AppColors.darkTextColor` | 深色文本颜色 |
| `AppColors.darkLightTextColor` | 深色次要文本颜色 |
| `AppColors.darkDividerColor` | 深色分割线颜色 |
| `AppColors.darkBorderColor` | 深色边框颜色 |
| `AppColors.darkInputBackground` | 深色输入框背景色 |
| `AppColors.darkInputHintColor` | 深色输入框提示色 |
| `AppColors.darkOnPrimaryColor` | 深色主题主色上的颜色 |

---

## 3. 配置资源

### 3.1 UI 配置

**文件位置**: `lib/config/ui_config.dart`

**导入方式**:
```dart
import 'config/ui_config.dart';
```

| 常量名 | 说明 |
|--------|------|
| `UIConfig.appName` | 应用名称 |
| `UIConfig.fontFamily` | 字体族 |
| `UIConfig.titleFontSize` | 标题字体大小 |
| `UIConfig.subtitleFontSize` | 副标题字体大小 |
| `UIConfig.bodyFontSize` | 正文字体大小 |
| `UIConfig.buttonFontSize` | 按钮字体大小 |
| `UIConfig.borderRadius` | 圆角大小 |
| `UIConfig.buttonHeight` | 按钮高度 |

### 3.2 CloudBase 配置

**文件位置**: `lib/config/cloudbase_config.dart`

| 常量名 | 说明 |
|--------|------|
| `CloudBaseConfig.envId` | 云开发环境 ID |
| `CloudBaseConfig.region` | 环境区域 |

### 3.3 认证配置

**文件位置**: `lib/config/auth_config.dart`

| 常量名 | 说明 |
|--------|------|
| `AuthConfig.tokenExpiresIn` | Token 过期时间 |
| `AuthConfig.codeExpiresIn` | 验证码过期时间 |
| `AuthConfig.codeResendInterval` | 验证码重发间隔 |

---

## 4. 常量资源

### 4.1 角色常量

**文件位置**: `lib/constants/app_roles.dart`

**导入方式**:
```dart
import 'constants/app_roles.dart';
```

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppRoles.sender` | `sender` | 发送者角色 |
| `AppRoles.receiver` | `receiver` | 接收者角色 |
| `AppRoles.both` | `both` | 两者皆可 |

### 4.2 状态常量

**文件位置**: `lib/constants/app_statuses.dart`

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `AppStatuses.active` | `active` | 活跃状态 |
| `AppStatuses.disabled` | `disabled` | 禁用状态 |

### 4.3 存储键常量

**文件位置**: `lib/constants/storage_keys.dart`

| 常量名 | 说明 |
|--------|------|
| `StorageKeys.userId` | 用户 ID 存储键 |
| `StorageKeys.accessToken` | 访问令牌存储键 |
| `StorageKeys.refreshToken` | 刷新令牌存储键 |
| `StorageKeys.userRole` | 用户角色存储键 |
| `StorageKeys.phoneNumber` | 手机号存储键 |

### 4.4 API 端点常量

**文件位置**: `lib/constants/api_endpoints.dart`

| 常量名 | 说明 |
|--------|------|
| `ApiEndpoints.users` | 用户管理端点 |
| `ApiEndpoints.bindings` | 绑定关系端点 |
| `ApiEndpoints.tasks` | 导航任务端点 |
| `ApiEndpoints.locations` | 位置共享端点 |

### 4.5 时间间隔常量

**文件位置**: `lib/constants/app_durations.dart`

| 常量名 | 说明 |
|--------|------|
| `AppDurations.codeResend` | 验证码重发间隔 |
| `AppDurations.snackBar` | SnackBar 显示时长 |
| `AppDurations.animation` | 动画默认时长 |

---

## 5. 通用常量

**文件位置**: `lib/utils/constants.dart`

**导入方式**:
```dart
import 'utils/constants.dart';
```

| 常量名 | 说明 |
|--------|------|
| `Constants.baseUrl` | API 基础 URL |
| `Constants.maxReceiversPerSender` | 发送者最大接收者数量（5） |
| `Constants.maxSendersPerReceiver` | 接收者最大发送者数量（3） |

---

## 6. 使用规范

### 6.1 禁止硬编码

❌ **错误示例**:
```dart
Text('亲途')
Text('加载中...')
Text('确定')
SizedBox(height: 16)  // 应使用 UIConfig
Color(0xFF4CAF50)     // 应使用 AppColors
```

✅ **正确示例**:
```dart
Text(AppStrings.appName)
Text(AppStrings.loading)
Text(AppStrings.confirm)
SizedBox(height: UIConfig.spacingMedium)
AppColors.brandGreen
```

### 6.2 导入规范

1. **同一模块内**：使用相对路径导入
   ```dart
   import '../../constants/app_strings.dart';
   ```

2. **跨模块或从 lib/ 根目录**：使用 package 导入
   ```dart
   import 'package:qintu/constants/app_strings.dart';
   ```

3. **禁止使用** `../` 超过 3 层的相对路径

### 6.3 命名规范

- 字符串常量使用 **camelCase** 命名
- 颜色常量使用 **PascalCase** 命名
- 配置常量使用 **PascalCase** 类名 + **camelCase** 属性名

### 6.4 新增资源流程

1. 在对应的 `app_strings.dart`、`app_colors.dart` 等文件中添加常量
2. 添加清晰的文档注释说明用途
3. 在代码中使用新的常量
4. 更新本文档

### 6.5 动态字符串

对于需要动态生成的字符串（如倒计时、角色名称），应：

1. 在 `AppStrings` 中定义静态方法
2. 方法接受参数并返回格式化后的字符串

```dart
// ✅ 正确示例
static String resendCodeCountdown(int seconds) => '重新发送 ($seconds 秒)';

// 使用
Text(AppStrings.resendCodeCountdown(30))
```

---

## 7. 资源文件结构

```
lib/
├── constants/
│   ├── app_strings.dart    # 字符串资源
│   ├── app_colors.dart     # 颜色资源
│   ├── app_roles.dart      # 角色常量
│   ├── app_statuses.dart   # 状态常量
│   ├── api_endpoints.dart  # API 端点
│   ├── app_durations.dart  # 时间间隔
│   └── storage_keys.dart   # 存储键
├── config/
│   ├── ui_config.dart          # UI 配置
│   ├── cloudbase_config.dart   # CloudBase 配置
│   └── auth_config.dart        # 认证配置
└── utils/
    └── constants.dart      # 通用常量
```

---

## 8. 检查清单

在提交代码前，请确认：

- [ ] 所有用户可见的文字都使用了 `AppStrings`
- [ ] 所有颜色都使用了 `AppColors`
- [ ] 所有尺寸常量都使用了 `UIConfig` 或 `AppDurations`
- [ ] 所有 API 端点都使用了 `ApiEndpoints`
- [ ] 没有硬编码的魔法数字或字符串

---

**最后更新**: 2026-04-05
**维护人员**: 开发团队
