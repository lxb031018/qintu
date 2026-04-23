# Flutter Widget Preview 批量添加指南

## 已添加预览的组件 ✅

### app_shell
- [x] splash_screen.dart

### auth  
- [x] auth_button.dart

### map_navigation
- [x] route_input_card.dart

### settings
- [ ] font_size_selector_card.dart
- [ ] logout_card.dart
- [ ] settings_section_card.dart
- [ ] tab_switch_mode_card.dart
- [ ] theme_selector_card.dart

### widgets/common
- [ ] app_button.dart
- [ ] app_confirm_dialog.dart
- [ ] logout_dialog.dart
- [ ] tab_badge.dart

### 不适合预览的组件(依赖Provider/复杂上下文)
- [ ] unified_home_page.dart
- [ ] auth_page.dart
- [ ] relationship_binding_tab.dart
- [ ] settings_page.dart
- [ ] 其他页面级组件

## 添加预览的步骤

### 1. 在文件顶部添加import
```dart
import 'package:flutter/widget_previews.dart';
```

### 2. 在文件末尾添加@Preview函数
```dart
@Preview(name: '组件名称', group: '模块名')
Widget previewComponentName() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: ComponentName(), // 替换为实际组件
      ),
    ),
  );
}
```

### 3. 有多个状态的组件添加多个预览
```dart
@Preview(name: '按钮-正常', group: 'common')
Widget previewButtonNormal() => MaterialApp(...);

@Preview(name: '按钮-加载', group: 'common')  
Widget previewButtonLoading() => MaterialApp(...);
```

## 批量处理命令

在PowerShell中运行:
```powershell
# 查找所有需要添加预览的Widget文件
Get-ChildItem -Path lib\features,lib\widgets -Recurse -Filter *.dart | 
  Select-String -Pattern "class \w+ extends (Stateless|Stateful)Widget" |
  Select-Object -Unique Path
```
