# Theme 目录

主题配置和文本样式定义。

## 目录结构

```
theme/
├── app_theme.dart         # Material 主题构建（亮色/暗色模式）
└── app_text_styles.dart   # 文本样式定义（支持字体大小缩放）
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `app_theme.dart` | Material 主题构建，定义亮色和暗色模式的颜色方案、组件主题等 |
| `app_text_styles.dart` | 文本样式定义，统一管理字体大小、字重、行高，支持字体大小缩放 |

## 使用方式

```dart
// 在 main.dart 中应用主题
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeManager.themeMode,
  // ...
)

// 使用预定义文本样式
Text(
  '标题',
  style: AppTextStyles.title(context),
)

Text(
  '正文',
  style: AppTextStyles.body(context),
)
```

## 主题切换

```dart
// 切换亮色/暗色模式
themeManager.toggleTheme();

// 设置特定模式
themeManager.setThemeMode(ThemeMode.dark);
```

## 规范

- 颜色定义放在 `constants/app_colors.dart`
- 主题配置放在 `theme/` 目录
- 文本样式使用 `AppTextStyles` 统一管理，避免在 UI 中硬编码
- 支持字体大小缩放时，使用 `AppTextStyles` 的缩放参数
