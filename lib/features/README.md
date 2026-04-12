# Features 目录

按功能划分的页面和专属组件，采用 **Feature-First** 架构。

## 目录结构

```
features/
├── auth/                    # 认证模块
│   ├── auth_page.dart                      # 登录/注册页面入口
│   └── widgets/
│       ├── auth_button.dart                # 认证按钮组件
│       ├── auth_header.dart                # 认证页头部（Logo/标题）
│       ├── code_input_card.dart            # 验证码输入卡片
│       ├── error_card.dart                 # 错误提示卡片
│       └── phone_input_card.dart           # 手机号输入卡片
├── binding/                 # 绑定系统
│   ├── binding_page.dart                   # 绑定关系主页面
│   ├── binding_controller.dart             # 绑定页面的业务逻辑控制器
│   ├── widgets/                            # 绑定关系子组件
│   │   ├── add_binding_button.dart         # 添加绑定的按钮/入口
│   │   ├── binding_card.dart               # 单个绑定关系卡片
│   │   ├── binding_list_view.dart          # 绑定关系列表视图
│   │   ├── binding_stats_card.dart         # 绑定统计卡片
│   │   ├── empty_binding_view.dart         # 空绑定状态页面
│   │   ├── error_view.dart                 # 错误状态视图
│   │   ├── notification_badge.dart         # 通知徽章（显示未读数量）
│   │   └── phone_binding_dialog.dart       # 手机号绑定对话框
│   └── requests/                           # 绑定请求（通知中心）
│       ├── notification_center_page.dart   # 通知中心页面（3个Tab）
│       └── widgets/
│           ├── empty_state_widget.dart     # 通用空状态组件
│           ├── pending_request_card.dart   # 待处理请求卡片（接受/拒绝）
│           ├── received_requests_tab.dart  # 收到的请求 Tab
│           ├── rejected_requests_tab.dart  # 已拒绝请求 Tab
│           ├── sent_request_card.dart      # 已发送请求卡片
│           └── sent_requests_tab.dart      # 已发送请求 Tab
├── common/                  # 通用功能
│   └── splash_screen.dart                  # 应用启动闪屏/加载页
├── receiver/                # 接收者端
│   ├── receiver_home_page.dart             # 接收者首页
│   └── widgets/
│       ├── receiver_location_info_card.dart  # 位置信息卡片
│       ├── receiver_location_toggle.dart     # 位置共享开关
│       └── receiver_map_widget.dart          # 地图组件（显示发送者位置）
├── role/                    # 角色选择
│   └── role_selection_page.dart            # 角色选择页面（Sender/Receiver）
├── sender/                  # 发送者端
│   ├── sender_main_screen.dart             # 发送者主屏幕
│   └── sender_home_page.dart               # 发送者首页
└── settings/                # 设置
    ├── settings_page.dart                  # 设置页面入口
    ├── environment_switch_page.dart        # 环境切换页面（dev/test/prod）
    └── widgets/
        ├── font_size_selector_card.dart    # 字体大小选择卡片
        ├── logout_card.dart                # 退出登录卡片
        ├── role_switch_card.dart           # 角色切换卡片
        ├── settings_section_card.dart      # 设置分组卡片
        └── theme_selector_card.dart        # 主题选择卡片（亮色/暗色）
```

## 模块说明

### auth/ - 认证模块
| 文件 | 作用 |
|------|------|
| `auth_page.dart` | 登录/注册页面入口 |
| `widgets/auth_button.dart` | 认证按钮组件 |
| `widgets/auth_header.dart` | 认证页头部（Logo/标题） |
| `widgets/code_input_card.dart` | 验证码输入卡片 |
| `widgets/error_card.dart` | 错误提示卡片 |
| `widgets/phone_input_card.dart` | 手机号输入卡片 |

### binding/ - 绑定系统
| 文件 | 作用 |
|------|------|
| `binding_page.dart` | 绑定关系主页面 |
| `binding_controller.dart` | 绑定页面的业务逻辑控制器 |
| **widgets/** | **绑定关系子组件** |
| `widgets/add_binding_button.dart` | 添加绑定的按钮/入口 |
| `widgets/binding_card.dart` | 单个绑定关系卡片 |
| `widgets/binding_list_view.dart` | 绑定关系列表视图 |
| `widgets/binding_stats_card.dart` | 绑定统计卡片 |
| `widgets/empty_binding_view.dart` | 空绑定状态页面 |
| `widgets/error_view.dart` | 错误状态视图 |
| `widgets/notification_badge.dart` | 通知徽章（显示未读数量） |
| `widgets/phone_binding_dialog.dart` | 手机号绑定对话框 |
| **requests/** | **绑定请求（通知中心）** |
| `requests/notification_center_page.dart` | 通知中心页面（3个Tab） |
| `requests/widgets/empty_state_widget.dart` | 通用空状态组件 |
| `requests/widgets/pending_request_card.dart` | 待处理请求卡片（接受/拒绝） |
| `requests/widgets/received_requests_tab.dart` | 收到的请求 Tab |
| `requests/widgets/rejected_requests_tab.dart` | 已拒绝请求 Tab |
| `requests/widgets/sent_request_card.dart` | 已发送请求卡片 |
| `requests/widgets/sent_requests_tab.dart` | 已发送请求 Tab |

### common/ - 通用功能
| 文件 | 作用 |
|------|------|
| `splash_screen.dart` | 应用启动闪屏/加载页 |

### receiver/ - 接收者端
| 文件 | 作用 |
|------|------|
| `receiver_home_page.dart` | 接收者首页 |
| `widgets/receiver_location_info_card.dart` | 位置信息卡片 |
| `widgets/receiver_location_toggle.dart` | 位置共享开关 |
| `widgets/receiver_map_widget.dart` | 地图组件（显示发送者位置） |

### role/ - 角色选择
| 文件 | 作用 |
|------|------|
| `role_selection_page.dart` | 角色选择页面（Sender/Receiver） |

### sender/ - 发送者端
| 文件 | 作用 |
|------|------|
| `sender_main_screen.dart` | 发送者主屏幕 |
| `sender_home_page.dart` | 发送者首页 |

### settings/ - 设置
| 文件 | 作用 |
|------|------|
| `settings_page.dart` | 设置页面入口 |
| `environment_switch_page.dart` | 环境切换页面（dev/test/prod） |
| `widgets/font_size_selector_card.dart` | 字体大小选择卡片 |
| `widgets/logout_card.dart` | 退出登录卡片 |
| `widgets/role_switch_card.dart` | 角色切换卡片 |
| `widgets/settings_section_card.dart` | 设置分组卡片 |
| `widgets/theme_selector_card.dart` | 主题选择卡片（亮色/暗色） |

## 架构原则

1. **Feature-First**：每个功能模块包含页面和专属 widgets/
2. **组件内聚**：专属组件放在模块内的 widgets/ 目录
3. **通用组件**：跨模块复用的组件放在 `lib/widgets/`
4. **职责单一**：每个组件只负责一个 UI 片段
5. **状态外置**：组件通过参数接收数据，不直接读取 Provider
