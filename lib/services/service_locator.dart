import 'package:get_it/get_it.dart';
import '../state/managers/user_state_manager.dart';
import 'api_client.dart';

/// 服务定位器
///
/// 使用 get_it 实现依赖注入
/// 统一管理所有服务实例
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  /// 注册所有服务
  static void registerServices() {
    // 注册 API 客户端（单例）
    if (!_getIt.isRegistered<ApiClient>()) {
      _getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(),
      );
    }

    // 注册用户状态管理器（工厂模式，每次创建新实例）
    if (!_getIt.isRegistered<UserStateManager>()) {
      _getIt.registerFactory<UserStateManager>(
        () => UserStateManager(),
      );
    }

    // 未来可以在这里注册更多服务
    // 例如：
    // _getIt.registerLazySingleton<AuthService>(() => AuthService());
    // _getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  }

  /// 重置所有服务（用于测试或注销）
  static void reset() {
    _getIt.reset();
  }

  /// 获取 GetIt 实例
  static GetIt get instance => _getIt;

  /// 便捷方法：获取服务
  static T call<T extends Object>() => _getIt<T>();
}

/// 扩展方法，方便使用
extension ServiceLocatorExtension on Object {
  /// 获取服务实例
  T service<T extends Object>() => ServiceLocator.call<T>();
}
