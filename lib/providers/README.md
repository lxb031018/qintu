# Providers 目录

全局状态管理，使用 Provider 进行依赖注入和状态管理。

## 目录结构

```
providers/
├── auth_state_manager.dart    # 唯一认证源，管理登录/登出/Token 状态
├── binding_provider.dart      # 绑定关系状态管理（CRUD 操作）
├── settings_manager.dart      # 设置管理（字体大小、主题偏好等）
└── theme_manager.dart         # 主题管理（亮色/暗色模式切换）
```

## 文件说明

| 文件 | 作用 | 注入方式 |
|------|------|----------|
| `auth_state_manager.dart` | **唯一认证源**，管理登录状态、用户信息、Token 刷新。已删除旧的 UserProvider，不要重新创建 | `ChangeNotifierProvider.value` |
| `binding_provider.dart` | 绑定关系状态管理，包括发送请求、确认/拒绝请求、加载列表等 CRUD 操作 | `ChangeNotifierProvider` |
| `settings_manager.dart` | 应用设置管理，包括字体大小、角色偏好、环境偏好等 | `ChangeNotifierProvider` |
| `theme_manager.dart` | 主题管理，支持亮色/暗色模式切换。已移除单例模式，通过 Provider 注入 | `ChangeNotifierProvider.value` |

## 使用方式

### 统一导入（推荐）

```dart
// 一次性导入所有 Provider
import 'package:qintu/providers/index.dart';
```

### 在 main.dart 中注入

```dart
MultiProvider(
  providers: [
    // BindingProvider 支持构造函数注入（可选的 apiClient 参数）
    ChangeNotifierProvider(create: (_) => BindingProvider()),
    ChangeNotifierProvider.value(value: AuthStateManager()),
    ChangeNotifierProvider.value(value: ThemeManager()),
    ChangeNotifierProvider(create: (_) => SettingsManager()),
  ],
  child: MyApp(),
)
```

### 在组件中读取

```dart
// 读取并监听变化
final auth = context.watch<AuthStateManager>();

// 只读取一次（不监听变化）
final binding = context.read<BindingProvider>();
```

### 单元测试中注入 Mock

```dart
// 创建 Mock ApiClient
final mockClient = MockApiClient();

// 注入到 BindingProvider
final provider = BindingProvider(apiClient: mockClient);

// 现在可以隔离网络请求进行测试
await provider.loadBindings();
expect(provider.bindings, isNotEmpty);
```

## 架构规则

1. **AuthStateManager 是唯一认证源**：不要创建 UserProvider 或其他认证状态管理
2. **通过 Provider 获取实例**：不要使用 GetIt/ServiceLocator
3. **ThemeManager 不使用单例**：通过 `ChangeNotifierProvider.value` 注入
4. **状态不可变性**：修改状态时创建新对象，避免直接修改
5. **异步操作**：长时间运行的操作（如网络请求）在 Provider 内部处理

## 状态管理规范

```dart
class BindingProvider extends ChangeNotifier {
  List<Binding> _bindings = [];
  bool _isLoading = false;
  String? _error;

  List<Binding> get bindings => _bindings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBindings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bindings = await apiClient.getBindings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```
