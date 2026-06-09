import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/auth/user_state.dart';
import '../../providers/auth_state_manager.dart';
import 'provider/auth_provider.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_button.dart';
import 'widgets/phone_input_card.dart';
import 'widgets/code_input_card.dart';
import 'widgets/error_card.dart';
import 'widgets/agreement_checkbox.dart';

/// ============================================
/// 认证页面（登录/注册）
///
/// 使用 Riverpod Notifier 管理状态，遵循四层架构
/// ============================================

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor;
    final authNotifier = ref.watch(authProvider.notifier);
    final authState = ref.watch(authProvider);

    // Check if already logged in
    final authStateNotifier = ref.watch(authStateProvider);
    if (authStateNotifier.authStatus == AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

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
                if (authState.step == AuthStep.inputPhone) ...[
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
                    isLoading: authState.isLoading,
                    disabled: !_agreed,
                    onPressed: () {
                      authNotifier.sendCode(_phoneController.text);
                    },
                  ),
                  const SizedBox(height: 16),
                  AgreementCheckbox(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    isDark: isDark,
                  ),
                ],
                if (authState.step == AuthStep.inputCode) ...[
                  CodeInputCard(
                    controller: _codeController,
                    phoneNumber: authState.phone,
                    primaryColor: primaryColor,
                    textColor: theme.textTheme.bodyLarge!.color!,
                    lightTextColor: theme.textTheme.bodyMedium!.color!,
                    countdown: authState.countdown,
                    onResend: authNotifier.resendCode,
                    onChangePhone: authNotifier.changePhone,
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    text: AppStrings.login,
                    primaryColor: primaryColor,
                    isLoading: authState.isLoading,
                    disabled: !_agreed,
                    onPressed: () {
                      authNotifier.verifyAndLogin(_codeController.text);
                    },
                  ),
                  const SizedBox(height: 16),
                  AgreementCheckbox(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    isDark: isDark,
                  ),
                ],
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  ErrorCard(message: authState.errorMessage!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
