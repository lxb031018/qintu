# Feature 模块结构规范

## 📁 当前采用的目录结构

每个 feature 模块采用**扁平结构**，按功能规模自然分层：

```
features/
└── auth/                           # Feature 名称
    ├── auth_page.dart              # 页面入口
    └── widgets/                    # 页面专属组件
        ├── auth_header.dart
        ├── code_input_widget.dart
        └── ...
```

## 🎯 各部分职责

### 页面文件 (`*_page.dart`)
- **职责**: 页面入口，组织页面布局
- **规则**:
  - 保持简洁，UI 逻辑复杂时拆到 widgets/
  - 业务逻辑放在全局 Provider（AuthStateManager、BindingProvider 等）
  - 通过 `Provider.of<T>(context)` 获取状态和调用方法

### 专属组件 (`widgets/`)
- **职责**: 页面内的可复用 UI 组件
- **规则**:
  - 不包含跨 feature 的通用组件（那些放 `lib/widgets/common/`）
  - 不做 API 调用，通过回调让页面处理
  - 只关注 UI 状态展示

## 📋 实际项目结构

```
lib/features/
├── auth/                    # 认证功能
│   ├── auth_page.dart
│   └── widgets/
├── binding/                 # 绑定关系管理
│   ├── binding_page.dart
│   └── widgets/
├── common/                  # 通用功能（启动页等）
│   └── splash_screen.dart
├── receiver/                # 接收者端
│   ├── receiver_home_page.dart
│   └── widgets/
├── sender/                  # 发送者端
│   ├── sender_main_screen.dart
│   ├── sender_home_content.dart
│   └── widgets/
├── role/                    # 角色选择
│   └── role_selection_page.dart
├── settings/                # 设置
│   ├── settings_page.dart
│   └── widgets/
└── dev/                     # 开发调试（留空备用）
```

## 📊 什么时候拆分层级？

### 保持扁平结构（当前）
- 页面数量 ≤ 3 个
- 业务逻辑不复杂
- 直接用全局 Provider 管理状态

### 考虑拆分 provider/ 层
- 某个 feature 有独立的复杂业务逻辑（如任务管理、消息系统）
- 需要独立的状态管理，不适合放在全局 Provider
- 需要单独测试该 feature 的业务逻辑

### 考虑拆分 data/ 层
- 某个 feature 有专属的数据源（独立的 Repository、本地缓存）
- API 调用逻辑复杂，需要单独封装

> **原则：避免过度工程，功能复杂后再拆分。**

## 🔄 数据流向（当前架构）

```
用户交互 (feature page)
    ↓
调用全局 Provider 方法 (AuthStateManager / BindingProvider)
    ↓
调用 ApiClient (services/api_client.dart)
    ↓
API 调用
    ↓
Provider 处理业务逻辑
    ↓
notifyListeners()
    ↓
UI 更新
```

## ✅ 优势

1. **简洁直接**: 小项目不需要复杂分层
2. **代码位置可预测**: 页面文件直接在 feature 根目录
3. **易于维护**: 文件少，一目了然
4. **渐进式演进**: 功能变复杂时再拆分，不提前优化

## ⚠️ 注意事项

- **不要为了规范而规范**: 1 个页面的功能不需要创建 provider/ 和 data/
- **保持一致性**: 同类型文件放在相同位置
- **跨功能组件放全局**: 通用组件放 `lib/widgets/common/`，不要复制到各 feature

## 📝 示例: 添加新功能

假设要添加"消息中心"功能:

1. **简单情况**（只有列表页）:
   - 创建 `features/message/message_page.dart`
   - 页面内嵌 UI，业务逻辑用全局 Provider

2. **复杂情况**（独立业务逻辑）:
   - 创建 `features/message/` + `message_page.dart`
   - 添加 `providers/message_provider.dart` 管理消息状态
   - 数据层直接调用 `ApiClient`，不需要额外 Repository

## 📚 参考

- [Flutter 架构最佳实践](https://docs.flutter.dev/get-started/flutter-for/android-devs#how-do-i-handle-state)
- [Provider 包文档](https://pub.dev/packages/provider)