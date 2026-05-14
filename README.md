# 亲途 (Qintu)

一款帮助不便使用传统导航软件的人群轻松使用导航功能的 Flutter 应用。

[![Powered by CloudBase](https://7463-tcb-advanced-a656fc-1257967285.tcb.qcloud.la/mcp/powered-by-cloudbase-badge.svg)](https://github.com/TencentCloudBase/CloudBase-AI-ToolKit)

> 本项目基于 [**CloudBase AI ToolKit**](https://github.com/TencentCloudBase/CloudBase-AI-ToolKit) 开发，通过AI提示词和 MCP 协议+云开发，让开发更智能、更高效，支持AI生成全栈代码、一键部署至腾讯云开发（免服务器）、智能日志修复。

## 功能特性

- **路线规划**：支持驾车、步行、骑行、公交（Bus + 地铁）四种出行方式
- **实时导航**：基于高德地图 SDK 的 turn-by-turn 语音导航
- **位置分享**：将路线分享给绑定者，接收方可直接导航
- **关系绑定**：双向对等绑定，确认后双方自动互相绑定
- **统一界面**：不区分"发送者"和"接收者"角色

## 技术栈

| 类别 | 技术 |
|------|------|
| 前端 | Flutter + Riverpod + GoRouter |
| 网络 | Dio |
| 后端 | Node.js + Express + MySQL |
| 云平台 | CloudBase |
| 地图 | 高德 Android SDK |

## 项目结构

```
qintu/
├── lib/                         # Flutter 代码
│   ├── features/                # 功能模块
│   │   ├── map_navigation/     # 地图导航
│   │   ├── relationship_binding/ # 关系绑定
│   │   ├── auth/               # 认证
│   │   ├── settings/           # 设置
│   │   └── app_shell/          # 应用外壳
│   ├── core/                    # 核心模块
│   │   ├── http/               # HTTP 客户端
│   │   ├── constants/          # 常量
│   │   └── utils/              # 工具类
│   ├── models/                  # 数据模型
│   ├── providers/               # 全局状态管理
│   └── main.dart               # 应用入口
├── functions/qintu-api/        # 云函数（后端 API）
├── database/                     # 数据库脚本
├── android/                      # Android 原生代码
└── docs/                        # 开发文档
```

### 功能模块

| 模块 | 说明 |
|------|------|
| `map_navigation` | 地图导航核心功能 |
| `relationship_binding` | 绑定关系管理 |
| `auth` | 用户登录注册 |
| `settings` | 应用设置 |

## 快速开始

### 环境要求

- Flutter 3.x
- Android Studio / VS Code
- Android SDK

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
flutter run
```

### 构建 APK

```bash
flutter build apk --debug
```

## 开发文档

| 文档 | 说明 |
|------|------|
| [CLAUDE.md](CLAUDE.md) | 开发规则（每次对话自动加载） |
| [docs/CHECKLIST.md](docs/CHECKLIST.md) | 上线前检查 |
| [docs/guides/API_CONTRACT.md](docs/guides/API_CONTRACT.md) | 接口规范 |
| [docs/guides/AMAP_GUIDE.md](docs/guides/AMAP_GUIDE.md) | 高德地图集成 |
| [docs/architecture/](docs/architecture/) | 架构文档 |
| [docs/features/map_navigation/](docs/features/map_navigation/) | 地图导航功能文档 |
| [docs/operations/DEPLOY_GUIDE.md](docs/operations/DEPLOY_GUIDE.md) | 部署指南 |

## 设计理念

- **统一界面**：不区分"发送者"和"接收者"角色
- **顶部 Tab 架构**：路线规划 / 关系绑定 / 设置
- **双向对等绑定**：确认后双方自动互相绑定
- **四层分离架构**（Flutter 侧）：
  - `api` 层：HTTP/原生 SDK 调用
  - `service` 层：业务逻辑
  - `provider` 层：UI 状态
  - `widget` 层：UI 组件