/// Repository 层
///
/// 职责：
/// - 封装数据源访问（远程 API、本地存储）
/// - 统一错误处理和日志记录
/// - 为 Provider/UseCase 提供清晰的数据访问接口
/// - 解耦 Presentation 层和 Data 层

export 'repository_manager.dart';
export 'repositories/auth_repository.dart';
export 'repositories/user_repository.dart';
export 'repositories/binding_repository.dart';
export 'repositories/task_repository.dart';
export 'repositories/location_repository.dart';
