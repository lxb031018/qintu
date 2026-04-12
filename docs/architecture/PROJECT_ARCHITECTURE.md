# 项目架构说明

## 📁 功能模块结构

```
lib/features/
├── auth/                          # 认证模块（登录/注册）
│   ├── auth_page.dart             # 登录/注册页面
│   └── widgets/                   # 认证组件
│       ├── auth_button.dart       # 认证按钮
│       ├── auth_header.dart       # 页面头部（Logo + 欢迎语）
│       ├── code_input_card.dart   # 验证码输入卡片
│       ├── error_card.dart        # 错误提示卡片
│       └── phone_input_card.dart  # 手机号输入卡片
├── binding/                       # 绑定关系模块
│   ├── binding_page.dart          # 绑定管理主页面
│   ├── binding_controller.dart    # 绑定业务逻辑控制器
│   ├── requests/                  # 请求管理子模块
│   │   ├── notification_center_page.dart  # 通知中心页面（3个Tab）
│   │   └── widgets/
│   │       ├── empty_state_widget.dart    # 空状态组件
│   │       ├── pending_request_card.dart  # 待确认请求卡片
│   │       ├── received_requests_tab.dart # 收到请求Tab
│   │       ├── rejected_requests_tab.dart # 被拒绝请求Tab
│   │       └── sent_requests_tab.dart     # 发出请求Tab
│   └── widgets/
│       ├── add_binding_button.dart        # 添加绑定按钮
│       ├── binding_card.dart              # 绑定关系卡片
│       ├── binding_list_view.dart         # 绑定列表视图
│       ├── binding_stats_card.dart        # 绑定统计卡片
│       ├── empty_binding_view.dart        # 空绑定状态
│       ├── error_view.dart                # 错误视图
│       ├── notification_badge.dart        # 通知角标
│       ├── phone_binding_dialog.dart      # 手机号绑定对话框
│       └── sent_request_card.dart         # 已发出请求卡片
├── common/                        # 通用模块
│   └── splash_screen.dart         # 启动页
├── home/                          # 主页模块
│   ├── unified_home_page.dart     # 统一主页（顶部Tab架构）
│   └── tabs/
│       ├── route_planning_tab.dart        # 路线规划Tab
│       └── widgets/
│           └── route_map_widget.dart      # 地图组件
└── settings/                      # 设置模块
    ├── settings_page.dart         # 设置页面
    ├── environment_switch_page.dart  # 环境切换页面
    └── widgets/
        ├── font_size_selector_card.dart   # 字体大小选择器
        ├── logout_card.dart               # 退出登录卡片
        ├── settings_section_card.dart     # 设置区域卡片
        ├── tab_switch_mode_card.dart      # Tab切换模式卡片
        └── theme_selector_card.dart       # 主题选择器
```

## 🎯 统一主页架构

### 顶部 3 Tab 架构

```
UnifiedHomePage (顶部Tab栏)
├── Tab 0: 路线规划 - 高德地图 + 起点终点输入
│   └── RoutePlanningTab
│       └── RouteMapWidget (地图组件)
├── Tab 1: 关系绑定 - 绑定列表 + 通知中心
│   └── BindingPage
│       └── 通知中心入口 (角标提示)
└── Tab 2: 设置 - 应用设置、账号管理
    └── SettingsPage
        ├── 主题选择器
        ├── 字体大小选择器
        ├── Tab切换模式切换
        └── 退出登录
```

**设计理由**：
- 所有人使用同一套界面，不再区分"发送者"和"接收者"
- 顶部 Tab 防止老人误触（双击切换）
- 会用的年轻人自然使用所有功能
- 不会用的老人不接触看不懂的按钮

### 双击切换 Tab 机制

| 模式 | 单击行为 | 双击行为 | 适用场景 |
|------|---------|---------|---------|
| **双击模式** (默认) | 显示提示"💡 双击顶部标签切换页面" | 切换到对应 Tab | 防止老人误触 |
| **单击模式** | 直接切换 Tab | 无操作 | 年轻人使用 |

**设置路径**: 设置页 → Tab 双击模式

## 🔄 用户流程

```
启动应用
   ↓
AuthStateManager.initialize() 检查登录状态
   ↓
未登录 → AuthPage (登录/注册)
   ↓
已登录 → UnifiedHomePage (统一主页)
   ↓
顶部 3 Tab 自由选择
```

## 📝 命名规范

| 文件/类名 | 位置 | 说明 |
|----------|------|------|
| `UnifiedHomePage` | `features/home/` | 统一主页（顶部Tab） |
| `RoutePlanningTab` | `features/home/tabs/` | 路线规划Tab |
| `BindingPage` | `features/binding/` | 绑定管理页 |
| `NotificationCenterPage` | `features/binding/requests/` | 通知中心（3个Tab） |
| `SettingsPage` | `features/settings/` | 设置页 |

## ✅ 架构决策

### 统一发送者和接收者端

**决策日期**: 2026-04-08

- ✅ 完全统一界面，不再区分角色
- ✅ 统一主界面包含顶部 Tab Bar（路线规划/关系绑定/设置）
- ✅ 删除角色选择机制
- ✅ 绑定关系改为双向对等（A绑定B确认后，两人自动互相绑定）

### 主题颜色

**主色调**: 珊瑚橙 `#FF8C69`

| 元素 | 浅色模式 | 深色模式 |
|------|---------|---------|
| 主色调 | 珊瑚橙 `#FF8C69` | 珊瑚橙 `#FF8C69` |
| 背景 | 奶油白 `#FFF8F0` | 深蓝灰 `#121212` |
| 卡片 | 纯白 `#FFFFFF` | 深灰 `#242424` |

### 认证状态持久化

- Token 仅存储在 `SecureStorage` 中
- `AuthStateManager` 为唯一认证源
- Refresh Token 有效期 10 年（一次登录，永久保持）
- 自动刷新：`TokenRefreshInterceptor` 处理 401 错误

## 📊 编译检查

```bash
flutter analyze --no-fatal-infos
```

当前状态：✅ **无编译错误**
