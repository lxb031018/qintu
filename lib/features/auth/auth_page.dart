import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

/// ============================================
/// 认证页面（登录/注册）
///
/// 使用 Provider 层管理状态，遵循四层架构
/// ============================================

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = AppColors.primaryColor;

    return Consumer<AuthNotifier>(
      builder: (context, authState, _) {
        final authNotifier = context.read<AuthStateNotifier>();

        // Check if already logged in
        if (authNotifier.state.authStatus == AuthStatus.authenticated) {
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
                    if (authState.state.step == AuthStep.inputPhone) ...[
                      PhoneInputCard(
                        controller: TextEditingController(),
                        primaryColor: primaryColor,
                        textColor: theme.textTheme.bodyLarge!.color!,
                        lightTextColor: theme.textTheme.bodyMedium!.color!,
                      ),
                      const SizedBox(height: 32),
                      AuthButton(
                        text: AppStrings.getVerificationCode,
                        primaryColor: primaryColor,
                        isLoading: authState.state.isLoading,
                        onPressed: () {
                          authState.sendCode('13800138000'); // TODO: get from controller
                        },
                      ),
                    ],
                    if (authState.state.step == AuthStep.inputCode) ...[
                      CodeInputCard(
                        controller: TextEditingController(),
                        phoneNumber: authState.state.phone,
                        primaryColor: primaryColor,
                        textColor: theme.textTheme.bodyLarge!.color!,
                        lightTextColor: theme.textTheme.bodyMedium!.color!,
                        countdown: authState.state.countdown,
                        onResend: authState.resendCode,
                        onChangePhone: authState.changePhone,
                      ),
                      const SizedBox(height: 24),
                      AuthButton(
                        text: AppStrings.login,
                        primaryColor: primaryColor,
                        isLoading: authState.state.isLoading,
                        onPressed: () {
                          authState.verifyAndLogin('123456', context); // TODO: get from controller
                        },
                      ),
                    ],
                    if (authState.state.errorMessage != null) ...[
                      const SizedBox(height: 24),
                      ErrorCard(message: authState.state.errorMessage!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
