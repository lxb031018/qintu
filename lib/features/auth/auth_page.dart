import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'provider/auth_provider.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_button.dart';
import 'widgets/phone_input_card.dart';
import 'widgets/code_input_card.dart';
import 'widgets/error_card.dart';

/// ============================================
/// 认证页面（登录/注册）
///
/// 使用 Provider 层管理状态，遵循四层架构
/// ============================================

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = AppColors.primaryColor;
    final authState = ref.watch(authProvider);

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
                    onPressed: () {
                      ref.read(authProvider.notifier).sendCode(
                        _phoneController.text.trim(),
                      );
                    },
                  ),
                ],
                if (authState.step == AuthStep.inputCode) ...[
                  CodeInputCard(
                    controller: _codeController,
                    phoneNumber: _phoneController.text,
                    primaryColor: primaryColor,
                    textColor: theme.textTheme.bodyLarge!.color!,
                    lightTextColor: theme.textTheme.bodyMedium!.color!,
                    countdown: authState.countdown,
                    onResend: () {
                      ref.read(authProvider.notifier).resendCode();
                    },
                    onChangePhone: () {
                      ref.read(authProvider.notifier).changePhone();
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    text: AppStrings.login,
                    primaryColor: primaryColor,
                    isLoading: authState.isLoading,
                    onPressed: () {
                      ref.read(authProvider.notifier).verifyAndLogin(
                        _codeController.text.trim(),
                      );
                    },
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
