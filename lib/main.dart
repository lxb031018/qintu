import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'constants/app_strings.dart';
import 'providers/user_provider.dart';
import 'providers/binding_provider.dart';
import 'state/managers/user_state_manager.dart';
import 'utils/logger.dart';
import 'managers/theme_manager.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载环境变量 (.env)
  try {
    await dotenv.load(fileName: ".env");
    Logs.app.info('✅ 环境变量加载成功: ${dotenv.env['CLOUDBASE_ENV_ID']}');
  } catch (e) {
    Logs.app.warning('⚠️ 环境变量加载失败: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeManager _themeManager = ThemeManager.instance;
  late final UserStateManager _userStateManager;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _userStateManager = UserStateManager();
    _router = AppRouter.getRouter();
    _initializeAppState();
  }

  Future<void> _initializeAppState() async {
    // 初始化主题
    await _themeManager.init();
    
    // 初始化用户状态
    await _userStateManager.initialize();
    
    // 初始化完成后，刷新路由以触发 redirect
    if (mounted) {
      setState(() {});
      // 刷新 go_router 以触发路由守卫
      _router.refresh();
      Logs.app.info('✅ 路由刷新完成，将自动跳转到对应页面');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BindingProvider()),
        ChangeNotifierProvider.value(value: _userStateManager),
        // TODO: 添加其他 Provider
        // ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: AnimatedBuilder(
        animation: _themeManager,
        builder: (context, child) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeManager.themeMode,
            // 禁用主题切换动画，实现瞬间切换
            themeAnimationDuration: Duration.zero,
            themeAnimationCurve: Curves.linear,
            routerConfig: _router,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _userStateManager.dispose();
    super.dispose();
  }
}
