import '../../services/api_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/binding_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/location_repository.dart';

/// 仓库管理器
///
/// 职责：
/// - 统一管理所有 Repository 实例
/// - 提供便捷的访问入口
/// - 作为 Data 层的统一出口
class RepositoryManager {
  /// 认证仓库
  final AuthRepository auth;

  /// 用户仓库
  final UserRepository user;

  /// 绑定仓库
  final BindingRepository binding;

  /// 任务仓库
  final TaskRepository task;

  /// 位置仓库
  final LocationRepository location;

  /// 私有构造函数
  RepositoryManager._({
    required this.auth,
    required this.user,
    required this.binding,
    required this.task,
    required this.location,
  });

  /// 工厂方法：创建 RepositoryManager 实例
  factory RepositoryManager(ApiService apiService) {
    return RepositoryManager._(
      auth: AuthRepository(),
      user: UserRepository(),
      binding: BindingRepository(),
      task: TaskRepository(),
      location: LocationRepository(),
    );
  }
}
