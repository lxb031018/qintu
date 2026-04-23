# 亲途 (Qintu) 前端开发规范

> **版本**：v4.0.0
> **日期**：2026-04-17
> **说明**：本文档是前端开发的最高指导原则，所有代码编写必须遵守。

---

## 📋 目录

- [1. 目录结构](#1-目录结构)
- [2. 页面设计规范](#2-页面设计规范)
- [3. 组件化规范](#3-组件化规范)
- [4. 状态管理](#4-状态管理)
- [5. 日志与隐私](#5-日志与隐私)
- [6. 异常处理](#6-异常处理)
- [7. 代码规范](#7-代码规范)
- [8. 测试与发布](#8-测试与发布)

---

## 1. 目录结构

### 1.1 Feature-First 架构

```
lib/
├── features/                 # 功能模块（主架构）
│   ├── auth/               # 认证模块（登录）
│   ├── map_navigation/     # 地图导航模块（复杂）
│   ├── relationship_binding/  # 关系绑定模块（复杂）
│   └── settings/           # 设置模块（简单）
├── providers/              # 全局状态 Provider
├── models/                # 数据模型（Freezed）
├── services/              # 服务层
├── constants/             # 常量
├── config/                # 配置管理
├── theme/                # 主题配置
├── router/               # 路由配置
├── widgets/              # 公共组件
├── utils/                # 工具类
└── main.dart
```

### 1.2 功能模块标准结构

**复杂模块**（功能多、需要分离关注点）：

```
features/{module}/
├── {module}_tab.dart              # 0级：主页面
├── {module}_controller.dart       # 0级：控制器
├── widgets/                       # 0级：公共组件
└── {sub_module}/                 # 1级子模块
    ├── {sub_module}_page.dart
    ├── {sub_module}_controller.dart
    └── widgets/
```

**简单模块**（功能单一、文件少）：

```
features/{module}/
├── {module}_page.dart            # 主页面
└── widgets/                      # 组件
```

### 1.3 严格分层 — 职责单一原则（SRP）

**核心原则：一个类只做一件事，修改它的理由应该只有一个。**

#### 分层职责定义

| 层级 | 职责 | 应该做的 | 禁止事项 | 指导行数 |
|------|------|---------|---------|---------|
| **View/UI** | 渲染 UI，响应用户交互 | 构建 Widget 树、监听 Provider 状态、触发 Provider 方法 | 禁止直接调用 Service、禁止复杂业务逻辑 | < 300 行 |
| **Provider** | 管理 UI 状态，桥接 Service 和 Widget | 管理状态、调用 Service、notifyListeners() | 禁止写 HTTP 细节 | < 200 行 |
| **Service** | 封装通用技术能力 | HTTP 请求、本地存储、第三方 SDK 封装 | 禁止业务决策、禁止 import Flutter Widget | < 300 行 |
| **Model** | 纯数据载体 | 数据结构定义、JSON 序列化 | 禁止网络请求、禁止复杂业务判断 | < 100 行 |

#### 红线

| 规则 | 反例 |
|------|------|
| **Service 不感知 UI** | `SecureStorage` 里弹 Toast |
| **Provider 不写 HTTP 细节** | `BindingProvider` 里写 `options: {'timeout': 5000}` |
| **Model 不做外部依赖查询** | `User` 里查询数据库判断权限 |
| **Widget 不直接调 Service** | `AuthPage` 直接 `ApiClient.post()` |

---

## 2. 页面设计规范

### 2.1 颜色规范

| 用途 | 颜色值 | 说明 |
|------|--------|------|
| 主色调 | `#FF8C69` | 珊瑚橙，代表温暖、关怀 |
| 辅助色 | `#FF9800` | 橙色，用于提醒、警告 |
| 成功 | `#4CAF50` | 绿色，导航完成、绑定成功 |
| 错误 | `#F44336` | 红色，网络错误、操作失败 |

**使用方式**：
```dart
// ✅ 正确：使用颜色常量
color: AppColors.primaryColor

// ❌ 错误：硬编码颜色
color: Color(0xFFFF8C69)
```

### 2.2 字体规范

项目使用 `AppTextStyles` 统一管理所有文字样式，支持动态字体缩放。

```dart
// ✅ 正确：使用 AppTextStyles
Text('欢迎', style: AppTextStyles.titleSmall)
Text('说明', style: AppTextStyles.bodyMedium)
Text('提交', style: AppTextStyles.button)

// ❌ 错误：硬编码 fontSize
Text('欢迎', style: TextStyle(fontSize: 24))
```

### 2.3 间距规范

- 页面内边距：16px
- 卡片间距：12px
- 组件间距：8px

### 2.4 圆角规范

- 卡片圆角：8px
- 按钮圆角：8px
- 输入框圆角：8px
- 对话框圆角：12px

### 2.5 深色/浅色主题

- 所有页面必须同时适配深色和浅色主题
- 使用 `Theme.of(context)` 动态获取颜色
- 禁止硬编码颜色值

---

## 3. 组件化规范

### 3.1 组件拆分原则

- 单个 Widget 文件不超过 300 行
- 独立逻辑块必须拆分为私有组件
- 可复用组件应提取到 `lib/widgets/` 目录

### 3.2 组件命名

- 组件类名：大驼峰 + Widget 后缀（`PhoneInputCard`）
- 组件文件名：小写下划线（`phone_input_card.dart`）

### 3.3 组件参数

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
}
```

---

## 4. 状态管理

### 4.1 Provider 模式

```dart
class AuthStateManager extends ChangeNotifier {
  AuthState _state = AuthState.initial();
  AuthState get state => _state;

  Future<void> setAuthenticated(...) async {
    _state = _state.copyWith(authStatus: AuthStatus.authenticated);
    notifyListeners();
  }
}
```

### 4.2 Provider 使用

```dart
// ✅ 使用 Consumer
Consumer<AuthStateManager>(
  builder: (context, authStateManager, child) {
    return Text(authStateManager.state.userId ?? '');
  },
)

// ✅ 直接读取状态
Provider.of<AuthStateManager>(context, listen: false).state

// ✅ 使用 .value 注入
ChangeNotifierProvider.value(value: _authStateManager)
```

### 4.3 Provider 列表

| Provider | 职责 | 位置 |
|----------|------|------|
| `AuthStateManager` | 认证状态和 Token | `lib/providers/auth_state_manager.dart` |
| `BindingProvider` | 绑定关系状态 | `lib/providers/binding_provider.dart` |
| `ThemeManager` | 主题状态 | `lib/providers/theme_manager.dart` |
| `SettingsManager` | 设置状态 | `lib/providers/settings_manager.dart` |

---

## 5. 日志与隐私

### 5.1 必须添加日志

关键路径必须打印日志：
```dart
Logs.auth.info('发送验证码, phone: ${maskPhone(phone)}');
Logs.api.info('API请求: POST /api/bindings/my');
```

### 5.2 隐私脱敏（红线）

- **日志脱敏**：绝对禁止在日志中打印完整手机号、密码、Token
- **UI 脱敏**：所有界面展示的敏感信息默认隐藏

```dart
// ✅ 正确：脱敏处理
Logs.auth.info('登录成功, phone: ${PhoneUtils.maskForLog(phone)}');

// ❌ 错误：打印完整手机号
Logs.auth.info('登录成功, phone: $phone');
```

---

## 6. 异常处理

### 6.1 不静默失败

```dart
try {
  await authService.login(phone, code);
} catch (e) {
  // 1. 打印日志
  Logs.auth.error('登录失败: $e');

  // 2. 用户反馈
  AppSnackbar.showError(context, '登录失败，请重试');

  // 3. 状态恢复
  setState(() => _isLoading = false);
}
```

### 6.2 降级策略

- 网络请求失败时，提供重试机制
- 关键服务不可用时，提供明确的引导

---

## 7. 代码规范

### 7.1 静态分析

- **强制命令**：提交前必须运行 `flutter analyze` 并通过
- **代码清理**：消除所有 Unused import、Unused variable

### 7.2 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | 大驼峰 | `AuthPage` |
| 变量/方法 | 小驼峰 | `fetchUserInfo` |
| 私有成员 | 下划线开头 | `_isLoading` |
| 文件命名 | 全小写下划线 | `auth_page.dart` |

---

## 8. 测试与发布

### 8.1 开发者自测

- 编码完成后，必须确保代码可以成功编译
- 使用模拟数据验证业务逻辑闭环

### 8.2 真机验收

- 核心功能（定位、导航、扫码）必须在真机上验证

---

**文档版本**：v4.0.0
**更新日期**：2026-04-17
