import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/api_endpoints.dart';
import '../../constants/app_durations.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../utils/logger.dart';
import '../../providers/auth_state_manager.dart';
import '../../router/app_router.dart';
import '../../models/auth_result.dart';
import '../../utils/error_mapper.dart';
import '../../utils/exceptions.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_button.dart';
import 'widgets/phone_input_card.dart';
import 'widgets/code_input_card.dart';
import 'widgets/error_card.dart';

/// ============================================
/// 认证页面（登录/注册）
///
/// 智能判断用户状态：
/// - 新用户：自动注册
/// - 老用户：直接登录
///
/// 设计风格：珊瑚橙主题，大字体，适合老年人
/// ============================================

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // ==================== 状态变量 ====================

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  int _step = 1;
  String? _verificationId;
  AuthResult? _authResult;

  bool _isLoading = false;
  String? _errorMessage;
  int _countdown = 0;

  // ==================== 核心方法 ====================

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      setState(() => _errorMessage = AppStrings.invalidPhoneNumber);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formattedPhone = '+86 $phone';
      _verificationId = await CloudBaseAuthService.sendVerificationCode(formattedPhone);

      setState(() {
        _step = 2;
        _isLoading = false;
      });

      _startCountdown();
    } catch (e) {
      setState(() {
        _isLoading = false;
        // 根据异常类型显示对应错误信息
        if (e is AppException) {
          _errorMessage = e.message;
        } else {
          _errorMessage = ErrorMapper.parse(e.toString());
        }
      });
    }
  }

  Future<void> _verifyAndLogin() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = AppStrings.invalidVerificationCode);
      return;
    }

    if (_verificationId == null) {
      setState(() => _errorMessage = AppStrings.pleaseGetCodeFirst);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final verificationToken = await CloudBaseAuthService.verifyCode(
        _verificationId!,
        code,
      );

      final formattedPhone = '+86 ${_phoneController.text.trim()}';

      _authResult = await CloudBaseAuthService.signInOrSignUp(
        verificationToken: verificationToken,
        phoneNumber: formattedPhone,
      );

      // 使用 AuthStateManager 统一设置认证状态
      if (mounted) {
        final authStateManager = context.read<AuthStateManager>();
        await authStateManager.setAuthenticated(
          userId: _authResult!.uid,
          accessToken: _authResult!.accessToken,
          refreshToken: _authResult!.refreshToken,
          accessTokenExpiresIn: _authResult!.accessTokenExpiresIn,
          refreshTokenExpiresIn: _authResult!.refreshTokenExpiresIn,
          phoneNumber: formattedPhone,
          pendingBindingCount: _authResult!.pendingCount,
        );

        // 同步用户信息到 MySQL 数据库（确保后端有记录）
        try {
          final apiClient = ApiClient();
          await apiClient.post(
            ApiEndpoints.syncUser,
            data: {'openid': _authResult!.uid, 'phone': formattedPhone},
          );
          Logs.auth.info('用户同步成功');
        } catch (e) {
          Logs.auth.warning('用户同步失败，将继续使用 CloudBase Auth', data: {'error': e.toString()});
        }

        // 使用 go_router 跳转到统一主页（所有用户登录后进入此页面）
        if (mounted) {
          context.goToUnifiedHome();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        // 根据异常类型显示对应错误信息
        if (e is AppException) {
          _errorMessage = e.message;
        } else {
          _errorMessage = ErrorMapper.parse(e.toString());
        }
      });
    }
  }

  void _resendCode() {
    setState(() {
      _step = 1;
      _codeController.clear();
      _verificationId = null;
    });
  }

  /// 修改手机号（返回第一步）
  void _changePhone() {
    setState(() {
      _step = 1;
      _codeController.clear();
      _verificationId = null;
      _countdown = 0;
    });
  }

  void _startCountdown() {
    setState(() => _countdown = 60);

    Future.doWhile(() async {
      await Future.delayed(AppDurations.splashMinDuration);
      if (!mounted) return false;

      setState(() => _countdown--);

      return _countdown > 0;
    });
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = AppColors.primaryColor; // 使用主色调（珊瑚橙）

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                AuthHeader(
                  textColor: theme.textTheme.bodyLarge!.color!,
                  lightTextColor: theme.textTheme.bodyMedium!.color!,
                ),
                const SizedBox(height: 60),
                if (_step == 1) ...[
                  PhoneInputCard(
                    controller: _phoneController,
                    primaryColor: primaryColor,
                    textColor: theme.textTheme.bodyLarge!.color!,
                    lightTextColor: theme.textTheme.bodyMedium!.color!,
                  ),
                  const SizedBox(height: 32),
                  AuthButton(
                    text: AppStrings.getVerificationCode,
                    primaryColor: primaryColor,
                    isLoading: _isLoading,
                    onPressed: _sendCode,
                  ),
                ],
                if (_step == 2) ...[
                  CodeInputCard(
                    controller: _codeController,
                    phoneNumber: _phoneController.text,
                    primaryColor: primaryColor,
                    textColor: theme.textTheme.bodyLarge!.color!,
                    lightTextColor: theme.textTheme.bodyMedium!.color!,
                    countdown: _countdown,
                    onResend: _resendCode,
                    onChangePhone: _changePhone,
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    text: AppStrings.login,
                    primaryColor: primaryColor,
                    isLoading: _isLoading,
                    onPressed: _verifyAndLogin,
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  ErrorCard(message: _errorMessage!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}

// ==================== Widget Preview ====================

/// 预览：认证页面（浅色主题）
@Preview(name: 'AuthPage - Light')
Widget authPageLightPreview() {
  return const MaterialApp(
    home: AuthPage(),
  );
}

/// 预览：认证页面（深色主题）
@Preview(name: 'AuthPage - Dark')
Widget authPageDarkPreview() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const AuthPage(),
  );
}