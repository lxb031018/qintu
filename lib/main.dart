import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'constants/app_strings.dart';
import 'providers/auth_state_manager.dart';
import 'providers/theme_manager.dart';
import 'providers/settings_manager.dart';
import 'config/environments/environment_manager.dart';
import 'utils/logger.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'widgets/error_boundary.dart';

export 'providers/auth_state_manager.dart' show authStateProvider;
export 'providers/binding_provider.dart' show bindingProvider;
export 'providers/settings_manager.dart' show settingsManagerProvider;
export 'providers/theme_manager.dart' show themeManagerProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 固定全局竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 加载环境变量 (.env)
  try {
    await dotenv.load(fileName: ".env");
    Logs.app.info('✅ 环境变量加载成功: ${dotenv.env['CLOUDBASE_ENV_ID']}');
  } catch (e) {
    Logs.app.warning('⚠️ 环境变量加载失败: $e');
  }

  // 初始化环境管理器（必须在 dotenv 加载后调用）
  EnvironmentManager.initialize();
  EnvironmentManager.printEnvironmentInfo();

  // 高德地图隐私合规已在 Android 原生端 (AmapMapPlugin.kt) 初始化

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.getRouter();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAppState();
      });
    }
  }

  Future<void> _initializeAppState() async {
    // 触发 providers 的初始化（在 build 之后）
    ref.read(settingsManagerProvider);

    // 初始化认证状态
    await ref.read(authStateProvider.notifier).initialize();

    if (mounted) {
      // 刷新 go_router 以触发路由守卫
      _router.refresh();
      Logs.app.info('✅ 路由刷新完成，将自动跳转到对应页面');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeManagerProvider);

    return ErrorBoundary(
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildLightTheme(),
            darkTheme: AppTheme.buildDarkTheme(),
            themeMode: themeMode,
            // 禁用主题切换动画，实现瞬间切换
            themeAnimationDuration: Duration.zero,
            themeAnimationCurve: Curves.linear,
            routerConfig: _router,
            builder: (context, child) {
              // 全局错误处理
              ErrorWidget.builder = (FlutterErrorDetails details) {
                return SafeErrorWidget(details: details);
              };
              return child!;
            },
          );
        },
      ),
    );
  }
}
