import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/user_state_manager.dart';
import '../../utils/logger.dart';

/// 应用状态管理器
///
/// 统一管理所有状态管理器
/// 提供便捷的访问方式
class AppProviders {
  /// 用户状态管理器
  static UserStateManager get userStateManager => UserStateManager();

  /// 获取所有 Provider 列表
  static List<ChangeNotifierProvider> get providers => [
        ChangeNotifierProvider<UserStateManager>(
          create: (_) => UserStateManager(),
        ),
        // 未来可以在这里添加更多 Provider
        // ChangeNotifierProvider<ThemeManager>(
        //   create: (_) => ThemeManager(),
        // ),
      ];
}

/// 便捷扩展方法
extension AppProvidersExtension on BuildContext {
  /// 获取用户状态管理器
  UserStateManager get userStateManager => read<UserStateManager>();

  /// 监听用户状态管理器
  UserStateManager watchUserStateManager() => watch<UserStateManager>();
}

/// 应用初始化器
///
/// 在应用启动时初始化所有状态管理器
class AppInitializer {
  static Future<void> initialize(BuildContext context) async {
    Logs.app.info('🚀 开始初始化应用状态...');
    
    try {
      // 初始化用户状态
      final userStateManager = context.read<UserStateManager>();
      await userStateManager.initialize();
      
      Logs.app.info('✅ 应用状态初始化完成');
    } catch (e, stackTrace) {
      Logs.app.error('❌ 应用状态初始化失败: $e\n$stackTrace');
      rethrow;
    }
  }
}
