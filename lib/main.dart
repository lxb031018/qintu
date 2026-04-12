import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart' show AMapPrivacyStatement;
import 'constants/app_strings.dart';
import 'providers/binding_provider.dart';
import 'providers/auth_state_manager.dart';
import 'providers/theme_manager.dart';
import 'providers/settings_manager.dart';
import 'config/environments/environment_manager.dart';
import 'utils/logger.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'widgets/error_boundary.dart';

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

  // 初始化高德地图隐私合规（必须在 runApp 之前或任何地图操作之前调用）
  _initAmapPrivacy();

  runApp(const MyApp());
}

/// 初始化高德地图隐私合规
void _initAmapPrivacy() {
  try {
    const privacyStatement = AMapPrivacyStatement(
      hasShow: true,
      hasAgree: true,
    );

    // 设置隐私合规（必须在任何地图操作之前调用）
    AMapInitializer.updatePrivacyAgree(privacyStatement);

    Logs.map.info('✅ 高德地图隐私合规设置成功');
  } catch (e, stackTrace) {
    Logs.map.warning('高德地图隐私合规初始化失败: $e');
    Logs.map.warning('堆栈: $stackTrace');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeManager _themeManager;
  late final AuthStateManager _authStateManager;
  late final SettingsManager _settingsManager;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager();
    _authStateManager = AuthStateManager();
    _settingsManager = SettingsManager();
    _router = AppRouter.getRouter();
    _initializeAppState();
  }

  Future<void> _initializeAppState() async {
    // 初始化设置（字体大小等）
    await _settingsManager.init();
    AppTextStyles.setFontSizeScale(_settingsManager.fontSizeScale);

    // 初始化主题
    await _themeManager.init();

    // 初始化认证状态
    await _authStateManager.initialize();

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
        ChangeNotifierProvider(create: (_) => BindingProvider()),
        ChangeNotifierProvider.value(value: _authStateManager),
        ChangeNotifierProvider.value(value: _themeManager),
        ChangeNotifierProvider.value(value: _settingsManager),
      ],
      child: ErrorBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_themeManager, _settingsManager]),
          builder: (context, child) {
            // 同步字体缩放到 AppTheme 和 AppTextStyles
            AppTheme.setFontSizeScale(_settingsManager.fontSizeScale);

            return MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.buildLightTheme(),
              darkTheme: AppTheme.buildDarkTheme(),
              themeMode: _themeManager.themeMode,
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
      ),
    );
  }

  @override
  void dispose() {
    _authStateManager.dispose();
    super.dispose();
  }
}
