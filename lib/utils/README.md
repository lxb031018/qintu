# Utils 目录

工具函数和辅助类。

## 目录结构

```
utils/
├── app_snackbar.dart          # 全局 Snackbar/Toast 工具
├── error_mapper.dart          # 错误类型映射（异常 -> 用户友好消息）
├── exceptions.dart            # 自定义异常类定义
├── http_error_handler.dart    # HTTP 错误处理工具
├── logger.dart                # 日志系统入口
├── logger/
│   ├── file_logger.dart       # 文件日志写入器
│   └── log_config.dart        # 日志配置（级别、格式等）
├── phone_utils.dart           # 手机号格式化工具
├── theme_utils.dart           # 主题相关工具函数
└── validators.dart            # 表单验证工具
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `app_snackbar.dart` | 全局 Snackbar/Toast 工具，统一显示提示消息 |
| `error_mapper.dart` | 错误类型映射器，将底层异常转换为用户友好的提示文案 |
| `exceptions.dart` | 自定义异常类定义（网络异常、认证异常、业务异常等） |
| `http_error_handler.dart` | HTTP 错误处理工具，统一处理不同状态码的错误 |
| `logger.dart` | 日志系统入口，提供 debug/info/warn/error 等日志方法 |
| `logger/file_logger.dart` | 文件日志写入器，将日志写入本地文件（开发调试用） |
| `logger/log_config.dart` | 日志配置，定义日志级别、格式、输出目标等 |
| `phone_utils.dart` | 手机号格式化工具（脱敏、校验、格式化等） |
| `theme_utils.dart` | 主题相关工具函数（亮度判断、颜色对比度等） |
| `validators.dart` | 表单验证工具（手机号、验证码、邮箱等校验） |

## 使用方式

```dart
// Snackbar 提示
AppSnackbar.success('操作成功');
AppSnackbar.error('操作失败');
AppSnackbar.info('提示信息');

// 错误映射
final message = ErrorMapper.mapToString(error);

// 日志记录
Logs.api.debug('API 请求', data: {'url': '/api/users'});
Logs.ui.info('页面加载完成');
Logs.auth.error('认证失败', error: e);

// 手机号处理
final masked = PhoneUtils.maskPhone('13800138000'); // 138****8000
final isValid = PhoneUtils.isValid('13800138000');

// 表单验证
final error = Validators.validatePhone(phone);
if (error != null) {
  // 显示错误
}
```

## 规范

- 工具函数应该是**纯函数**，不依赖外部状态
- 避免在工具函数中使用 `context`，除非必要
- 日志系统使用 `Logs` 类，不要直接使用 `print`
- 错误处理使用自定义异常类，便于类型匹配
