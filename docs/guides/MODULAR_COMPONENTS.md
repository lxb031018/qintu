# 模块化组件使用指南

## 📋 概述

本项目已完成全面的模块化重构，消除了重复代码，提升了可维护性和可测试性。

---

## 🔧 新增模块清单

### 1. **PhoneUtils** - 手机号脱敏工具

**位置**: `lib/utils/phone_utils.dart`

```dart
// UI 显示脱敏
PhoneUtils.maskPhone('13812345678')  // → '138****5678'

// 日志脱敏（带标记）
PhoneUtils.maskForLog('13812345678')  // → '[脱敏]138****5678'

// 批量脱敏
PhoneUtils.maskList(['13812345678', '13987654321'])

// 验证手机号
PhoneUtils.isValidPhone('13812345678')  // → true

// 格式化
PhoneUtils.formatPhone('13812345678')  // → '138 1234 5678'
```

---

### 2. **AppSnackbar** - SnackBar 辅助类

**位置**: `lib/utils/app_snackbar.dart`

```dart
// 成功提示（绿色）
AppSnackbar.showSuccess(context, '操作成功');

// 错误提示（红色）
AppSnackbar.showError(context, '操作失败');

// 信息提示（蓝色）
AppSnackbar.showInfo(context, '请注意');

// 警告提示（橙色）
AppSnackbar.showWarning(context, '警告信息');
```

**替代前代码**:
```dart
// ❌ 旧方式（重复代码）
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(message),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
  ),
);

// ✅ 新方式（统一调用）
AppSnackbar.showError(context, '操作失败');
```

---

### 3. **AppConfirmDialog** - 通用确认对话框

**位置**: `lib/widgets/common/app_confirm_dialog.dart`

```dart
// 标准确认对话框
final result = await AppConfirmDialog.show(
  context,
  title: '确认操作',
  message: '确定要执行此操作吗？',
  confirmText: '确定',
  cancelText: '取消',
);

if (result == true) {
  // 用户点击了确定
}

// 危险操作确认对话框（红色主题）
final result = await AppConfirmDialog.showDanger(
  context,
  title: '删除数据',
  message: '此操作不可恢复，确定要删除吗？',
);
```

**替代前代码**:
```dart
// ❌ 旧方式（15+ 处重复）
showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('确认操作'),
    content: Text('确定要执行此操作吗？'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('取消'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('确定'),
      ),
    ],
  ),
);

// ✅ 新方式（统一调用）
AppConfirmDialog.show(context, title: '确认操作', message: '确定要执行吗？');
```

---

### 4. **ThemeUtils** - 主题适配工具

**位置**: `lib/utils/theme_utils.dart`

```dart
// 判断是否为深色主题
if (ThemeUtils.isDark(context)) { ... }

// 自适应颜色
final color = ThemeUtils.adaptiveColor(
  context: context,
  light: Colors.white,
  dark: Colors.black,
);

// 快捷获取背景色
final bgColor = ThemeUtils.getBackgroundColor(context);

// 快捷获取卡片色
final cardColor = ThemeUtils.getCardBackground(context);

// 快捷获取文字色
final textColor = ThemeUtils.getTextColor(context);

// 快捷获取次要文字色
final lightTextColor = ThemeUtils.getLightTextColor(context);

// 快捷获取输入框背景色
final inputBgColor = ThemeUtils.getInputBackground(context);

// 快捷获取边框颜色
final borderColor = ThemeUtils.getBorderColor(context);
```

**替代前代码**:
```dart
// ❌ 旧方式（17+ 处重复）
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;
final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;

// ✅ 新方式（统一调用）
final bgColor = ThemeUtils.getBackgroundColor(context);
final textColor = ThemeUtils.getTextColor(context);
```

---

### 5. **Validators** - 验证工具类

**位置**: `lib/utils/validators.dart`

```dart
// 验证手机号
String? phoneError = Validators.validatePhone(phone);
if (phoneError != null) {
  // 显示错误信息
}

// 验证验证码
String? codeError = Validators.validateCode(code);

// 验证姓名
String? nameError = Validators.validateName(name);

// 验证必填项
String? requiredError = Validators.validateRequired(value, '用户名');

// 验证邮箱
String? emailError = Validators.validateEmail(email);

// 验证密码
String? passwordError = Validators.validatePassword(password);
```

**使用示例（TextFormField）**:
```dart
TextFormField(
  validator: Validators.validatePhone,
  decoration: InputDecoration(labelText: '手机号'),
)

TextFormField(
  validator: (value) => Validators.validateRequired(value, '姓名'),
  decoration: InputDecoration(labelText: '姓名'),
)
```

---

## 📊 模块化成果

| 模块 | 消除重复代码数 | 文件位置 |
|------|---------------|----------|
| PhoneUtils | 4 处 `_maskPhone` 重复 | `lib/utils/phone_utils.dart` |
| AppSnackbar | 28 处 SnackBar 重复 | `lib/utils/app_snackbar.dart` |
| AppConfirmDialog | 15 处对话框重复 | `lib/widgets/common/app_confirm_dialog.dart` |
| ThemeUtils | 17 处 `isDark` 判断 | `lib/utils/theme_utils.dart` |
| Validators | 3 处验证重复 | `lib/utils/validators.dart` |

---

## 🎯 使用建议

### 1. **新功能开发**

- ✅ 优先使用现有模块，避免重复造轮子
- ✅ 新增工具类时遵循相同的设计模式
- ✅ 所有 UI 提示统一使用 `AppSnackbar`
- ✅ 所有确认对话框统一使用 `AppConfirmDialog`

### 2. **旧代码迁移**

逐步将旧代码迁移到新模块，优先级：
1. **P0**: SnackBar、对话框（立即可见效果）
2. **P1**: 主题适配、验证逻辑
3. **P2**: 其他优化

### 3. **代码审查**

提交代码前检查：
- ❌ 是否有重复的工具函数
- ❌ 是否有直接调用 `ScaffoldMessenger.showSnackBar`
- ❌ 是否有直接调用 `showDialog<AlertDialog>`
- ❌ 是否有重复的 `isDark` 判断
- ✅ 是否统一使用模块化工具类

---

## 📝 完整模块清单

| 模块 | 职责 | 状态 |
|------|------|------|
| `PhoneUtils` | 手机号脱敏、验证、格式化 | ✅ 已完成 |
| `AppSnackbar` | SnackBar 统一封装 | ✅ 已完成 |
| `AppConfirmDialog` | 通用确认对话框 | ✅ 已完成 |
| `ThemeUtils` | 主题适配工具 | ✅ 已完成 |
| `Validators` | 表单验证逻辑 | ✅ 已完成 |
| `Logger` | 日志系统 | ✅ 已有 |
| `AuthStateManager` | 认证状态管理 | ✅ 已有 |
| `AppRouter` | go_router 路由配置 | ✅ 已有 |

---

## 🔍 搜索关键词

当需要修改相关功能时，可搜索以下关键词：

```
AppSnackbar        # 所有 SnackBar 调用
AppConfirmDialog   # 所有确认对话框
ThemeUtils         # 所有主题适配
PhoneUtils         # 所有手机号脱敏
Validators         # 所有表单验证
```

---

## ⚠️ 注意事项

1. **向后兼容**: 所有新模块都与旧代码兼容，可逐步迁移
2. **测试覆盖**: 建议为核心工具类添加单元测试
3. **文档更新**: 新增模块时同步更新此文档
4. **代码审查**: 确保新代码优先使用模块化工具

---

## 📚 相关文档

- [手机号脱敏使用指南](./PHONE_MASK_USAGE.md)
- [日志系统使用指南](./LOGGER_GUIDE.md)
- [前端开发规范](../architecture/FRONTEND_DEVELOPMENT.md)
