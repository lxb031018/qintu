# 工具使用指南

> 本文档统一描述项目中各个工具模块的使用方法。

---

## 📋 模块清单

| 模块 | 位置 | 用途 |
|------|------|------|
| Logger | `lib/utils/logger.dart` | 日志系统 |
| PhoneUtils | `lib/utils/phone_utils.dart` | 手机号脱敏、验证、格式化 |
| AppSnackbar | `lib/utils/app_snackbar.dart` | SnackBar 统一封装 |
| AppConfirmDialog | `lib/widgets/common/app_confirm_dialog.dart` | 通用确认对话框 |
| ThemeUtils | `lib/utils/theme_utils.dart` | 主题适配工具 |
| Validators | `lib/utils/validators.dart` | 表单验证逻辑 |
| AppWidgets | `lib/constants/app_widgets.dart` | Widget 样式常量 |

---

## 1. Logger - 日志系统

### 核心功能

| 特性 | 说明 |
|------|------|
| **日志级别** | debug / info / warning / error / critical |
| **标签分类** | 预定义 10 个常用标签（API、AUTH、BINDING 等） |
| **彩色输出** | 开发环境自动彩色，生产环境自动降级 |
| **数据附加** | 支持传递 Map 类型数据 |
| **堆栈跟踪** | 错误日志支持传递 StackTrace |

### 预定义标签

| 标签 | 用途 | 示例 |
|------|------|------|
| `Logs.api` | API 调用 | 请求、响应、错误 |
| `Logs.auth` | 认证相关 | 登录、注册、Token |
| `Logs.binding` | 绑定关系 | 生成码、确认、解绑 |
| `Logs.task` | 导航任务 | 创建、接受，完成、取消 |
| `Logs.location` | 位置共享 | 上传、查询、切换共享 |
| `Logs.ui` | UI 交互 | 页面跳转、用户操作 |
| `Logs.app` | 应用生命周期 | 启动、后台、恢复 |

### 基本使用

```dart
// 使用预定义标签
Logs.api.info('发送请求: GET /api/users/me');
Logs.auth.error('登录失败', data: {'phone': '+86 138****8000'});
Logs.binding.warning('绑定人数接近上限', data: {'current': 4, 'max': 5});

// 自定义标签
const logger = Logger('MY_CUSTOM_TAG');
logger.debug('调试信息');
```

### 不同日志级别

```dart
// DEBUG - 开发调试（生产环境自动忽略）
logger.debug('解析 JSON 数据');

// INFO - 正常业务流程
logger.info('用户登录成功');

// WARNING - 警告信息
logger.warning('绑定人数达到 80%');

// ERROR - 错误信息
logger.error('API 请求失败', stackTrace: stackTrace);

// CRITICAL - 严重错误
logger.critical('数据库连接断开');
```

### 生产环境配置

```dart
void main() {
  if (kReleaseMode) {
    // 生产环境：只记录 info 及以上级别
    Logger.setMinLevel(LogLevel.info);
  }
  runApp(MyApp());
}
```

---

## 2. PhoneUtils - 手机号脱敏工具

### 位置
`lib/utils/phone_utils.dart`

### 可用方法

```dart
// UI 显示脱敏
PhoneUtils.maskPhone('13812345678')       // → '138****5678'

// 日志脱敏（带标记）
PhoneUtils.maskForLog('13812345678')  // → '[脱敏]138****5678'

// 批量脱敏
PhoneUtils.maskList(['13812345678', '13987654321'])

// 验证手机号
PhoneUtils.isValidPhone('13812345678')  // → true

// 格式化
PhoneUtils.formatPhone('13812345678')  // → '138 1234 5678'
```

### 使用场景

| 场景 | 方法 |
|------|------|
| UI 界面显示 | `PhoneUtils.maskPhone()` |
| 日志打印 | `PhoneUtils.maskForLog()` |
| 批量处理 | `PhoneUtils.maskList()` |
| 表单验证 | `PhoneUtils.isValidPhone()` |

### 脱敏红线

| 场景 | 要求 |
|------|------|
| **日志打印** | ❌ 绝对禁止打印完整手机号，必须脱敏 |
| **UI 显示** | ✅ 所有界面展示的手机号必须脱敏 |
| **日志标签** | `[脱敏]` 前缀便于日志审查 |

---

## 3. AppSnackbar - SnackBar 统一封装

### 位置
`lib/utils/app_snackbar.dart`

### 基本使用

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

### 替代前代码

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

## 4. AppConfirmDialog - 通用确认对话框

### 位置
`lib/widgets/common/app_confirm_dialog.dart`

### 基本使用

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

### 替代前代码

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

## 5. ThemeUtils - 主题适配工具

### 位置
`lib/utils/theme_utils.dart`

### 基本使用

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
```

### 替代前代码

```dart
// ❌ 旧方式（17+ 处重复）
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;

// ✅ 新方式（统一调用）
final bgColor = ThemeUtils.getBackgroundColor(context);
```

---

## 6. Validators - 验证工具类

### 位置
`lib/utils/validators.dart`

### 基本使用

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
```

### 使用示例（TextFormField）

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

## 7. AppWidgets - Widget 样式常量

### 位置
`lib/constants/app_widgets.dart`

### 图标大小

```dart
AppWidgets.iconXSmall  // 14px
AppWidgets.iconSmall   // 16px
AppWidgets.iconMedium  // 18px
AppWidgets.iconNormal  // 20px
AppWidgets.iconLarge   // 24px
AppWidgets.iconXLarge  // 48px
```

### 输入框

```dart
AppWidgets.inputHeight         // 48px
AppWidgets.inputPadding       // EdgeInsets.symmetric(12, 12)
AppWidgets.inputBorderColor   // Color(0xFFE8E8E8)
AppWidgets.inputBorderRadius  // Radius.circular(10)
```

### 卡片

```dart
AppWidgets.cardRadius    // Radius.circular(12)
AppWidgets.cardShadow    // BoxShadow 列表
AppWidgets.cardPadding   // EdgeInsets.all(12)
AppWidgets.listCardMargin    // EdgeInsets.symmetric(horizontal: 12)
```

### 替代前代码

```dart
// ❌ 旧方式（硬编码）
Icon(Icons.location_on, size: 18)
const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
BorderRadius.circular(12)

// ✅ 新方式（统一常量）
Icon(Icons.location_on, size: AppWidgets.iconMedium)
AppWidgets.listItemPadding
BorderRadius.all(AppWidgets.cardRadius)
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

## ✅ 代码审查检查清单

提交代码前检查：
- ❌ 是否有重复的工具函数
- ❌ 是否有直接调用 `ScaffoldMessenger.showSnackBar`
- ❌ 是否有直接调用 `showDialog<AlertDialog>`
- ❌ 是否有重复的 `isDark` 判断
- ❌ 手机号是否脱敏
- ✅ 是否统一使用模块化工具类

---

**最后更新**：2026-04-17
