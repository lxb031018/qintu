# 项目规则

> 每次对话自动加载，AI 必须遵守以下规则。

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
- 第三方 API：`ThirdPartyApiClient`（`lib/core/http/third_party_api_client.dart`）
- 禁止：硬编码 URL、创建独立 Dio 实例

## Provider 管理

- 在 feature 入口 widget 用 MultiProvider 注入
- 禁止：main.dart 全局注册功能级 provider

## 环境与配置

- 环境切换：`EnvironmentManager`（`config/environments/`）
- API 端点：`constants/api_endpoints.dart`
- 禁止：代码中硬编码 `http://` 或 `https://`

## Android 原生集成

- 定位/地图：高德 Android SDK（原生集成，非 Flutter 插件）
- 插件注册：`MainActivity.configureFlutterEngine()`
- 禁止：业务代码直接调用 Platform Channel

## Git 工作流

- 每完成一个完整事件 add + commit
- commit 信息描述做的事，不描述改了哪些文件

## 文档导航

| 场景 | 文档 |
|------|------|
| 接口规范 | docs/guides/API_CONTRACT.md |
| 部署上线 | docs/operations/DEPLOY_GUIDE.md |
| 高德地图 | docs/guides/AMAP_GUIDE.md |
| 上线前检查 | docs/CHECKLIST.md |
| 云函数部署 | docs/guides/flutter-call-cloud-function.md |
