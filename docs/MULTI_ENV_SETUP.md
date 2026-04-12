# 多环境配置架构指南

> 本文档介绍亲途 App 的多环境配置系统，方便开发、测试和上线切换。

---

## 📁 目录结构

```
lib/config/environments/
├── environment_config.dart           # 环境配置接口定义
├── local_environment.dart            # 本地开发环境配置
├── cloudbase_test_environment.dart   # CloudBase 测试环境配置
├── cloudbase_prod_environment.dart   # CloudBase 生产环境配置
├── production_environment.dart       # 正式生产环境配置
├── environment_manager.dart          # 环境管理器（核心）
└── index.dart                        # 统一导出
```

---

## 🎯 环境类型

| 环境 | 枚举值 | 适用场景 | 特点 |
|------|--------|---------|------|
| **本地开发** | `EnvironmentType.local` | 开发调试、双设备测试 | 零成本、快速、局域网 |
| **CloudBase 测试** | `EnvironmentType.cloudbaseTest` | 内部测试、演示 | 数据持久、消耗额度 |
| **CloudBase 生产** | `EnvironmentType.cloudbaseProd` | 上线前最终测试 | 正式路径、严格控制 |
| **生产环境** | `EnvironmentType.production` | 正式上线 | 完全自主、可扩展 |

---

## 🚀 快速开始

### 方式 1：代码中切换（推荐）

编辑 `lib/utils/constants.dart`：

```dart
class Constants {
  // 修改这一行即可切换环境
  static const AppEnv currentEnv = AppEnv.local;  // 本地开发
  // static const AppEnv currentEnv = AppEnv.cloudbaseTest;  // CloudBase 测试
  // static const AppEnv currentEnv = AppEnv.production;  // 生产环境
}
```

### 方式 2：使用环境管理器

```dart
import 'package:qintu/config/environments/index.dart';

void main() {
  // 切换环境
  EnvironmentManager.switchEnvironment(EnvironmentType.local);
  
  // 查看当前环境
  EnvironmentManager.printEnvironmentInfo();
  
  runApp(const MyApp());
}
```

### 方式 3：App 内切换（开发阶段）

在 App 设置页面添加"环境切换"入口：

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EnvironmentSwitchPage(),
  ),
);
```

---

## 📝 使用示例

### 1. 获取 API 基础 URL

```dart
import 'package:qintu/config/environments/index.dart';

// 方式 1：通过 EnvironmentManager
final baseUrl = EnvironmentManager.baseUrl;

// 方式 2：通过 Constants（兼容老代码）
final baseUrl = Constants.baseUrl;
```

### 2. 根据环境执行不同逻辑

```dart
if (EnvironmentManager.isLocal) {
  // 本地开发：显示详细日志
  Logs.debug('请求详情: ...');
}

if (EnvironmentManager.isProduction) {
  // 生产环境：上报错误到监控
  Sentry.captureException(error);
}
```

### 3. 配置 HTTP 客户端

```dart
class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvironmentManager.baseUrl,
      connectTimeout: Duration(seconds: EnvironmentManager.current.connectTimeout),
      receiveTimeout: Duration(seconds: EnvironmentManager.current.receiveTimeout),
    ));
    
    // 根据环境决定是否启用日志
    if (EnvironmentManager.current.enableNetworkLogs) {
      _dio.interceptors.add(LogInterceptor());
    }
  }
}
```

---

## 🔧 修改环境配置

### 修改本地开发 IP

当电脑 IP 变化时，编辑 `lib/config/environments/local_environment.dart`：

```dart
const LocalEnvironment(
  localIp: '192.168.1.100',  // 修改为你的新 IP
  port: 9000,
);
```

或直接在 `lib/utils/constants.dart` 修改：

```dart
static const String _localBaseUrl = 'http://192.168.1.100:9000';
```

### 修改 CloudBase 环境

编辑 `lib/config/environments/cloudbase_test_environment.dart`：

```dart
const CloudBaseTestEnvironment(
  envId: 'your-env-id',       // 修改环境 ID
  gatewayPath: 'qintu-api',   // 修改网关路径
);
```

### 修改生产服务器地址

编辑 `lib/config/environments/production_environment.dart`：

```dart
const ProductionEnvironment(
  prodUrl: 'https://api.qintu.com',  // 修改为正式域名
);
```

---

## 🎨 App 内环境切换页面

在设置页面添加入口：

```dart
// lib/features/settings/settings_page.dart
ListTile(
  leading: const Icon(Icons.settings_ethernet),
  title: const Text('环境切换'),
  subtitle: Text(EnvironmentManager.currentName),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnvironmentSwitchPage(),
      ),
    );
  },
),
```

**⚠️ 注意：** 生产环境应移除此功能或添加密码保护！

---

## 📊 环境对比

| 特性 | 本地 | CloudBase 测试 | CloudBase 生产 | 生产服务器 |
|------|------|---------------|---------------|-----------|
| **成本** | 免费 | 免费额度 | 免费额度 | 服务器费用 |
| **数据持久** | ❌ | ✅ | ✅ | ✅ |
| **网络要求** | 同 WiFi | 任何网络 | 任何网 | 任何网 |
| **响应速度** | 快 | 中 | 中 | 快 |
| **调试便利** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **适合阶段** | 开发 | 测试 | 预上线 | 正式 |

---

## 🚦 上线前检查清单

### 1. 修改环境配置

```dart
// lib/utils/constants.dart
class Constants {
  // 改为生产环境
  static const AppEnv currentEnv = AppEnv.production;
}
```

### 2. 更新生产服务器地址

```dart
// lib/config/environments/production_environment.dart
const ProductionEnvironment(
  prodUrl: 'https://api.qintu.com',  // 替换为正式域名
);
```

### 3. 移除或保护环境切换页面

```dart
// 方案 1: 完全移除
// 删除 EnvironmentSwitchPage 相关代码

// 方案 2: 添加密码保护
if (EnvironmentManager.isDevelopment) {
  // 显示环境切换
} else {
  // 隐藏或要求输入管理员密码
}
```

### 4. 关闭调试日志

```dart
// 生产环境配置中已默认关闭
@override
bool get enableDebugLogs => false;

@override
bool get enableNetworkLogs => false;
```

---

## 💡 最佳实践

### ✅ DO

1. **开发时使用本地环境** - 快速迭代，不消耗额度
2. **测试使用 CloudBase** - 数据持久，方便团队协作
3. **上线前切换到生产** - 确保配置正确
4. **定期检查配置** - 避免误提交敏感信息

### ❌ DON'T

1. **不要在生产环境使用本地 IP**
2. **不要提交 `.env` 文件到 Git**
3. **不要让环境切换页面暴露给用户**
4. **不要硬编码服务器地址** - 统一使用环境配置

---

## 🔍 故障排除

### 问题 1: 切换环境后不生效

**解决：**
1. 完全重启 App（不是回到后台）
2. 检查 `Constants.currentEnv` 是否正确
3. 查看控制台输出：`EnvironmentManager.printEnvironmentInfo()`

### 问题 2: 本地环境手机无法连接

**解决：**
1. 确认手机和电脑在同一 WiFi
2. 检查 Windows 防火墙是否允许 Node.js
3. 确认 IP 地址正确（`ipconfig` 查看）
4. 测试服务器是否运行：`http://192.168.x.x:9000/health`

### 问题 3: CloudBase 环境请求失败

**解决：**
1. 检查 CloudBase 免费额度是否用完
2. 确认网关路径正确（`/qintu-api-test` vs `/qintu-api`）
3. 查看 CloudBase 控制台函数日志

---

## 📚 相关文档

- [本地服务器配置](LOCAL_SERVER_SETUP.md)
- [认证系统测试](AUTH_SYSTEM_TEST_REPORT.md)
- [云函数部署踩坑](CLOUDBASE_FUNCTION_TROUBLESHOOTING.md)

---

## 📝 更新记录

| 日期 | 更新内容 | 负责人 |
|------|---------|--------|
| 2026-04-09 | 初始版本，创建多环境配置架构 | AI Assistant |
