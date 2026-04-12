# 亲途 (Qintu) 前端开发规范

> **版本**：v2.0.0
> **日期**：2026-04-05
> **说明**：本文档是前端开发的最高指导原则，所有代码编写必须遵守。

---

## 📋 目录

- [1. 文档驱动开发](#1-文档驱动开发)
- [2. 架构设计](#2-架构设计)
- [3. 目录结构](#3-目录结构)
- [4. 角色架构设计](#4-角色架构设计)
- [5. 页面设计规范](#5-页面设计规范)
- [6. 组件化规范](#6-组件化规范)
- [7. 状态管理](#7-状态管理)
- [8. API 接口规范](#8-api-接口规范)
- [9. 日志与隐私](#9-日志与隐私)
- [10. 异常处理](#10-异常处理)
- [11. 代码规范](#11-代码规范)
- [12. 测试与发布](#12-测试与发布)
- [13. CloudBase 后端开发规范](#13-cloudbase-后端开发规范)

---

## 1. 文档驱动开发

### 1.1 文档先行
- **规划优先**：所有核心功能在编码前必须在 `docs/archive/` 下有线框图 (`WIREFRAMES.md`) 和交互流程 (`INTERACTION_FLOWS.md`)。
- **同步更新**：修改代码逻辑时，必须同步更新对应文档。如果文档与代码不符，视为 Bug。

### 1.2 经验沉淀
- **踩坑记录**：开发中遇到的环境配置、第三方库兼容性问题，必须记录到文档的 `技术实现要点` 章节，作为后续开发的避坑指南。

---

## 2. 架构设计

### 2.1 Feature-First 架构

采用 **Feature-First** 架构，按功能模块组织代码：

```
lib/
├── features/              # 功能模块（主架构）
│   ├── auth/             # 认证模块
│   ├── receiver/         # 接收者模块（老人端 - 简洁单页）
│   ├── sender/           # 发送者模块（子女端 - 三Tab架构）
│   ├── binding/          # 绑定模块（绑定 Tab）
│   ├── settings/         # 设置模块（设置 Tab）
│   └── role/             # 角色选择模块
├── core/                 # 核心模块（跨功能共享）
│   ├── config/           # 配置
│   ├── constants/        # 常量
│   ├── services/         # 服务层
│   ├── models/           # 数据模型
│   ├── utils/            # 工具类
│   └── router/           # 路由管理
├── providers/            # 全局状态 Provider
├── managers/             # 全局管理器（主题、日志等）
└── main.dart             # 应用入口
```

### 2.2 严格分层 — 职责单一原则（SRP）

**核心原则：一个类只做一件事，修改它的理由应该只有一个。**

#### 分层职责定义

| 层级 | 职责 | 应该做的 | 禁止事项 | 指导行数 |
|------|------|---------|---------|---------|
| **View/UI** (Features) | 渲染 UI，响应用户交互 | 构建 Widget 树、监听 Provider 状态、触发 Provider 方法 | 禁止直接调用 Service、禁止复杂业务逻辑、禁止状态管理细节 | < 300 行 |
| **Provider/State** | 管理 UI 状态，桥接 Service 和 Widget | 管理 AsyncState、调用 Service、notifyListeners() | 禁止写 HTTP 细节、禁止业务规则判断、禁止复杂数据转换 | < 200 行 |
| **Service/Repo** | 封装通用技术能力 | HTTP 请求、本地存储、第三方 SDK 封装 | 禁止业务决策、禁止状态管理、禁止 import Flutter Widget | < 300 行 |
| **Model** | 纯数据载体 | 数据结构定义、JSON 序列化、简单计算属性 | 禁止网络请求、禁止数据库操作、禁止复杂业务判断 | < 100 行 |

#### 判断标准

- **Service**：这个 Service 能否被另一个完全不同的业务复用？
- **Provider**：能否用"更新 XX 状态"一句话描述？
- **Model**：getter 是否只依赖自身字段，不需要外部依赖？
- **Widget**：能否用"显示 XX，用户点 XX 时调用 Provider 的 YY"描述？

#### 红线（新代码必须遵守）

| 规则 | 反例 |
|------|------|
| **Service 不感知 UI** | `SecureStorage` 里弹 Toast |
| **Provider 不写 HTTP 细节** | `BindingProvider` 里写 `options: {'timeout': 5000}` |
| **Model 不做外部依赖查询** | `User` 里查询数据库判断权限 |
| **Widget 不直接调 Service** | `AuthPage` 直接 `ApiClient.post()` |

#### 渐进式重构策略

- **新模块**：严格按规范写
- **老模块**：不主动动刀，满足以下任一条件才重构：
  - 文件 > 500 行且持续增长
  - 多人同时修改频繁冲突
  - 写单元测试时无法 mock 单一职责
  - 同样逻辑在多处复制粘贴

#### Code Review 检查清单

- [ ] 这个类能用一句话描述它的职责吗？
- [ ] 修改这个类的理由是否只有一个？
- [ ] 这个类是否依赖了不应该依赖的分层？（如 Widget → Service）
- [ ] 这个类的代码是否超过 500 行？
- [ ] 这个类能否被其他业务复用？

### 2.3 组件化

- **拒绝巨型文件**：如果一个 UI 文件超过 300 行，必须拆分为更小的私有组件
- **常量集中**：所有颜色、字体、字符串、API 路径必须从 `lib/constants/` 或 `lib/config/` 引用，禁止硬编码

---

## 3. 目录结构

### 3.1 功能模块标准结构

每个功能模块（Feature）的标准结构：

```
features/{module}/
├── {module}_main_screen.dart  # 主容器（如需要底部导航）
├── {module}_home_content.dart # Home 内容页
├── widgets/                # 模块私有组件
│   ├── {widget}_card.dart
│   └── {widget}_button.dart
└── providers/              # 模块状态管理（可选）
    └── {module}_provider.dart
```

### 3.2 核心模块结构

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
│   ├── api_client.dart       # 统一 HTTP 客户端（Dio）
│   └── secure_storage.dart
├── models/                 # 数据模型
│   ├── user.dart
│   └── binding.dart
├── utils/                  # 工具类
│   └── logger.dart
└── router/                 # 路由管理
    └── app_router.dart
```

---

## 🎯 核心场景说明

### 场景 1：手机号绑定（建立长期/短期关系）
- **用途**：建立长期或短期绑定关系的唯一方法
- **场景**：发送者知道对方手机号，远程建立绑定关系
- **流程**：输入对方 11 位手机号 → 选择绑定有效期 → 确认绑定 → 建立关系
- **有效期设置**：
  - **永久绑定**：长期关系（如家庭成员）
  - **有限时间绑定**：自定义有效期（如旅游团导游带团 7 天）
  - 由发送者定义，过期后自动解除绑定
- **特点**：绑定后可随时查看对方位置、发送导航任务

### 场景 2：二维码分享路线（临时分享）
- **用途**：一次性分享路线，**无需绑定关系**
- **场景**：面对面时，发送者生成路线二维码，多人可扫码接受同一路线
- **流程**：发送者规划路线 → 生成二维码 → 多人扫码 → 各自开始导航
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

## 4. 角色架构设计

### 4.1 发送者（子女/年轻人）- 三Tab架构

```
SenderMainScreen (底部导航栏)
├── Tab 0: Home - 路径规划、发送导航
│   └── SenderHomeContent
│       ├── 起点输入
│       ├── 终点输入
│       └── 规划路线按钮
├── Tab 1: 绑定 - 管理绑定关系
│   └── BindingPage (复用 binding/ 模块)
└── Tab 2: 设置 - 应用设置、账号管理
    └── SettingsPage (复用 settings/ 模块)
```

**设计理由**：
- 发送者是主动操作方，功能复杂度高
- 需要管理绑定关系（低频但重要）
- 用户相对年轻，能处理复杂UI

### 4.2 接收者（老人）- 简洁单页架构

```
ReceiverHomePage (单页展示)
├── AppBar
│   ├── [开始导航] 按钮（左上角，避免误触）
│   ├── 设置图标（右上角）
│   ├── 绑定请求通知（如有，红点提示）
│   └── 定位开关按钮
├── 主体内容
│   └── 等待导航提示
└── （无浮动按钮，全部集成到 AppBar）
```

**设计理由**：
- 老人用户防误触设计
- 零学习成本，打开就是核心功能
- 不会因为点错Tab而"丢失"导航界面
- KISS原则（Keep It Simple, Stupid）
- 所有操作按钮集成到 AppBar 上方，避免老人误触

---

## 5. 页面设计规范

### 5.1 线框图遵守

- **必须严格遵守** `docs/archive/WIREFRAMES.md` 中的页面设计
- 页面布局、按钮位置、交互流程必须与线框图一致
- 如需修改，必须先更新线框图文档

### 5.2 颜色规范

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

### 5.3 字体规范

**重要**：项目使用 `AppTextStyles` 统一管理所有文字样式，支持动态字体缩放。

#### 基础字体大小（1.0x 缩放时）

| 元素 | 基础大小 | 对应 AppTextStyles |
|------|---------|-------------------|
| 超大标题 | 40sp | `AppTextStyles.titleLarge` |
| 大标题 | 32sp | `AppTextStyles.titleMedium` |
| 标题 | 24sp | `AppTextStyles.titleSmall` |
| 大正文 | 24sp | `AppTextStyles.bodyLarge` |
| 正文 | 20sp | `AppTextStyles.bodyMedium` |
| 小正文 | 18sp | `AppTextStyles.bodySmall` |
| 按钮文字 | 24sp | `AppTextStyles.button` |
| 小按钮文字 | 18sp | `AppTextStyles.buttonSmall` |
| 辅助文字 | 16sp | `AppTextStyles.caption` |
| 小提示 | 14sp | `AppTextStyles.captionSmall` |

#### 动态缩放机制

用户可以在设置中选择字体大小（0.9x、1.0x、1.2x、1.4x），所有文字会自动按比例缩放。

```dart
// ✅ 正确：使用 AppTextStyles
Text('欢迎', style: AppTextStyles.titleSmall)
Text('说明', style: AppTextStyles.bodyMedium)
Text('提交', style: AppTextStyles.button)

// ❌ 错误：硬编码 fontSize（不会响应字体缩放）
Text('欢迎', style: TextStyle(fontSize: 24))
```

#### 注意事项

1. **禁止硬编码 `fontSize`**：所有文字必须使用 `AppTextStyles.xxx`
2. **支持 `copyWith`**：如需覆盖个别属性（如颜色），使用 `.copyWith()`
   ```dart
   Text('错误', style: AppTextStyles.error.copyWith(color: Colors.red))
   ```
3. **新增样式**：在 `lib/theme/app_text_styles.dart` 中添加新的 getter

### 5.4 间距规范

- 页面内边距：16px
- 卡片间距：12px
- 组件间距：8px
- 按钮内边距：12px

### 5.5 圆角规范

- 卡片圆角：8px
- 按钮圆角：8px
- 输入框圆角：8px
- 对话框圆角：12px

### 5.6 深色/浅色主题

- 所有页面必须同时适配深色和浅色主题
- 使用 `Theme.of(context)` 动态获取颜色
- 禁止硬编码颜色值

### 5.7 页面主题一致性（重要）

- **统一 AppBar 样式**：所有页面的顶部导航栏必须保持一致的高度、背景色和阴影效果
- **统一颜色方案**：所有页面必须使用 `lib/constants/app_colors.dart` 定义的颜色常量，禁止硬编码颜色值
- **统一字体大小**：所有文字使用 `AppTextStyles`，禁止硬编码 `fontSize`。相同类型的文字在所有页面中使用相同的 `AppTextStyles` 样式（会自动响应字体缩放）
- **统一间距规范**：页面边距、卡片间距、组件间距必须统一
- **统一圆角风格**：卡片、按钮、输入框的圆角大小必须保持一致
- **统一深色/浅色适配**：所有页面必须同时适配深色和浅色主题

---

## 6. 组件化规范

### 6.1 组件拆分原则

- 单个 Widget 文件不超过 300 行
- 独立逻辑块必须拆分为私有组件
- 可复用组件应提取到 `lib/widgets/` 目录

### 6.2 组件命名

- 组件类名：大驼峰 + Widget 后缀（`PhoneInputCard`）
- 组件文件名：小写下划线（`phone_input_card.dart`）

### 6.3 组件参数

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

## 7. 状态管理

### 7.1 Provider 模式

使用 Provider 进行全局状态管理：

```dart
class AuthStateManager extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
```

### 7.2 Provider 使用

```dart
// ✅ 正确：使用 Consumer
Consumer<AuthStateManager>(
  builder: (context, authStateManager, child) {
    return Text(authStateManager.state.userId ?? '');
  },
)

// ✅ 直接读取状态
Provider.of<AuthStateManager>(context, listen: false).state
```

### 7.3 Provider 列表

| Provider | 职责 | 位置 |
|----------|------|------|
| `AuthStateManager` | 认证状态和 Token | `lib/state/managers/auth_state_manager.dart` |
| `BindingProvider` | 绑定关系状态和操作 | `lib/providers/binding_provider.dart` |
| `TaskProvider` | 导航任务状态 | `lib/providers/task_provider.dart` |

---

## 8. API 接口规范

### 8.1 CloudBase 官方 API 优先

**核心原则**：能使用 CloudBase 官方 API 实现的功能，绝不自己写后端。

### 8.2 认证 API

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

### 8.3 业务 API

业务相关 API 通过云函数调用：

```dart
// 云函数基础地址
const baseUrl = 'https://$envId.api.tcloudbasegateway.com/v1/functions/qintu-api?webfn=true';

// 绑定关系 API
POST /api/bindings/generate   // 手机号绑定（建立关系）
POST /api/bindings/confirm    // 确认绑定
GET  /api/bindings/my         // 获取我的绑定关系
DELETE /api/bindings/{id}     // 解除绑定

// 导航任务 API
POST /api/tasks               // 创建任务
GET  /api/tasks/my            // 获取我的任务
POST /api/tasks/{id}/accept   // 接受任务
POST /api/tasks/{id}/complete // 完成任务
```

### 8.4 API 响应格式

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

## 9. 日志与隐私

### 9.1 必须添加日志

- 关键路径（登录、绑定、网络请求、状态切换）必须打印日志
- 使用分级日志工具（如 `Logs.app.info()`, `Logs.app.error()`）
- **日志格式**：`[模块名] 操作描述, 关键参数: 值`

```dart
Logs.auth.info('发送验证码, phone: ${maskPhone(phone)}');
Logs.api.info('API请求: POST ${url.toString()}');
```

### 9.2 隐私脱敏（红线）

- **日志脱敏**：绝对禁止在日志中打印完整手机号、密码、Token。必须使用脱敏函数（如 `138****5678`）
- **UI 脱敏**：所有界面展示的敏感信息默认隐藏，支持"点击眼睛图标短暂显示"
- **传输加密**：所有敏感数据传输必须通过 HTTPS

```dart
// ✅ 正确：脱敏处理
Logs.auth.info('登录成功, phone: ${maskPhone(phone)}');

// ❌ 错误：打印完整手机号
Logs.auth.info('登录成功, phone: $phone');
```

---

## 10. 异常处理

### 10.1 不静默失败

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

### 10.2 降级策略

- 网络请求失败时，提供重试机制或引导用户检查网络
- 关键服务（如定位）不可用时，提供明确的引导设置入口

---

## 11. 代码规范

### 11.1 静态分析

- **强制命令**：每次功能开发完成后，提交前必须运行 `flutter analyze` 并通过
- **代码清理**：消除所有 Unused import、Unused variable

### 11.2 命名规范

- **类名**：大驼峰 (`ReceiverHomePage`)
- **变量/方法**：小驼峰 (`fetchUserInfo`)
- **私有成员**：下划线开头 (`_isLoading`)
- **文件命名**：全小写下划线 (`user_repository.dart`)

---

## 12. 测试与发布

### 12.1 开发者自测

- 编码完成后，必须确保代码可以成功编译（无语法错误）
- 使用模拟数据或 Mock 验证业务逻辑闭环

### 12.2 真机验收

- 核心功能（如：定位、导航、扫码、保活）必须在真机上进行验证
- **提交节点**：每当完成一个 CheckList 节点（如阶段一），应生成一个可运行的构建供用户真机测试

---

## 13. CloudBase 后端开发规范

### 13.0 优先使用 CloudBase 官方 API（重要原则）

**核心原则**：能使用 CloudBase 官方 API 实现的功能，绝不自己写后端。

**官方 API 优先的原因**：
- ✅ **官方维护**：由腾讯云开发团队维护，稳定性和安全性有保障
- ✅ **开箱即用**：无需自己实现复杂逻辑（如验证码防刷、Token 管理等）
- ✅ **成本更低**：减少云函数调用次数，降低服务器压力
- ✅ **更安全**：官方提供企业级安全防护（加密、限流、审计等）
- ✅ **易维护**：减少代码量，降低维护成本

**必须使用官方 API 的场景**：
| 功能 | 官方 API | 说明 |
|------|----------|------|
| **手机号验证码登录** | `/auth/v1/verification` | 发送验证码、验证、登录/注册 |
| **微信授权登录** | 官方 Auth 微信登录 | 自动获取 OpenID |
| **邮箱验证码登录** | 官方 Auth Email 登录 | 邮件验证码 |
| **Token 管理** | 官方 Auth Token API | 生成、刷新、验证 Token |
| **匿名登录** | 官方 Auth 匿名登录 | 临时用户身份 |

**适合自己实现云函数的场景**：
| 功能 | 说明 |
|------|------|
| **业务逻辑** | 用户管理、绑定关系、任务管理等 |
| **数据库操作** | MySQL 数据查询、更新、事务处理 |
| **自定义业务** | 导航路线计算、位置共享等 |

### 13.0.1 CloudBase 官方 Auth API 使用经验

**实际踩坑经验**（2026-04-05 验证）：

#### 发送验证码 API

**正确请求体**：
```json
{
  "phone_number": "+86 13800138000"
}
```

**⚠️ 关键注意事项**：
1. **只需 `phone_number` 字段**，不需要其他参数
2. ❌ **不要传 `target` 参数** - 会报错 `invalid value for enum type: "any"`
3. ❌ **不要传 `type` 参数** - 官方 API 不需要此字段
4. ✅ **手机号格式必须为 `"+86 13800138000"`**（带 "+86 " 前缀和空格）

**错误示例**（❌ 会失败）：
```dart
// ❌ 错误：多余的参数会导致 400 错误
body: jsonEncode({
  'phone_number': phoneNumber,
  'target': 'any',              // ❌ 错误：不支持此参数
  'type': 'phoneNumberLogin',   // ❌ 错误：不需要此参数
})
```

**正确示例**（✅ 已验证）：
```dart
// ✅ 正确：只包含必需的 phone_number 字段
body: jsonEncode({
  'phone_number': phoneNumber,  // 格式: "+86 13800138000"
})
```

#### 错误响应处理

官方 API 返回的错误格式：
```json
{
  "code": "INVALID_ARGUMENT",
  "error": "invalid_argument",
  "error_code": 3,
  "error_description": "详细的错误描述",
  "requestId": "xxx"
}
```

**处理建议**：
- 使用 `error['code']` 判断错误类型（如 `"INVALID_ARGUMENT"`）
- 使用 `error['error_description']` 获取详细错误信息
- 不要依赖 `error['error_code']` 数字码，可能不稳定

#### 成功响应格式

发送验证码成功返回：
```json
{
  "verification_id": "xxx",
  "expires_in": 600
}
```

验证验证码成功返回：
```json
{
  "verification_token": "xxx"
}
```

登录/注册成功返回：
```json
{
  "access_token": "xxx",
  "refresh_token": "xxx",
  "expires_in": 7200,
  "refresh_expires_in": 2592000,
  "uid": "xxx"
}
```

### 13.1 CloudBase CLI 部署流程
- **部署命令**：`cloudbase fn code update <函数名> --dir ./functions/<函数名>`
- **配置要求**：必须在 `cloudbaserc.json` 中正确配置函数信息
- **部署后验证**：部署完成后应立即检查云函数日志，确认无启动错误

### 13.2 云函数开发规范
- **Express 框架**：使用 Express 作为 Web 框架，监听 9000 端口
- **数据库操作**：使用 `mysql2/promise` 连接池，所有查询必须通过 `query()` 函数执行
- **认证中间件**：所有需要认证的接口必须使用 `authMiddleware`
- **响应格式**：统一使用 `lib/response.js` 中的辅助函数

### 13.3 数据库表结构管理
- **表名规范**：使用小写下划线（如 `users`, `user_bindings`, `navigation_tasks`）
- **时间字段**：使用 `NOW()` 自动填充，避免手动传入时间戳
- **软删除**：使用状态字段（如 `status = 'revoked'`）代替物理删除

### 13.4 环境配置
- **环境变量**：敏感配置（数据库密码、密钥等）必须通过 CloudBase 环境变量管理，不得硬编码
- **本地调试**：本地开发时设置 `useLocalServer = true`，指向 `localhost:9000`

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

**文档版本**：v2.0.0
**更新日期**：2026-04-05
**维护人员**：开发团队
