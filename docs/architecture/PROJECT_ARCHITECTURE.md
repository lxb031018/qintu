# 项目架构说明

## 📁 功能模块结构

```
lib/features/
├── auth/              # 认证模块（登录/注册）
├── binding/           # 绑定管理模块（独立的绑定关系管理）
├── receiver/          # 接收者模块（老人端 - 简洁单页）
├── role/              # 角色选择模块
├── sender/            # 发送者模块（子女端 - 三Tab架构）
│   ├── sender_main_screen.dart      # 发送者主容器（底部三Tab导航）
│   ├── sender_home_content.dart     # 发送者Home Tab内容（路径规划）
│   └── widgets/                     # 发送者相关小组件
└── settings/          # 设置模块（主题、账号、退出）
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

1. ✅ 删除 `lib/features/home/` 文件夹（包含硬编码的占位页面）
2. ✅ 重构 `lib/features/sender/` 为三Tab架构
3. ✅ 保持 `lib/features/receiver/` 简洁单页架构
4. ✅ 更新 `NavigationService` 导航逻辑
5. ✅ 更新 `main.dart` 和 `app_router.dart` 引用
6. ✅ 清理所有未使用的导入
7. ✅ 修复硬编码字符串（底部导航、主题模式名称）
8. ✅ 修复废弃 API（`dialogBackgroundColor`）
9. ✅ 完整深色模式适配（所有核心页面）
10. ✅ 接收者页面按钮位置调整（避免误触）
11. ✅ 角色切换页面更新修复（清除页面栈）
12. ✅ 主题切换实时生效修复
13. ✅ 退出登录错误修复

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
