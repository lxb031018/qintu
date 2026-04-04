# BindingProvider 使用指南

## 📋 概述

`BindingProvider` 是绑定关系的状态管理器，负责管理所有与绑定相关的操作。

## 🚀 基本使用

### 1. 初始化

在用户登录后，需要初始化 `BindingProvider`：

```dart
// 获取 BindingProvider 实例
final bindingProvider = context.read<BindingProvider>();

// 使用 UserProvider 中的 ApiService 初始化
bindingProvider.init(userProvider.apiService!);
```

### 2. 加载绑定列表

```dart
await bindingProvider.loadBindings();

// 访问绑定数据
print('总绑定数量: ${bindingProvider.bindings.length}');
print('作为发送者: ${bindingProvider.asSenderCount}');
print('作为接收者: ${bindingProvider.asReceiverCount}');
```

### 3. 生成绑定码

```dart
final bindCode = await bindingProvider.generateBindCode(
  receiverPhone: '+86 13800138000',  // 可选
  remark: '给父亲的绑定',              // 可选
);

if (bindCode != null) {
  print('绑定码: $bindCode');
  // 显示绑定码给用户
} else {
  print('生成失败: ${bindingProvider.error}');
}
```

### 4. 确认绑定

```dart
final success = await bindingProvider.confirmBinding('ABC12345');

if (success) {
  print('绑定成功: ${bindingProvider.successMessage}');
} else {
  print('绑定失败: ${bindingProvider.error}');
}
```

### 5. 解除绑定

```dart
final success = await bindingProvider.revokeBinding(bindingId);

if (success) {
  print('解除成功: ${bindingProvider.successMessage}');
} else {
  print('解除失败: ${bindingProvider.error}');
}
```

### 6. 检查绑定码

```dart
final info = await bindingProvider.checkBindCode('ABC12345');

if (info != null) {
  print('绑定码有效: $info');
} else {
  print('绑定码无效: ${bindingProvider.error}');
}
```

## 📊 属性说明

### 绑定数据
- `bindings`: 所有绑定关系列表
- `bindingSummary`: 绑定摘要信息（包含 asSender, asReceiver 等）
- `senderBindings`: 仅作为发送者的绑定关系
- `receiverBindings`: 仅作为接收者的绑定关系

### 状态数据
- `isLoading`: 是否正在加载
- `error`: 错误信息
- `successMessage`: 成功消息

### 计算属性
- `asSenderCount`: 作为发送者的绑定数量
- `asReceiverCount`: 作为接收者的绑定数量
- `isSenderLimitReached`: 发送者是否达到绑定上限（5人）
- `isReceiverLimitReached`: 接收者是否达到绑定上限（3人）
- `hasActiveBindings`: 是否有活跃的绑定关系

## ⚠️ 注意事项

1. **必须先初始化**：在使用任何功能前，必须先调用 `init(apiService)` 方法
2. **错误处理**：操作失败时，错误信息会保存在 `error` 属性中
3. **自动刷新**：成功执行操作后，会自动刷新绑定列表
4. **状态清理**：可以使用 `clearError()` 和 `clearSuccessMessage()` 清理状态

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
                      final code = await provider.generateBindCode();
                      if (code != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('绑定码: $code')),
                        );
                      }
                    },
              child: Text(
                provider.isSenderLimitReached
                    ? '绑定人数已达上限'
                    : '生成绑定码',
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

`BindingProvider` 已经在 `main.dart` 中注册：

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => BindingProvider()),
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
