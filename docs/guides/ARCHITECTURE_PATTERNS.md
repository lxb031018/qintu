# 架构经验与规范

> 本文档记录项目架构改进过程中的经验教训，指导未来开发。

---

## 📁 目录结构规范

### 规则：按职责合并，避免过度拆分

**✅ 好的做法：**
```
lib/
├── managers/           # 所有状态管理器（2+ 个文件）
├── models/             # 所有数据模型
├── providers/          # 所有 Provider（2+ 个文件）
├── services/           # 所有服务层
```

**❌ 避免：**
```
lib/
├── state/
│   ├── managers/       # 只有 1 个文件
│   ├── providers/      # 只有 1 个文件
│   └── models/         # 只有 1 个文件
```

**判断标准：**
- 如果子目录下只有 1 个文件 → 合并到上级目录
- 如果子目录下有 2+ 个文件 → 可以保留
- 目录层级不超过 3 层

**经验：**
> 2026-04-07 曾出现 `state/managers/`、`state/providers/`、`state/models/` 各只有 1 个文件的情况，增加了认知负担。合并到 `managers/` 和 `models/` 后更清晰。

---

## 🔐 Token 安全管理规范

### 规则：Token 不暴露在 Provider 状态中

**✅ 正确做法：**
```dart
// UserState 只包含非敏感数据
class UserState {
  final String? userId;
  final String? phoneNumber;
  final String? userRole;
  // ❌ 不要包含 accessToken 和 refreshToken
}

// Token 仅存储在 SecureStorage 中
class SecureStorage {
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConfig.accessTokenKey);
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

**❌ 错误做法：**
```dart
// Token 暴露在 Provider 状态中
_state = _state.copyWith(
  accessToken: loginInfo?.accessToken,    // ❌ 任何 Widget 都能访问
  refreshToken: loginInfo?.refreshToken,  // ❌ 安全风险
);

// 路由中传递 Token
return RoleSelectionPage(
  accessToken: authStateManager.state.accessToken ?? '',  // ❌ 不应该这样传
);
```

**安全原则：**
1. Token 仅存在于 `SecureStorage` 中
2. 页面不需要知道 Token，由拦截器自动处理
3. 路由传参只传 userId、phone 等非敏感数据

---

## 🏗️ 依赖注入规范

### 规则：统一使用 Provider，不引入 GetIt

**✅ 当前方案：**
```dart
// 状态管理 → Provider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => BindingProvider()),
    ChangeNotifierProvider.value(value: _authStateManager),
  ],
  child: MyApp(),
)

// 单例服务 → 私有构造函数
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();
}
```

**❌ 禁止：**
```dart
// 不要引入 GetIt/ServiceLocator
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  // ... ❌ 增加认知负担，且未被使用
}
```

**决策依据：**
1. 项目已经有 Provider 作为状态管理方案
2. `ApiClient` 已经是单例，不需要 GetIt
3. `AuthStateManager` 通过 Provider 注入，不需要 GetIt
4. 减少依赖和维护成本

**禁止：**
- 重新引入 `get_it` 包
- 创建新的 ServiceLocator
- 通过 `getIt<T>()` 获取服务实例

---

## 🧪 测试编写规范

### 规则：核心状态管理必须有测试覆盖

**必须测试的模块：**
1. `AuthStateManager` - 认证状态管理
2. `BindingProvider` - 绑定关系状态管理
3. 未来新增的 Provider/Manager

**测试模板：**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qintu/managers/auth_state_manager.dart';

void main() {
  group('AuthStateManager', () {
    late AuthStateManager manager;

    setUp(() {
      manager = AuthStateManager();
    });

    tearDown(() {
      manager.dispose();
    });

    test('初始状态应该是正确的', () {
      expect(manager.state.authStatus, AuthStatus.unknown);
      expect(manager.state.userId, isNull);
    });

    // 测试每个方法的行为...
  });
}
```

**注意事项：**
- 如果依赖 `.env` 文件，在 `setUpAll` 中加载：
  ```dart
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });
  ```
- 每个测试用例应该独立，不依赖其他测试的状态
- 使用 `setUp`/`tearDown` 确保环境干净

**最低测试覆盖要求：**
- 初始状态检查 ✅
- 核心方法的行为检查 ✅
- 错误处理检查 ✅

---

## 📦 HTTP 客户端规范

### 规则：统一使用 ApiClient（Dio），不使用 http

**✅ 正确做法：**
```dart
final apiClient = ApiClient();

// GET 请求
final response = await apiClient.get<Map<String, dynamic>>('/api/bindings/my');

// POST 请求
final response = await apiClient.post<Map<String, dynamic>>(
  '/api/bindings/generate',
  data: {'receiver_phone': phone},
);
```

**❌ 禁止：**
```dart
// 不要使用 http 包
import 'package:http/http.dart' as http;  // ❌

// 不要创建新的 HTTP 客户端
class MyApiService {
  final http.Client _client = http.Client();  // ❌
}
```

**原因：**
1. `ApiClient` 有拦截器自动注入 Token
2. 统一的错误处理和日志
3. 避免维护两套代码

**已删除：**
- `lib/services/api_service.dart`（基于 http）
- `lib/services/api_response.dart`（旧的响应模型）
- `pubspec.yaml` 中的 `http` 依赖

---

## 🚀 未来改进建议

### 中优先级
1. **利用 Freezed** → 自动生成 `UserState` 的 `copyWith/==/hashCode`
2. **实现 Token 刷新** → 处理 `api_client.dart` 和 `auth_state_manager.dart` 中的 TODO
3. **URL 编码** → 查询参数使用 Dio 的 `queryParameters` 而不是字符串拼接

### 低优先级
4. **路由改进** → 页面从 Provider 树读取数据，而不是构造函数传递
5. **更多测试** → 覆盖 API 调用和页面交互
6. **性能优化** → 按需加载、缓存策略

---

## 📝 变更记录

| 日期 | 改进内容 | 原因 |
|------|---------|------|
| 2026-04-07 | 合并 `state/` 目录到 `managers/` 和 `models/` | 避免过度拆分，降低认知负担 |
| 2026-04-07 | Token 从 Provider 状态中移除 | 安全考虑，Token 不应暴露给所有 Widget |
| 2026-04-07 | 删除 `GetIt`/`ServiceLocator` | 未使用，增加维护成本 |
| 2026-04-07 | 补充测试覆盖 | 之前零测试覆盖 |
| 2026-04-07 | 统一使用 Dio，删除 http | 避免两套 HTTP 客户端并存 |
