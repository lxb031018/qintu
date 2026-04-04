import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/managers/user_state_manager.dart';
import '../../constants/app_colors.dart';
import '../../utils/logger.dart';

/// 应用初始化器
///
/// 在应用启动时初始化用户状态
/// 包裹在 MaterialApp 外部，确保在路由系统之前初始化
class AppInitializerWidget extends StatefulWidget {
  final Widget child;

  const AppInitializerWidget({
    super.key,
    required this.child,
  });

  @override
  State<AppInitializerWidget> createState() => _AppInitializerWidgetState();
}

class _AppInitializerWidgetState extends State<AppInitializerWidget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    Logs.ui.info('========== AppInitializerWidget initState ==========');
    _initialize();
  }

  Future<void> _initialize() async {
    Logs.ui.info('AppInitializerWidget._initialize() 开始执行...');
    try {
      // 初始化用户状态
      Logs.ui.info('正在获取 UserStateManager...');
      final userStateManager = context.read<UserStateManager>();
      Logs.ui.info('UserStateManager 已获取，开始初始化...');
      await userStateManager.initialize();
      Logs.ui.info('UserStateManager 初始化完成');

      if (mounted) {
        Logs.ui.info('设置 _isInitialized = true，即将显示主应用...');
        setState(() {
          _isInitialized = true;
        });
      } else {
        Logs.ui.info('警告: Widget 已 unmounted，无法更新状态');
      }
    } catch (e) {
      Logs.ui.info('❌ 初始化异常: $e');
      // 初始化失败，设置为未登录状态
      if (mounted) {
        Logs.ui.info('设置 _isInitialized = true（异常路径）...');
        setState(() {
          _isInitialized = true;
        });
      }
    }
    Logs.ui.info('========== AppInitializerWidget._initialize() 执行完毕 ==========');
  }

  @override
  Widget build(BuildContext context) {
    Logs.ui.info('AppInitializerWidget.build() 被调用, _isInitialized = $_isInitialized');
    if (!_isInitialized) {
      // 初始化期间显示简单的加载提示
      Logs.ui.info('显示加载中页面...');
      return MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
                const SizedBox(height: 24),
                Text(
                  '加载中...',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Logs.ui.info('返回子 Widget (MaterialApp.router)...');
    return widget.child;
  }
}
