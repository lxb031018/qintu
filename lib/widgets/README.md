# Widgets 目录

全局通用组件，跨功能模块复用的 UI 组件。

## 目录结构

```
widgets/
└── common/
    ├── app_confirm_dialog.dart    # 全局确认对话框组件
    └── logout_dialog.dart         # 退出登录对话框
└── error_boundary.dart           # 全局错误边界 Widget，防止白屏
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `common/app_confirm_dialog.dart` | 全局确认对话框，用于危险操作前的二次确认（如删除、登出等） |
| `common/logout_dialog.dart` | 退出登录对话框，显示确认提示并处理登出逻辑 |
| `error_boundary.dart` | 全局错误边界 Widget，捕获未处理的异常，避免应用白屏 |

## 与 Features/widgets/ 的区别

| 目录 | 用途 | 示例 |
|------|------|------|
| `lib/widgets/` | **全局通用组件**，跨模块复用 | 错误边界、确认对话框 |
| `lib/features/xxx/widgets/` | **模块专属组件**，仅在该模块内使用 | binding 卡片、认证输入框 |

## 使用方式

```dart
// 错误边界包裹整个应用
ErrorBoundary(
  child: MaterialApp(...),
)

// 确认对话框
final confirmed = await AppConfirmDialog.show(
  context,
  title: '确认删除',
  content: '此操作不可撤销，确定继续吗？',
);

if (confirmed) {
  // 执行删除
}

// 退出登录对话框
await LogoutDialog.show(context);
```

## 规范

1. **只有跨模块复用的组件才放在这里**
2. **模块专属组件放在 `lib/features/xxx/widgets/`**
3. 组件应该是**无状态的**（StatelessWidget），通过参数接收数据
4. 组件应该支持**亮色/暗色主题**，避免硬编码颜色
