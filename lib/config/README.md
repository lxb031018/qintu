# Config 目录

环境配置与第三方服务配置中心。

## 目录结构

```
config/
├── environments/              # 多环境配置管理
│   ├── environment_config.dart   # 环境配置抽象接口
│   ├── environment_manager.dart  # 环境管理器（切换/读取当前环境）
│   ├── index.dart                # 环境模块导出入口
│   ├── local_environment.dart    # 本地开发环境
│   ├── cloudbase_test_environment.dart  # CloudBase 测试环境
│   ├── cloudbase_prod_environment.dart  # CloudBase 生产环境
│   └── production_environment.dart      # 通用生产环境
├── amap_config.dart           # 高德地图配置（API Key、隐私合规）
├── auth_config.dart           # 认证配置（Token 策略、过期时间）
├── cloudbase_config.dart      # CloudBase 环境配置（envId、baseUrl、gatewayUrl、publishableKey）
└── ui_config.dart             # UI 全局配置（应用信息、布局常量）
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `environments/environment_config.dart` | 环境配置抽象接口，定义环境配置必须实现的属性 |
| `environments/environment_manager.dart` | 环境管理器，负责切换和读取当前环境（local/test/prod） |
| `environments/index.dart` | 环境模块导出入口，简化导入 |
| `environments/local_environment.dart` | 本地开发环境配置（本地服务器地址等） |
| `environments/cloudbase_test_environment.dart` | CloudBase 测试环境配置 |
| `environments/cloudbase_prod_environment.dart` | CloudBase 生产环境配置 |
| `environments/production_environment.dart` | 通用生产环境配置 |
| `amap_config.dart` | 高德地图 SDK 配置（API Key、隐私合规回调） |
| `auth_config.dart` | 认证相关配置（Token 有效期策略、验证码配置、存储键名） |
| `cloudbase_config.dart` | CloudBase 环境配置（仅保留 `envId`、`baseUrl`、`gatewayUrl`、`publishableKey`） |
| `ui_config.dart` | UI 全局配置（应用信息、布局常量）。注意：部分已迁移至 `constants/` 的属性已标记 `@Deprecated` |

## 架构原则

1. **环境管理唯一入口**：所有服务器地址通过 `EnvironmentManager` 统一管理
2. **CloudBase 解耦**：前端业务逻辑不感知底层是 CloudBase 还是自建服务器
3. **配置职责分离**：
   - `environments/`：不同部署环境的 URL 和调试开关
   - `constants/`：颜色、字符串、圆角、字体等 UI 常量
   - `config/`：第三方服务配置（高德、CloudBase、认证策略）

## 使用方式

```dart
// 获取当前环境基础 URL
final baseUrl = EnvironmentManager.baseUrl;

// 切换环境
await EnvironmentManager.switchEnvironment(EnvironmentType.cloudbaseTest);

// 获取 CloudBase 环境 ID
final envId = CloudBaseConfig.envId;
```
