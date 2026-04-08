# BindingProvider 使用指南

## 📋 概述

`BindingProvider` 是绑定关系的状态管理器，负责管理所有与绑定相关的操作。

## 🚀 基本使用

### 1. 使用方式

`BindingProvider` 内部使用 `ApiClient` 单例，无需手动初始化：

```dart
// 获取 BindingProvider 实例
final bindingProvider = context.read<BindingProvider>();

// 直接调用方法（ApiClient 会自动从 SecureStorage 获取 Token）
await bindingProvider.loadBindings();
```

### 2. 加载绑定列表

```dart
await bindingProvider.loadBindings();

// 访问绑定数据
print('总绑定数量: ${bindingProvider.bindings.length}');
print('作为发送者: ${bindingProvider.asSenderCount}');
print('作为接收者: ${bindingProvider.asReceiverCount}');
```

### 3. 发送手机号绑定请求

```dart
final success = await bindingProvider.requestPhoneBinding(
  receiverPhone: '+86 13800138000',
  senderName: '张三',
);

if (success) {
  print('绑定请求已发送，等待接收者确认');
} else {
  print('请求失败: ${bindingProvider.error}');
}
```

### 4. 获取待确认的绑定请求

```dart
await bindingProvider.loadPendingRequests();

// 访问待确认请求列表
print('待确认请求数量: ${bindingProvider.pendingRequests.length}');
```

### 5. 确认绑定请求

```dart
final success = await bindingProvider.confirmRequest(requestId);

if (success) {
  print('绑定成功');
} else {
  print('绑定失败: ${bindingProvider.error}');
}
```

### 6. 拒绝绑定请求

```dart
final success = await bindingProvider.rejectRequest(requestId);

if (success) {
  print('已拒绝绑定请求');
} else {
  print('拒绝失败: ${bindingProvider.error}');
}
```

### 7. 解除绑定

```dart
final success = await bindingProvider.revokeBinding(bindingId);

if (success) {
  print('解除绑定成功');
} else {
  print('解除失败: ${bindingProvider.error}');
}
```

## 📊 属性说明

### 绑定数据
- `bindings`: 所有绑定关系列表
- `bindingSummary`: 绑定摘要信息（包含 asSender, asReceiver 等）
- `senderBindings`: 仅作为发送者的绑定关系
- `receiverBindings`: 仅作为接收者的绑定关系
- `pendingRequests`: 待确认的绑定请求列表

### 状态数据
- `isLoading`: 是否正在加载
- `error`: 错误信息

### 计算属性
- `asSenderCount`: 作为发送者的绑定数量
- `asReceiverCount`: 作为接收者的绑定数量
- `isSenderLimitReached`: 发送者是否达到绑定上限（5人）
- `isReceiverLimitReached`: 接收者是否达到绑定上限（3人）
- `hasActiveBindings`: 是否有活跃的绑定关系

## ⚠️ 注意事项

1. **无需手动初始化**：`BindingProvider` 内部使用 `ApiClient()` 单例，自动从 `SecureStorage` 获取 Token
2. **错误处理**：操作失败时，错误信息会保存在 `error` 属性中
3. **自动刷新**：成功执行操作后，会自动刷新绑定列表
4. **状态清理**：可以使用 `clearError()` 清理错误状态
5. **双向确认机制**：绑定需要发送者发请求，接收者确认后才生效

## 📝 完整示例

```dart
class BindingExampleWidget extends StatefulWidget {
  @override
  State<BindingExampleWidget> createState() => _BindingExampleWidgetState();
}

class _BindingExampleWidgetState extends State<BindingExampleWidget> {
  @override
  void initState() {
    super.initState();
    // 页面加载时获取绑定列表
    _loadBindings();
  }

  Future<void> _loadBindings() async {
    final bindingProvider = context.read<BindingProvider>();
    await bindingProvider.loadBindings();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BindingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              children: [
                Text('错误: ${provider.error}'),
                ElevatedButton(
                  onPressed: _loadBindings,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Text('作为发送者: ${provider.asSenderCount}/5'),
            Text('作为接收者: ${provider.asReceiverCount}/3'),
            ElevatedButton(
              onPressed: provider.isSenderLimitReached
                  ? null
                  : () async {
                      final success = await provider.requestPhoneBinding(
                        receiverPhone: '+86 13800138000',
                        senderName: '张三',
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('绑定请求已发送')),
                        );
                      }
                    },
              child: Text(
                provider.isSenderLimitReached
                    ? '绑定人数已达上限'
                    : '发送绑定请求',
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.bindings.length,
                itemBuilder: (context, index) {
                  final binding = provider.bindings[index];
                  return ListTile(
                    title: Text(binding.partnerNickname ?? '未知用户'),
                    subtitle: Text('状态: ${binding.status.name}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final success = await provider.revokeBinding(binding.id);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('解除绑定成功')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
```

## 🔧 在 main.dart 中注册

`BindingProvider` 和 `AuthStateManager` 已经在 `main.dart` 中注册：

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => BindingProvider()),
    ChangeNotifierProvider.value(value: _authStateManager),
  ],
  child: MaterialApp(...),
)
```

## 📌 最佳实践

1. **页面加载时调用 `loadBindings()`**
2. **操作前检查限制**：使用 `isSenderLimitReached` 和 `isReceiverLimitReached`
3. **显示加载状态**：使用 `isLoading` 显示加载指示器
4. **错误提示**：显示 `error` 给用户
5. **成功反馈**：使用 `successMessage` 提供操作成功反馈
