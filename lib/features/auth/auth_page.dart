import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart';
import '../../services/secure_storage.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/logger.dart';
import '../../services/navigation_service.dart';
import '../../models/auth_result.dart';
import '../../utils/error_mapper.dart';
import '../../utils/exceptions.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_button.dart';
import 'widgets/phone_input_card.dart';
import 'widgets/code_input_card.dart';
import 'widgets/error_card.dart';

/// 是否启用模拟登录模式
/// 设置为 true 时，输入任意手机号即可直接登录（无需真实验证码）
/// 设置为 false 时，使用 CloudBase 真实短信验证码认证
const bool useMockAuth = false;

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

  // ==================== 颜色获取 ====================

  Color get _primaryColor => AppColors.primaryColor;
  Color get _backgroundColor => Theme.of(context).brightness == Brightness.dark
      ? AppColors.darkBackgroundColor
      : AppColors.backgroundColor;
  Color get _textColor => Theme.of(context).brightness == Brightness.dark
      ? AppColors.darkTextColor
      : AppColors.textColor;
  Color get _lightTextColor => Theme.of(context).brightness == Brightness.dark
      ? AppColors.darkLightTextColor
      : AppColors.lightTextColor;

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

      // 保存 Token 到本地
      await SecureStorage.saveTokens(
        accessToken: _authResult!.accessToken,
        refreshToken: _authResult!.refreshToken,
        accessTokenExpiresIn: _authResult!.accessTokenExpiresIn,
        refreshTokenExpiresIn: _authResult!.refreshTokenExpiresIn,
        phoneNumber: formattedPhone,
        userId: _authResult!.uid,
      );

      // 同步用户信息到 MySQL 数据库（确保后端有记录）
      try {
        final apiService = ApiService(
          baseUrl: Constants.baseUrl,
          openid: _authResult!.uid,
        );
        await apiService.syncUser(
          openid: _authResult!.uid,
          phone: formattedPhone,
        );
        Logs.auth.info('用户同步成功');
      } catch (e) {
        Logs.auth.warning('用户同步失败，将继续使用 CloudBase Auth', data: {'error': e.toString()});
      }

      if (mounted) {
        await NavigationService.goToRoleSelection(
          context,
          userId: _authResult!.uid,
          phone: _phoneController.text.trim(),
          accessToken: _authResult!.accessToken,
        );
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

  void _startCountdown() {
    setState(() => _countdown = 60);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() => _countdown--);

      return _countdown > 0;
    });
  }

  /// 模拟登录（开发模式）
  /// 输入任意手机号即可登录，无需真实验证码
  Future<void> _mockLogin() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      setState(() => _errorMessage = AppStrings.invalidPhoneNumber);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Logs.auth.info('🧪 模拟登录模式');

    try {
      // 模拟延迟
      await Future.delayed(const Duration(milliseconds: 800));

      // 生成模拟的认证结果
      final mockUid = 'mock_user_${phone.hashCode}';
      final mockAccessToken = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
      final mockRefreshToken = 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';

      // 保存 Token 到本地
      await SecureStorage.saveTokens(
        accessToken: mockAccessToken,
        refreshToken: mockRefreshToken,
        accessTokenExpiresIn: 86400, // 24 小时
        refreshTokenExpiresIn: 604800, // 7 天
        phoneNumber: '+86 $phone',
        userId: mockUid,
      );

      Logs.auth.info('🧪 模拟登录成功, uid: $mockUid');

      if (mounted) {
        await NavigationService.goToRoleSelection(
          context,
          userId: mockUid,
          phone: '+86 $phone',
          accessToken: mockAccessToken,
        );
      }
    } catch (e) {
      Logs.auth.warning('🧪 模拟登录失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '模拟登录失败: $e';
        });
      }
    }
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColor,
                  _primaryColor.withValues(alpha: 0.05),
                  _primaryColor.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    AuthHeader(
                      primaryColor: _primaryColor,
                      textColor: _textColor,
                      lightTextColor: _lightTextColor,
                    ),
                    const SizedBox(height: 60),
                    if (_step == 1) ...[
                      PhoneInputCard(
                        controller: _phoneController,
                        primaryColor: _primaryColor,
                        textColor: _textColor,
                        lightTextColor: _lightTextColor,
                      ),
                      const SizedBox(height: 32),
                      AuthButton(
                        text: AppStrings.getVerificationCode,
                        primaryColor: _primaryColor,
                        isLoading: _isLoading,
                        onPressed: _sendCode,
                      ),
                      // 模拟模式快捷按钮
                      if (useMockAuth) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading ? null : _mockLogin,
                          child: Text(
                            '🧪 模拟登录（开发模式）',
                            style: TextStyle(
                              color: _primaryColor.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                    if (_step == 2) ...[
                      CodeInputCard(
                        controller: _codeController,
                        phoneNumber: _phoneController.text,
                        primaryColor: _primaryColor,
                        textColor: _textColor,
                        lightTextColor: _lightTextColor,
                        countdown: _countdown,
                        onResend: _resendCode,
                      ),
                      const SizedBox(height: 24),
                      AuthButton(
                        text: AppStrings.login,
                        primaryColor: _primaryColor,
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
        ],
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