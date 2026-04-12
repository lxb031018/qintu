# Constants 目录

应用全局常量定义中心。

## 目录结构

```
constants/
├── api_endpoints.dart     # API 端点路径常量
├── app_colors.dart        # 应用颜色常量（含灰色层级、蓝色变体、透明度等）
├── app_durations.dart     # 动画/超时/延迟时间常量
├── app_font_sizes.dart    # 字体大小常量（9px ~ 32px）
├── app_radii.dart         # 圆角常量（xsmall ~ xxlarge）
├── app_roles.dart         # 角色枚举（Sender/Receiver）
├── app_statuses.dart      # 状态枚举（绑定状态、请求状态）
├── app_strings.dart       # 字符串常量（应用名、提示文案）
├── font_size_setting.dart # 字体大小设置选项（用户偏好：小/标准/大/特大）
└── storage_keys.dart      # 本地存储 Key 常量
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `api_endpoints.dart` | 所有后端 API 端点路径常量，统一管理避免硬编码 |
| `app_colors.dart` | 应用颜色常量（主色、状态色、灰色层级、蓝色变体、透明度等） |
| `app_durations.dart` | 动画时长、请求超时、缓存过期时间等时间常量 |
| `app_font_sizes.dart` | 字体大小常量（9px ~ 32px，共 11 个级别） |
| `app_radii.dart` | 圆角常量（4px ~ 24px，含快捷矩形构造器） |
| `app_roles.dart` | 用户角色枚举（发送者/接收者） |
| `app_statuses.dart` | 绑定状态枚举（pending/active/revoked/expired 等） |
| `app_strings.dart` | UI 字符串常量（应用名称、按钮文案、提示语等），支持多语言扩展 |
| `font_size_options.dart` | 字体大小选项配置（用户偏好设置，与 `app_font_sizes.dart` 不同） |
| `storage_keys.dart` | SharedPreferences/SecureStorage 的 Key 常量 |

## 使用方式

```dart
// API 端点
final url = ApiEndpoints.requestPhone;

// 颜色
Container(color: AppColors.primaryColor)

// 字符串
Text(AppStrings.appName)

// 存储 Key
await storage.setString(StorageKeys.authToken, token);
```

## 规范

- 所有魔法数字/字符串必须提取为常量
- 颜色统一使用 `AppColors`，避免在 UI 中直接写色值
- 文案统一使用 `AppStrings`，便于后续国际化
