# 亲途架构文档

## 四层架构

Feature 模块遵循 **api → service → provider → widget** 四层分离：

| 层 | 职责 | 禁止 |
|---|------|------|
| api 层 | HTTP/原生 SDK 调用，返回数据模型 | 调用 service |
| service 层 | 业务逻辑，不持有状态 | 继承 ChangeNotifier |
| provider 层 | UI 状态，编排 service | 直接调 api 层 |
| widget 层 | 纯 UI，只读 provider | 含业务逻辑 |

## 目录结构

```
lib/
├── core/http/                 # HTTP 客户端
│   ├── api_client.dart       # 后端 API（单例）
│   └── third_party_api_client.dart  # 第三方 API（单例）
├── features/                  # 功能模块（自包含）
│   └── {module}/
│       ├── core/            # api 层
│       ├── service/         # service 层
│       ├── provider/        # provider 层
│       └── widgets/         # widget 层
├── models/                   # 数据模型（Freezed）
├── providers/                # 全局状态
└── ...
```

## HTTP 客户端

| 类型 | 客户端 | 用途 |
|------|--------|------|
| 后端 API | `ApiClient` | 带 Token 认证 |
| 第三方 API | `ThirdPartyApiClient` | API Key 认证（高德地图等） |

## Provider 管理

- 功能级 Provider 在入口 widget 用 `MultiProvider` 注入
- 不在 main.dart 全局注册

## 主题

- 主色调：珊瑚橙 `#FF8C69`
- 浅色背景：奶油白 `#FFF8F0`
- 深色背景：深蓝灰 `#121212`

## 用户流程

```
启动 → AuthPage（未登录）→ UnifiedHomePage（已登录）
                                 ↓
                    顶部 3 Tab：路线规划 / 关系绑定 / 设置
```

## UI 规范

- 页面内边距：16px
- 卡片间距：12px
- 组件间距：8px
- 圆角：8-12px
