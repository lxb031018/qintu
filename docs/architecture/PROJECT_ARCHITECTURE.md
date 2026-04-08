# 项目架构说明

## 📁 功能模块结构

```
lib/features/
├── auth/              # 认证模块（登录/注册）
│   ├── auth_page.dart
│   └── widgets/       # 认证组件（auth_header, auth_button 等）
├── binding/           # 绑定管理模块（独立的绑定关系管理）
│   ├── binding_page.dart          # 主页面 (~230 行)
│   └── widgets/                   # 绑定组件
│       ├── phone_binding_dialog.dart   # 手机号对话框
│       ├── binding_stats_card.dart     # 统计卡片
│       ├── binding_list_view.dart      # 列表视图
│       ├── binding_card.dart           # 绑定卡片
│       ├── add_binding_button.dart     # 添加按钮
│       ├── empty_binding_view.dart     # 空状态
│       └── error_view.dart             # 错误视图
├── receiver/          # 接收者模块（老人端 - 简洁单页）
├── role/              # 角色选择模块
├── sender/            # 发送者模块（子女端 - 三Tab架构）
│   ├── sender_main_screen.dart      # 发送者主容器（底部三Tab导航）
│   ├── sender_home_content.dart     # 发送者Home Tab内容（路径规划）
│   └── widgets/                     # 发送者相关小组件
└── settings/          # 设置模块（主题、账号、退出）
    ├── settings_page.dart
    └── widgets/       # 设置组件（theme_selector, logout_card 等）
```

## 🎯 角色架构设计

### 发送者（子女/年轻人）- 三Tab架构

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

### 接收者（老人）- 简洁单页架构

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

## 🔄 用户流程

```
启动应用
   ↓
检查登录状态
   ↓
未登录 → AuthPage (登录/注册)
   ↓
已登录 → 检查角色
   ↓
未选择角色 → RoleSelectionPage (角色选择)
   ↓
已选择角色
   ├─ receiver → ReceiverHomePage (接收者单页)
   └─ sender → SenderMainScreen (发送者三Tab)
```

## 📝 命名规范

| 文件/类名 | 位置 | 说明 |
|----------|------|------|
| `SenderMainScreen` | `features/sender/` | 发送者主容器（带底部导航） |
| `SenderHomeContent` | `features/sender/` | 发送者Home Tab内容 |
| `ReceiverHomePage` | `features/receiver/` | 接收者主页（单页） |
| `BindingPage` | `features/binding/` | 绑定管理页（独立模块） |
| `SettingsPage` | `features/settings/` | 设置页（独立模块） |

## ✅ 重构完成项

### 架构重构（2026-04-08）
1. ✅ Token 刷新功能完整实现（`TokenRefreshInterceptor`）
2. ✅ 测试覆盖提升到 29 个测试全部通过
3. ✅ `api_client.dart` 从 424 行拆分到 180 行 (-57%)
4. ✅ `ThemeManager` 移除单例，统一使用 Provider
5. ✅ 全局错误边界 `ErrorBoundary` 和 `SafeErrorWidget`
6. ✅ `binding_page.dart` 从 742 行重构到 233 行 (-69%)
7. ✅ 创建 `lib/features/README.md` Feature 模块结构规范
8. ✅ 修复所有硬编码（绑定限制、提示文本等）
9. ✅ 修复 `auth_page.dart` 中的废弃导入

### 早期重构
10. ✅ 删除 `lib/features/home/` 文件夹（包含硬编码的占位页面）
11. ✅ 重构 `lib/features/sender/` 为三Tab架构
12. ✅ 保持 `lib/features/receiver/` 简洁单页架构
13. ✅ 统一使用 `go_router` 导航（已删除 `NavigationService`）
14. ✅ 更新 `main.dart` 和 `app_router.dart` 引用
15. ✅ 清理所有未使用的导入
16. ✅ 修复硬编码字符串（底部导航、主题模式名称）
17. ✅ 修复废弃 API（`dialogBackgroundColor`）
18. ✅ 完整深色模式适配（所有核心页面）
19. ✅ 接收者页面按钮位置调整（避免误触）
20. ✅ 角色切换页面更新修复（清除页面栈）
21. ✅ 主题切换实时生效修复
22. ✅ 退出登录错误修复

## 🔧 待完善项

- [ ] `accessToken` 的获取（目前在 `main.dart` 中标记为 TODO）
- [ ] 发送者 Home Tab 的路线规划 API 集成
- [ ] 发送者选择接收者发送导航的功能
- [ ] 接收者接收并显示导航指引
- [ ] Provider 注入优化（BindingPage 可能需要 Provider 包装）
- [ ] 接收者"开始导航"功能实现

## 🚀 编译检查

```bash
flutter analyze --no-fatal-infos
```

当前状态：✅ **无编译错误**（仅有代码风格提示）
