# 亲途 (Qintu) 前端开发规范

> **版本**：v1.0.0
> **日期**：2026-04-05
> **说明**：本文档是前端开发的最高指导原则，所有代码编写必须遵守。

---

## 📋 目录

- [1. 架构设计](#1-架构设计)
- [2. 目录结构](#2-目录结构)
- [3. 底部三 Tab 架构](#3-底部三-tab-架构)
- [4. 页面设计规范](#4-页面设计规范)
- [5. 组件化规范](#5-组件化规范)
- [6. 状态管理](#6-状态管理)
- [7. API 接口规范](#7-api-接口规范)
- [8. 日志与隐私](#8-日志与隐私)
- [9. 异常处理](#9-异常处理)
- [10. 代码规范](#10-代码规范)

---

## 1. 架构设计

### 1.1 Feature-First 架构

采用 **Feature-First** 架构，按功能模块组织代码：

```
lib/
├── features/              # 功能模块（主架构）
│   ├── auth/             # 认证模块
│   ├── home/             # 主页模块（Home Tab）
│   ├── binding/          # 绑定模块（绑定 Tab）
│   ├── settings/         # 设置模块（设置 Tab）
│   ├── receiver/         # 接收者模块
│   └── sender/           # 发送者模块
├── core/                 # 核心模块（跨功能共享）
│   ├── config/           # 配置
│   ├── constants/        # 常量
│   ├── services/         # 服务层
│   ├── models/           # 数据模型
│   ├── utils/            # 工具类
│   └── router/           # 路由管理
├── providers/            # 全局状态 Provider
└── main.dart             # 应用入口
```

### 1.2 严格分层

| 层级 | 职责 | 禁止事项 |
|------|------|----------|
| **View/UI** | 显示、布局、响应用户点击 | 禁止包含 API 调用、数据库操作、复杂计算 |
| **Provider/State** | 状态管理、调度业务逻辑 | 禁止直接操作 UI 组件实例 |
| **Service/Repo** | 网络请求、本地存储、SDK 封装 | 禁止包含 Flutter Widget 代码 |

### 1.3 组件化

- **拒绝巨型文件**：如果一个 UI 文件超过 300 行，必须拆分为更小的私有组件
- **常量集中**：所有颜色、字体、字符串、API 路径必须从 `lib/constants/` 或 `lib/config/` 引用，禁止硬编码

---

## 2. 目录结构

### 2.1 功能模块标准结构

每个功能模块（Feature）的标准结构：

```
features/{module}/
├── {module}_page.dart      # 主页面
├── widgets/                # 模块私有组件
│   ├── {widget}_card.dart
│   └── {widget}_button.dart
└── providers/              # 模块状态管理（可选）
    └── {module}_provider.dart
```

### 2.2 核心模块结构

```
core/
├── config/                 # 配置
│   ├── app_config.dart
│   ├── cloudbase_config.dart
│   └── ui_config.dart
├── constants/              # 常量
│   ├── app_colors.dart
│   ├── app_strings.dart
│   ├── api_endpoints.dart
│   └── storage_keys.dart
├── services/               # 服务层
│   ├── auth_service.dart
│   ├── api_service.dart
│   └── secure_storage.dart
├── models/                 # 数据模型
│   ├── user.dart
│   └── binding.dart
├── utils/                  # 工具类
│   ├── logger.dart
│   └── exceptions.dart
└── router/                 # 路由管理
    └── app_router.dart
```

---

## 3. 底部三 Tab 架构

### 3.1 发送者端底部导航栏

```
┌─────────────────────────────┐
│  features/                   │
│  ├── home/          🏠      │  ← Home Tab：路径规划、发送导航
│  ├── binding/       🔗      │  ← 绑定 Tab：管理绑定关系
│  └── settings/      ⚙️      │  ← 设置 Tab：应用设置、账号管理
└─────────────────────────────┘
```

### 3.2 各 Tab 职责

| Tab | 模块 | 职责 | 包含页面 |
|-----|------|------|----------|
| **主页** 🏠 | `features/home/` | 路径规划、发送导航 | 主页、路线预览、监护页 |
| **绑定** 🔗 | `features/binding/` | 管理绑定关系 | 绑定管理页（添加、解绑） |
| **设置** ⚙️ | `features/settings/` | 应用设置、账号管理 | 设置页、菜单页 |

### 3.3 设计原则

- ✅ **职责专一**：每个 Tab 只负责一个核心功能
- ✅ **解绑在绑定页**：解绑操作在"绑定"Tab 中进行，不在设置页
- ✅ **Home 专注核心**：主页只处理路径规划和发送导航，不混杂其他功能

### 3.4 接收者端底部导航栏

```
┌─────────────────────────────┐
│  features/                   │
│  ├── receiver/      🏠      │  ← 主页：等待导航任务
│  ├── binding_req/   🔔      │  ← 绑定请求：查看和管理绑定请求
│  └── settings/      ⚙️      │  ← 设置：应用设置、账号管理
└─────────────────────────────┘
```

---

## 4. 页面设计规范

### 4.1 线框图遵守

- **必须严格遵守** `docs/archive/WIREFRAMES.md` 中的页面设计
- 页面布局、按钮位置、交互流程必须与线框图一致
- 如需修改，必须先更新线框图文档

### 4.2 颜色规范

| 用途 | 颜色值 | 说明 |
|------|--------|------|
| 主色调 | `#4CAF50` | 绿色，代表安全、出行 |
| 辅助色 | `#FF9800` | 橙色，用于提醒、警告 |
| 成功 | `#4CAF50` | 导航完成、绑定成功 |
| 错误 | `#F44336` | 网络错误、操作失败 |
| 背景 | `#F5F5F5` | 浅灰色背景 |
| 卡片 | `#FFFFFF` | 白色卡片背景 |

**使用方式**：
```dart
// ✅ 正确：使用颜色常量
color: AppColors.brandGreen

// ❌ 错误：硬编码颜色
color: Color(0xFF4CAF50)
```

### 4.3 字体规范

| 元素 | 发送者端 | 接收者端 |
|------|---------|---------|
| 标题 | 20sp | 24sp |
| 正文 | 16sp | 20sp |
| 按钮 | 18sp | 22sp |
| 提示文字 | 14sp | 18sp |

### 4.4 间距规范

- 页面内边距：16px
- 卡片间距：12px
- 组件间距：8px
- 按钮内边距：12px

### 4.5 圆角规范

- 卡片圆角：8px
- 按钮圆角：8px
- 输入框圆角：8px
- 对话框圆角：12px

### 4.6 深色/浅色主题

- 所有页面必须同时适配深色和浅色主题
- 使用 `Theme.of(context)` 动态获取颜色
- 禁止硬编码颜色值

---

## 5. 组件化规范

### 5.1 组件拆分原则

- 单个 Widget 文件不超过 300 行
- 独立逻辑块必须拆分为私有组件
- 可复用组件应提取到 `lib/widgets/` 目录

### 5.2 组件命名

- 组件类名：大驼峰 + Widget 后缀（`PhoneInputCard`）
- 组件文件名：小写下划线（`phone_input_card.dart`）

### 5.3 组件参数

- 使用 `const` 构造函数
- 必填参数使用 `required` 关键字
- 可选参数提供默认值

```dart
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

---

## 6. 状态管理

### 6.1 Provider 模式

使用 Provider 进行全局状态管理：

```dart
class UserProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
```

### 6.2 Provider 使用

```dart
// ✅ 正确：使用 Consumer
Consumer<UserProvider>(
  builder: (context, userProvider, child) {
    return Text(userProvider.user?.name ?? '');
  },
)

// ❌ 错误：直接调用 Provider.of
Provider.of<UserProvider>(context).user
```

### 6.3 Provider 列表

| Provider | 职责 | 位置 |
|----------|------|------|
| `UserProvider` | 用户信息和登录状态 | `lib/providers/user_provider.dart` |
| `BindingProvider` | 绑定关系状态和操作 | `lib/providers/binding_provider.dart` |
| `TaskProvider` | 导航任务状态 | `lib/providers/task_provider.dart` |

---

## 7. API 接口规范

### 7.1 CloudBase 官方 API 优先

**核心原则**：能使用 CloudBase 官方 API 实现的功能，绝不自己写后端。

### 7.2 认证 API

使用 CloudBase 官方 Auth API：

```dart
// ✅ 正确：调用官方 Auth API
final response = await http.post(
  Uri.parse('https://$envId.api.tcloudbasegateway.com/auth/v1/verification'),
  headers: {'Authorization': 'Bearer $publishableKey'},
  body: jsonEncode({'phone_number': '+86 13800138000'}),
);

// ❌ 错误：自己写后端实现
```

### 7.3 业务 API

业务相关 API 通过云函数调用：

```dart
// 云函数基础地址
const baseUrl = 'https://$envId.api.tcloudbasegateway.com/v1/functions/qintu-api?webfn=true';

// 绑定关系 API
POST /api/bindings/generate   // 生成绑定码
POST /api/bindings/confirm    // 确认绑定
GET  /api/bindings/my         // 获取我的绑定关系
DELETE /api/bindings/{id}     // 解除绑定

// 导航任务 API
POST /api/tasks               // 创建任务
GET  /api/tasks/my            // 获取我的任务
POST /api/tasks/{id}/accept   // 接受任务
POST /api/tasks/{id}/complete // 完成任务
```

### 7.4 API 响应格式

统一响应格式：

```dart
// 成功响应
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": { ... }
}

// 错误响应
{
  "code": "ERROR_CODE",
  "message": "错误描述"
}
```

---

## 8. 日志与隐私

### 8.1 日志规范

- 关键路径必须打印日志（登录、绑定、网络请求、状态切换）
- 使用分级日志：`Logs.app.info()`, `Logs.app.error()`
- 日志格式：`[模块名] 操作描述, 关键参数: 值`

```dart
Logs.auth.info('发送验证码, phone: ${maskPhone(phone)}');
Logs.api.info('API请求: POST ${url.toString()}');
```

### 8.2 隐私脱敏

- **日志脱敏**：禁止在日志中打印完整手机号、Token
- **UI 脱敏**：敏感信息默认隐藏，支持"点击眼睛图标短暂显示"
- **传输加密**：所有敏感数据传输必须通过 HTTPS

```dart
// ✅ 正确：脱敏处理
Logs.auth.info('登录成功, phone: ${maskPhone(phone)}');

// ❌ 错误：打印完整手机号
Logs.auth.info('登录成功, phone: $phone');
```

---

## 9. 异常处理

### 9.1 不静默失败

```dart
try {
  await authService.login(phone, code);
} catch (e) {
  // 1. 打印日志
  Logs.auth.error('登录失败: $e');
  
  // 2. 用户反馈
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('登录失败，请重试')),
  );
  
  // 3. 状态恢复
  setState(() => _isLoading = false);
}
```

### 9.2 降级策略

- 网络请求失败时，提供重试机制或引导用户检查网络
- 关键服务不可用时，提供明确的引导设置入口

---

## 10. 代码规范

### 10.1 静态分析

- 每次功能开发完成后，必须运行 `flutter analyze` 并通过
- 消除所有 Unused import、Unused variable

### 10.2 命名规范

- **类名**：大驼峰 (`ReceiverHomePage`)
- **变量/方法**：小驼峰 (`fetchUserInfo`)
- **私有成员**：下划线开头 (`_isLoading`)
- **文件命名**：全小写下划线 (`user_repository.dart`)

### 10.3 页面主题一致性

- 统一 AppBar 样式
- 统一颜色方案（使用 `AppColors`）
- 统一字体大小
- 统一间距规范
- 统一圆角风格
- 统一深色/浅色适配

---

## 📝 踩坑经验记录

### 1. CloudBase 官方 Auth API

**问题**：发送验证码时传递 `target=any` 参数导致 400 错误

**错误信息**：
```
invalid value for enum type: "any"
```

**解决方案**：
```dart
// ✅ 正确：只传递 phone_number
body: jsonEncode({
  'phone_number': phoneNumber,
})

// ❌ 错误：多余的参数
body: jsonEncode({
  'phone_number': phoneNumber,
  'target': 'any',  // ❌ 不支持
  'type': 'phoneNumberLogin',  // ❌ 不需要
})
```

### 2. 手机号格式

**要求**：必须为 `"+86 13800138000"`（带 "+86 " 前缀和空格）

```dart
final formattedPhone = '+86 ${phoneController.text.trim()}';
```

### 3. 云函数 HTTP 调用

**URL 格式**：
```
https://$envId.api.tcloudbasegateway.com/v1/functions/qintu-api?webfn=true
```

必须添加 `?webfn=true` 参数，否则调用失败。

---

**文档版本**：v1.0.0
**更新日期**：2026-04-05
**维护人员**：开发团队
