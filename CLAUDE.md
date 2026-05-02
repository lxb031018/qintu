# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# 项目规则

> 每次对话自动加载，AI 必须遵守以下规则。

## 常用命令

```bash
# 运行应用
flutter run

# 代码分析
flutter analyze

# 运行测试
flutter test

# 构建 APK
flutter build apk --debug

# 运行单文件测试
flutter test test/path/to/file_test.dart
```

## 架构（四层分离）

Feature 模块：api → service → provider → widget

| 层 | 职责 | 禁止 |
|---|------|------|
| api 层 | HTTP/原生 SDK 调用，返回数据模型 | 调用 service |
| service 层 | 业务逻辑，不持有状态 | 继承 ChangeNotifier |
| provider 层 | UI 状态，编排 service | 直接调 api 层 |
| widget 层 | 纯 UI，只读 provider | 含业务逻辑 |

**Provider 直接调 api 是违规**（必须过 service 层）

## HTTP 客户端

- 后端 API：`ApiClient`（`lib/core/http/api_client.dart`）
- 第三方 SDK：通过 Platform Channel 调用 Android 原生 SDK，桥接层在 `lib/features/*/core/*_bridge.dart`
- 禁止：硬编码 URL、创建独立 Dio 实例

## Provider 管理

- 在 feature 入口 widget 用 MultiProvider 注入
- 禁止：main.dart 全局注册功能级 provider

## 环境与配置

- 环境切换：`EnvironmentManager`（`config/environments/`）
- API 端点：`constants/api_endpoints.dart`
- 禁止：代码中硬编码 `http://` 或 `https://`

## Android 原生集成

### 三层架构

Android 原生代码位于 `android/app/src/main/kotlin/me/lxb/qintu/`，采用**三层架构**：

| 层 | 职责 | 示例文件 |
|---|---|---|
| Plugin 层 | 实现 `FlutterPlugin`，暴露 MethodChannel/EventChannel 与 Flutter 通信 | `AmapMapPlugin.kt`、`AmapNavigationPlugin.kt` |
| Activity 层 | 原生页面（持有 UI），处理用户交互和生命周期 | `NavigationActivity.kt` |
| 功能模块层 | 封装高德 SDK 能力（定位、地图、导航、地理编码等） | `LocationClientImpl.kt`、`RouteRenderer.kt` |

**Plugin 层是 Flutter 与原生通信的桥接点**，禁止在 Plugin 层编写业务逻辑。

### 集成规则

- 定位/地图：高德 Android SDK（原生集成，非 Flutter 插件）
- 插件注册：`MainActivity.configureFlutterEngine()`
- Platform Channel 名称：在 `lib/core/constants/` 集中定义常量，Dart/Kotlin 两边共享
- 禁止：业务代码直接调用 Platform Channel

## Git 工作流

- 每完成一个完整事件 add + commit
- commit 信息描述做的事，不描述改了哪些文件

## 架构合规性检查

**每次修改功能或增加新功能后，必须检查架构合规性：**

### Flutter 侧

1. **四层分离**：
   - widget 层：纯 UI 展示，禁止业务逻辑
   - provider 层：状态管理，数据组装
   - service 层：业务逻辑处理
   - api 层：接口定义，网络请求
   各层单向依赖：widget → provider → service → api，是否每层职责正确
2. **禁止逆向调用**：provider 不能直接调 api 层，必须过 service 层
3. **禁止在 ui 层写业务逻辑**
4. **使用统一 HTTP 客户端**：后端用 `ApiClient`；第三方 SDK 通过原生 Platform Channel 调用
5. **清理死代码**：删除不再使用的文件、函数、import
6. **更新目录/函数名**：使用清晰、合适的命名

### Android 原生侧

1. **三层分离**：Activity 层管理 Plugin 层，Plugin 层调用功能模块层，是否每层职责正确
2. **Plugin 层禁止业务逻辑**：Plugin 只负责 Flutter 通信，不编写业务代码
3. **Platform Channel 名称一致**：Dart 和 Kotlin 两边使用同一常量定义

## 文档导航

### 高频（每次开发都可能用到）

| 场景 | 文档 |
|------|------|
| 开发规则 | CLAUDE.md（本文档） |
| 架构规范 | docs/architecture/ARCHITECTURE.md |
| 接口规范 | docs/guides/API_CONTRACT.md |
| 工具使用 | docs/guides/UTILS_USAGE.md |
| 高德官方文档 | docs/amap/ |

### 中频（特定场景需要）

| 场景 | 文档 |
|------|------|
| 高德地图集成 | docs/guides/AMAP_GUIDE.md |
| 本地服务器测试 | docs/LOCAL_SERVER_SETUP.md |
| 多环境配置 | docs/MULTI_ENV_SETUP.md |
| 认证配置 | docs/guides/AUTH_CONFIG.md |
| 绑定限制 | docs/guides/BINDING_LIMITS.md |

### 低频（调试/特殊场景）

| 场景 | 文档 |
|------|------|
| 测试环境 | docs/testing/TEST_ENV_SETUP.md |
| 绑定功能测试 | docs/testing/BINDING_TEST_GUIDE.md |
| 测试指南 | docs/testing/TEST_GUIDE.md |
| 云函数部署 | docs/guides/flutter-call-cloud-function.md |
| 云函数问题排查 | docs/CLOUDBASE_FUNCTION_TROUBLESHOOTING.md |
| 部署上线 | docs/operations/DEPLOY_GUIDE.md |
| MCP 工具技巧 | docs/MCP_TIPS.md |
| 项目简介 | docs/README_PROJECT.md |
| 上线前检查 | docs/CHECKLIST.md |

### 示例代码

| 场景 | 路径 |
|------|------|
| 高德地图示例 | examples/amap/ |
| TTS 语音示例 | examples/tts/flutter_tts_example |
| 高德 Android SDK | AmapSDK/ |
