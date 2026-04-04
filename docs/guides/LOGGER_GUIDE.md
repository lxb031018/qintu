# 亲途日志模块使用指南

## 📋 模块特性

### ✨ 核心功能

| 特性 | 说明 |
|------|------|
| **日志级别** | debug / info / warning / error / critical |
| **标签分类** | 预定义 10 个常用标签（API、AUTH、BINDING 等） |
| **彩色输出** | 开发环境自动彩色，生产环境自动降级 |
| **数据附加** | 支持传递 Map 类型数据 |
| **堆栈跟踪** | 错误日志支持传递 StackTrace |
| **DevTools 集成** | 自动发送到 Flutter DevTools Timeline |
| **文件日志** | 预留文件写入接口（可扩展） |

---

## 🚀 快速开始

### 1. 基本使用

```dart
import 'package:qintu/utils/logger.dart';

// 方式一：使用预定义标签
Logs.api.info('发送请求: GET /api/users/me');
Logs.auth.error('登录失败', data: {'phone': '+86 13800138000'});
Logs.binding.warning('绑定人数接近上限', data: {'current': 4, 'max': 5});

// 方式二：自定义标签
const logger = Logger('MY_CUSTOM_TAG');
logger.debug('调试信息');
```

### 2. 不同日志级别

```dart
const logger = Logger('TEST');

// DEBUG - 开发调试（生产环境自动忽略）
logger.debug('解析 JSON 数据', data: {'key': 'value'});

// INFO - 正常业务流程
logger.info('用户登录成功', data: {'openid': 'xxx'});
logger.info('导航任务创建成功', data: {'task_id': 'xxx'});

// WARNING - 警告信息
logger.warning('绑定人数达到 80%', data: {'current': 4, 'max': 5});

// ERROR - 错误信息
logger.error('API 请求失败', data: {'url': '/api/tasks'}, stackTrace: stackTrace);

// CRITICAL - 严重错误
logger.critical('数据库连接断开', stackTrace: stackTrace);
```

---

## 📚 实际使用示例

### API 服务中使用

```dart
// lib/services/api_service.dart
import '../utils/logger.dart';

class ApiService {
  Future<ApiResponse> createNavigationTask({...}) async {
    Logs.api.info('创建导航任务', data: {
      'receiver': receiverOpenid,
      'destination': endName,
    });

    try {
      final response = await _client.post(...);
      
      Logs.api.info('导航任务创建成功', data: {
        'task_id': response.data['task_id'],
      });
      
      return ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      Logs.api.error('创建导航任务失败', data: {
        'error': e.toString(),
        'receiver': receiverOpenid,
      }, stackTrace: stackTrace);
      
      throw ApiException(
        code: 'CREATE_TASK_FAILED',
        message: '创建导航任务失败',
      );
    }
  }
}
```

### 认证模块中使用

```dart
// 登录流程
Logs.auth.info('开始登录流程', data: {'phone': phone});

// 发送验证码
Logs.auth.info('发送验证码', data: {'phone': phone});

// 验证成功
Logs.auth.info('用户登录成功', data: {
  'openid': user.openid,
  'user_type': user.userType.name,
});

// 验证失败
Logs.auth.error('登录失败', data: {
  'error': error.message,
  'code': error.code,
}, stackTrace: stackTrace);
```

### 绑定模块中使用

```dart
// 生成绑定码
Logs.binding.info('生成绑定码', data: {
  'sender': senderOpenid,
  'bind_code': bindCode,
});

// 确认绑定
Logs.binding.info('确认绑定成功', data: {
  'sender': senderOpenid,
  'receiver': receiverOpenid,
  'bind_code': bindCode,
});

// 绑定失败
Logs.binding.warning('绑定码无效', data: {
  'bind_code': inputCode,
  'reason': '已过期',
});
```

### 导航任务模块

```dart
// 创建任务
Logs.task.info('创建导航任务', data: {
  'task_id': taskId,
  'sender': senderOpenid,
  'receiver': receiverOpenid,
  'destination': endName,
});

// 接受任务
Logs.task.info('接收者接受任务', data: {
  'task_id': taskId,
  'receiver': receiverOpenid,
});

// 开始导航
Logs.task.info('开始导航', data: {
  'task_id': taskId,
  'transport_mode': 'drive',
});

// 完成任务
Logs.task.info('导航任务完成', data: {
  'task_id': taskId,
  'duration': durationSeconds,
});
```

### 位置共享模块

```dart
// 上传位置
Logs.location.debug('上传位置', data: {
  'latitude': latitude,
  'longitude': longitude,
});

// 查询位置
Logs.location.info('发送者查看位置', data: {
  'sender': senderOpenid,
  'receiver': receiverOpenid,
});

// 切换共享
Logs.location.info('切换位置共享', data: {
  'receiver': receiverOpenid,
  'is_sharing': true,
});
```

---

## 🎨 输出效果

### 开发环境（彩色输出）

```
10:30:15.123 ℹ️ INFO    [API] 发送请求: GET /api/users/me
10:30:15.456 ℹ️ INFO    [API] 用户登录成功
  数据: {openid: xxx, user_type: both}
10:30:16.789 🐛 DEBUG   [BINDING] 生成绑定码
  数据: {sender: xxx, bind_code: ABC12345}
10:30:17.012 ⚠️ WARNING [TASK] 绑定人数接近上限
  数据: {current: 4, max: 5}
10:30:18.345 ❌ ERROR  [API] 创建导航任务失败
  数据: {error: Network error}
Stack trace: ...
```

### 生产环境

```
自动使用 developer.log 记录到系统日志
```

---

## ⚙️ 高级配置

### 1. 修改最低日志级别

```dart
// 只在 main.dart 中设置一次
import 'package:qintu/utils/logger.dart';

void main() {
  if (kReleaseMode) {
    // 生产环境：只记录 info 及以上级别
    Logger.setMinLevel(LogLevel.info);
  } else {
    // 开发环境：记录所有级别
    Logger.setMinLevel(LogLevel.debug);
  }
  
  runApp(MyApp());
}
```

### 2. 自定义格式化器

```dart
Logger.setFormatter(({
  required timestamp,
  required level,
  required message,
  required tag,
  data,
  stackTrace,
}) {
  // JSON 格式（适合发送到日志服务）
  return jsonEncode({
    'timestamp': timestamp.toIso8601String(),
    'level': level.name,
    'tag': tag,
    'message': message,
    'data': data,
  });
});
```

### 3. 自定义输出器

```dart
Logger.setOutput(({
  required formattedMessage,
  required level,
  required tag,
}) {
  // 输出到文件
  _logFile.writeAsStringSync(
    '$formattedMessage\n',
    mode: FileMode.append,
  );
  
  // 或发送到远程日志服务
  if (level == LogLevel.error || level == LogLevel.critical) {
    _sendToRemoteLogService(formattedMessage);
  }
});
```

### 4. 启用文件日志

```dart
// 获取应用文档目录
final dir = await getApplicationDocumentsDirectory();
final logFile = '${dir.path}/qintu.log';

// 启用文件日志
await Logger.enableFileLog(logFile);
```

---

## 📊 预定义标签说明

| 标签 | 用途 | 示例 |
|------|------|------|
| `Logs.api` | API 调用 | 请求、响应、错误 |
| `Logs.auth` | 认证相关 | 登录、注册、Token |
| `Logs.binding` | 绑定关系 | 生成码、确认、解绑 |
| `Logs.task` | 导航任务 | 创建、接受、完成、取消 |
| `Logs.location` | 位置共享 | 上传、查询、切换共享 |
| `Logs.ui` | UI 交互 | 页面跳转、用户操作 |
| `Logs.database` | 数据库操作 | 查询、更新、错误 |
| `Logs.network` | 网络连接 | 连接状态、超时 |
| `Logs.storage` | 本地存储 | 读写、错误 |
| `Logs.app` | 应用生命周期 | 启动、后台、恢复 |

---

## 🔍 调试技巧

### 1. 在 DevTools 中查看

打开 Flutter DevTools → Timeline，可以看到所有日志事件：

```
Event: qintu.log
{
  "tag": "API",
  "level": "info",
  "message": "用户登录成功",
  "data": {...}
}
```

### 2. 过滤特定标签

```dart
// 只显示 API 相关的日志
// 在运行时设置最低级别为 warning，减少日志输出
Logger.setMinLevel(LogLevel.warning);
```

### 3. 错误日志附带堆栈

```dart
try {
  // 业务逻辑
} catch (e, stackTrace) {
  Logs.api.error(
    '操作失败',
    data: {'error': e.toString()},
    stackTrace: stackTrace,  // 附带堆栈信息
  );
}
```

---

## 📝 最佳实践

### ✅ 推荐

```dart
// 1. 使用预定义标签
Logs.api.info('发送请求');

// 2. 关键操作记录 info 级别
Logs.task.info('导航任务创建成功', data: {'task_id': taskId});

// 3. 错误记录 error 级别并附带堆栈
Logs.auth.error('登录失败', data: {'error': e}, stackTrace: stackTrace);

// 4. 敏感信息脱敏
Logs.auth.info('用户登录', data: {
  'phone': '+86 138****8000',  // 脱敏处理
});
```

### ❌ 避免

```dart
// 1. 不要在生产环境使用 debug 级别
Logs.api.debug('完整请求体: ${jsonEncode(largeData)}');  // 数据量大

// 2. 不要记录敏感信息
Logs.auth.info('登录', data: {
  'password': '123456',  // ❌ 不要记录密码
  'token': 'secret',     // ❌ 不要记录 Token
});

// 3. 不要过度记录日志
for (var item in list) {
  Logs.api.debug('处理项: $item');  // ❌ 循环中频繁输出
}
```

---

## 🚀 未来扩展

### 1. 集成远程日志服务

```dart
Logger.setOutput(({
  required formattedMessage,
  required level,
  required tag,
}) {
  // 本地输出
  print(formattedMessage);
  
  // 远程发送（仅 error/critical）
  if (level.value >= LogLevel.error.value) {
    _sendToCloudLogService(formattedMessage);
  }
});
```

### 2. 日志轮转

```dart
// 按日期轮转日志文件
final today = DateTime.now();
final logFile = 'logs/qintu-${today.year}-${today.month}-${today.day}.log';
```

### 3. 日志分析工具

```dart
// 解析日志文件
class LogAnalyzer {
  static List<LogEntry> parseLogFile(String content) {
    // 解析日志内容
    // 统计错误率
    // 生成报告
  }
}
```

---

**模块版本**：v1.0.0  
**更新日期**：2026-04-04
