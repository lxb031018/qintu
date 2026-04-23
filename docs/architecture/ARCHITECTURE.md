# 亲途 (Qintu) 架构文档

> 本文档记录项目架构设计、架构规范和重要决策记录。

---

## 📁 目录结构

### lib/ 目录结构

```
lib/
├── features/                 # 功能模块
│   ├── auth/               # 认证模块（登录）
│   │   ├── auth_page.dart
│   │   └── widgets/
│   ├── map_navigation/     # 地图导航模块（复杂）
│   │   ├── map_navigation_tab.dart
│   │   ├── map_navigation_controller.dart
│   │   ├── widgets/
│   │   │   ├── route_map_widget.dart
│   │   │   ├── location_button.dart
│   │   │   └── location_status_button.dart
│   │   └── route_planning/
│   │       ├── route_planning_controller.dart
│   │       ├── route_planning_provider.dart
│   │       ├── route_planning_service.dart
│   │       ├── route_planning_history_service.dart
│   │       └── widgets/
│   ├── relationship_binding/  # 关系绑定模块（复杂）
│   │   ├── relationship_binding_tab.dart
│   │   ├── binding_controller.dart
│   │   ├── widgets/
│   │   │   ├── binding_stats_card.dart
│   │   │   ├── binding_list_view.dart
│   │   │   ├── binding_card.dart
│   │   │   ├── add_binding_button.dart
│   │   │   ├── empty_binding_view.dart
│   │   │   ├── error_view.dart
│   │   │   ├── notification_badge.dart
│   │   │   └── phone_binding_dialog.dart
│   │   └── binding_notifications/
│   │       ├── binding_notifications_page.dart
│   │       └── widgets/
│   └── settings/            # 设置模块（简单）
│       ├── settings_page.dart
│       ├── environment_switch_page.dart
│       └── widgets/
│           ├── settings_section_card.dart
│           ├── theme_selector_card.dart
│           ├── font_size_selector_card.dart
│           ├── tab_switch_mode_card.dart
│           └── logout_card.dart
├── providers/               # 状态管理
│   ├── auth_state_manager.dart
│   ├── binding_provider.dart
│   ├── theme_manager.dart
│   └── settings_manager.dart
├── models/                  # 数据模型（Freezed）
├── services/                # 服务层
│   ├── api_client.dart
│   ├── auth_service.dart
│   ├── secure_storage.dart
│   └── token_refresh_interceptor.dart
├── constants/               # 常量
│   ├── app_colors.dart
│   ├── app_strings.dart
│   ├── api_endpoints.dart
│   ├── binding_limits.dart
│   └── app_durations.dart
├── config/                  # 配置
│   └── environments/
├── theme/                   # 主题
│   ├── app_theme.dart
│   └── app_text_styles.dart
├── router/                  # 路由
│   └── app_router.dart
├── widgets/                 # 公共组件
│   └── common/
├── utils/                   # 工具类
│   ├── logger.dart
│   ├── phone_utils.dart
│   ├── validators.dart
│   ├── app_snackbar.dart
│   └── theme_utils.dart
└── main.dart
```

---

## 🏛️ 功能模块架构

### 复杂模块（多级结构）

```
map_navigation/           # 地图导航模块
├── map_navigation_tab.dart          # 0级：主页面
├── map_navigation_controller.dart    # 0级：控制器
├── widgets/                          # 0级：公共组件
│   ├── route_map_widget.dart
│   ├── location_button.dart
│   └── location_status_button.dart
└── route_planning/                   # 1级子模块
    ├── route_planning_controller.dart
    ├── route_planning_provider.dart
    ├── route_planning_service.dart
    ├── route_planning_history_service.dart
    └── widgets/
        ├── route_input_card.dart
        ├── route_suggestions_list.dart
        └── quick_action_suggestions_card.dart

relationship_binding/      # 关系绑定模块
├── relationship_binding_tab.dart    # 0级：主页面
├── binding_controller.dart         # 0级：控制器
├── widgets/                         # 0级：公共组件
│   ├── binding_stats_card.dart
│   ├── binding_list_view.dart
│   ├── binding_card.dart
│   ├── add_binding_button.dart
│   ├── empty_binding_view.dart
│   ├── error_view.dart
│   ├── notification_badge.dart
│   └── phone_binding_dialog.dart
└── binding_notifications/           # 1级子模块
    ├── binding_notifications_page.dart
    └── widgets/
        ├── empty_state_widget.dart
        ├── pending_request_card.dart
        ├── received_requests_tab.dart
        ├── rejected_requests_tab.dart
        ├── sent_requests_tab.dart
        └── sent_request_card.dart
```

### 简单模块（页面 + widgets）

```
auth/                     # 认证模块
├── auth_page.dart
└── widgets/
    ├── auth_header.dart
    ├── auth_button.dart
    ├── phone_input_card.dart
    ├── code_input_card.dart
    └── error_card.dart

settings/                 # 设置模块
├── settings_page.dart
├── environment_switch_page.dart
└── widgets/
    ├── settings_section_card.dart
    ├── theme_selector_card.dart
    ├── font_size_selector_card.dart
    ├── tab_switch_mode_card.dart
    └── logout_card.dart
```

### 架构原则

1. **复杂模块**（功能多、需要分离关注点）：
   - 0级：页面 + Controller + widgets
   - 1级子模块：有自己独立的页面、Controller、widgets
   - 组件层级清晰，便于维护和扩展

2. **简单模块**（功能单一、文件少）：
   - 页面 + widgets 目录
   - 不需要 Controller 分离

---

## 🎯 统一主页架构

### 顶部 3 Tab 架构

```
UnifiedHomePage (顶部Tab栏)
├── Tab 0: 路线规划 - 高德地图 + 起点终点输入
│   └── RoutePlanningTab
├── Tab 1: 关系绑定 - 绑定列表 + 通知中心
│   └── RelationshipBindingTab
└── Tab 2: 设置
    └── SettingsPage
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

---

## 🔐 Token 安全管理规范

### 规则：Token 不暴露在 Provider 状态中

**✅ 正确做法**：
```dart
// AuthStateManager.state 只包含非敏感数据
class AuthState {
  final AuthStatus authStatus;
  final String? userId;
  final String? phoneNumber;
  // ❌ 不要包含 accessToken 和 refreshToken
}

// Token 仅存储在 SecureStorage 中
class SecureStorage {
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: accessTokenKey);
  }
}

// ApiClient 拦截器按需读取
class ApiClient {
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }
}
```

**安全原则**：
1. Token 仅存在于 `SecureStorage` 中
2. 页面不需要知道 Token，由拦截器自动处理
3. 路由传参只传 userId、phone 等非敏感数据

---

## 🏗️ 依赖注入规范

### 规则：统一使用 Provider，不引入 GetIt

**✅ 当前方案**：
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => BindingProvider()),
    ChangeNotifierProvider.value(value: _authStateManager),
    ChangeNotifierProvider.value(value: _themeManager),
    ChangeNotifierProvider.value(value: _settingsManager),
  ],
  child: MyApp(),
)
```

**禁止**：
- 重新引入 `get_it` 包
- 创建新的 ServiceLocator
- 通过 `getIt<T>()` 获取服务实例

---

## 📦 HTTP 客户端规范

### 规则：统一使用 ApiClient（Dio），不使用 http

**已删除**：
- `lib/services/api_service.dart`（基于 http）
- `lib/services/api_response.dart`（旧的响应模型）

---

## 🧪 测试编写规范

### 规则：核心状态管理必须有测试覆盖

**必须测试的模块**：
1. `AuthStateManager` - 认证状态管理
2. `BindingProvider` - 绑定关系状态管理
3. 未来新增的 Provider/Manager

---

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

---

## 🎨 主题颜色

**主色调**：珊瑚橙 `#FF8C69`

| 元素 | 浅色模式 | 深色模式 |
|------|---------|---------|
| 主色调 | 珊瑚橙 `#FF8C69` | 珊瑚橙 `#FF8C69` |
| 背景 | 奶油白 `#FFF8F0` | 深蓝灰 `#121212` |
| 卡片 | 纯白 `#FFFFFF` | 深灰 `#242424` |

---

## 📊 技术栈状态

### 已实现

| 功能 | 状态 | 说明 |
|------|------|------|
| Freezed | ✅ 已使用 | `user_state.dart`、`navigation_task.dart`、`async_state.dart` 等 |
| Token 刷新 | ✅ 已实现 | `TokenRefreshInterceptor` 自动处理 401 错误 |
| Provider 状态管理 | ✅ 已使用 | `AuthStateManager`、`BindingProvider`、`ThemeManager`、`SettingsManager` |
| Dio HTTP 客户端 | ✅ 已使用 | 统一的 `ApiClient` |

### 待实现

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 限时绑定 | 中 | 临时绑定（有效期内），不限人数 |
| 二维码分享 | 中 | 无绑定分享路线 |
| 导航功能 | 高 | 完整导航体验 |

---

## 📝 架构变更记录

### 高德地图与定位方案（2026-04-13）

**变更内容**：
- ❌ 删除：`geolocator` 依赖（Flutter 定位插件）
- ❌ 删除：`amap_flutter_map_plus_x`、`amap_flutter_base_plus`（Flutter 地图插件）
- ❌ 删除：`lib/services/location_service.dart`
- ❌ 删除：`lib/utils/coordinate_transform.dart`
- ✅ 新增：高德 Android 原生 SDK（JAR + Native 库）
- ✅ 新增：`AmapMapPlugin.kt`（地图显示 + 定位桥接）
- ✅ 新增：`AmapNavigationPlugin.kt`（导航组件桥接）

**定位实现**：
```
Flutter 端 → MethodChannel → AmapMapPlugin.kt → AMapLocationClient → 高德原生定位
                                                              ↓
                                                   MyLocationStyle 蓝点显示
                                                              ↓
                                        locationListener → 原生箭头蓝点
```

### 统一发送者和接收者端（2026-04-08）

- ✅ 完全统一界面，不再区分角色
- ✅ 统一主界面包含顶部 Tab Bar（路线规划/关系绑定/设置）
- ✅ 删除角色选择机制
- ✅ 绑定关系改为双向对等（A绑定B确认后，两人自动互相绑定）

### 目录结构变更（2026-04-07）

- ❌ 合并 `state/managers/`、`state/providers/`、`state/models/` 到 `providers/` 和 `models/`
- 原因：避免过度拆分，降低认知负担

---

**最后更新**：2026-04-17
