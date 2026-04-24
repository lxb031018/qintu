import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/providers/auth_state_manager.dart';
import 'package:qintu/utils/exceptions.dart';
import 'package:qintu/utils/phone_utils.dart';
import '../core/auth_api.dart';
import '../service/auth_service.dart';

/// ============================================
/// 认证 Provider 层
///
/// Notifier，负责 UI 状态管理
/// ============================================

/// 登录步骤枚举
enum AuthStep {
  inputPhone,
  inputCode,
}

/// 登录页面状态
class AuthPageState {
  final AuthStep step;
  final int countdown;
  final bool isLoading;
  final String? errorMessage;
  final String phone;
  final String? verificationId;

  const AuthPageState({
    this.step = AuthStep.inputPhone,
    this.countdown = 0,
    this.isLoading = false,
    this.errorMessage,
    this.phone = '',
    this.verificationId,
  });

  AuthPageState copyWith({
    AuthStep? step,
    int? countdown,
    bool? isLoading,
    String? errorMessage,
    String? phone,
    String? verificationId,
  }) {
    return AuthPageState(
      step: step ?? this.step,
      countdown: countdown ?? this.countdown,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      phone: phone ?? this.phone,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}

/// 登录 Notifier
class AuthNotifier extends Notifier<AuthPageState> {
  @override
  AuthPageState build() {
    return const AuthPageState();
  }

  /// 发送验证码
  Future<void> sendCode(String phone) async {
    if (phone.length != 11) {
      state = state.copyWith(errorMessage: '请输入11位手机号');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final formattedPhone = PhoneUtils.formatForApi(phone);
      final verificationId = await AuthApi.sendVerificationCode(formattedPhone);
      state = state.copyWith(
        step: AuthStep.inputCode,
        isLoading: false,
        phone: phone,
        verificationId: verificationId,
      );
      _startCountdown();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
    }
  }

  /// 验证并登录
  Future<void> verifyAndLogin(String code) async {
    if (code.length != 6) {
      state = state.copyWith(errorMessage: '请输入6位验证码');
      return;
    }

    if (state.verificationId == null) {
      state = state.copyWith(errorMessage: '请先获取验证码');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final verificationToken = await AuthApi.verifyCode(
        state.verificationId!,
        code,
      );

      final formattedPhone = PhoneUtils.formatForApi(state.phone);
      final authResult = await AuthService.signInOrSignUp(
        verificationToken: verificationToken,
        phone: formattedPhone,
      );

      await AuthService.saveAuthResult(authResult, formattedPhone);

      await ref.read(authStateProvider.notifier).setAuthenticated(
        userId: authResult.uid,
        accessToken: authResult.accessToken,
        refreshToken: authResult.refreshToken,
        accessTokenExpiresIn: authResult.accessTokenExpiresIn,
        refreshTokenExpiresIn: authResult.refreshTokenExpiresIn,
        phoneNumber: formattedPhone,
        pendingBindingCount: authResult.pendingCount,
      );

      state = const AuthPageState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
    }
  }

  void resendCode() {
    state = state.copyWith(
      step: AuthStep.inputPhone,
      verificationId: null,
    );
  }

  void changePhone() {
    state = state.copyWith(
      step: AuthStep.inputPhone,
      countdown: 0,
      verificationId: null,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetToInputPhone() {
    state = const AuthPageState();
  }

  void _startCountdown() {
    state = state.copyWith(countdown: 60);
    _countdownTimer();
  }

  void _countdownTimer() async {
    while (state.countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (state.countdown <= 0) break;
      state = state.copyWith(countdown: state.countdown - 1);
    }
  }

  String _parseError(dynamic e) {
    if (e is AppException) {
      return e.message;
    }
    return e.toString();
  }
}

/// Provider 导出
final authProvider = NotifierProvider<AuthNotifier, AuthPageState>(
  AuthNotifier.new,
);