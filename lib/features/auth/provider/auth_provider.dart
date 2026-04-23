import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qintu/providers/auth_state_manager.dart';
import 'package:qintu/utils/exceptions.dart';
import 'package:qintu/utils/phone_utils.dart';
import '../core/auth_api.dart';
import '../service/auth_service.dart';

/// ============================================
/// 认证 Provider 层
///
/// 持有 UI 状态，通过 notifyListeners() 驱动 UI 更新
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

/// 登录 Provider
class AuthNotifier extends ChangeNotifier {
  AuthPageState _state = const AuthPageState();
  AuthPageState get state => _state;

  /// 发送验证码
  Future<void> sendCode(String phone) async {
    if (phone.length != 11) {
      _state = _state.copyWith(errorMessage: '请输入11位手机号');
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final formattedPhone = PhoneUtils.formatForApi(phone);
      final verificationId = await AuthApi.sendVerificationCode(formattedPhone);
      _state = _state.copyWith(
        step: AuthStep.inputCode,
        isLoading: false,
        phone: phone,
        verificationId: verificationId,
      );
      notifyListeners();
      _startCountdown();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
      notifyListeners();
    }
  }

  /// 验证并登录
  Future<void> verifyAndLogin(String code, BuildContext context) async {
    if (code.length != 6) {
      _state = _state.copyWith(errorMessage: '请输入6位验证码');
      notifyListeners();
      return;
    }

    if (_state.verificationId == null) {
      _state = _state.copyWith(errorMessage: '请先获取验证码');
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final verificationToken = await AuthApi.verifyCode(
        _state.verificationId!,
        code,
      );

      final formattedPhone = PhoneUtils.formatForApi(_state.phone);
      final authResult = await AuthService.signInOrSignUp(
        verificationToken: verificationToken,
        phone: formattedPhone,
      );

      await AuthService.saveAuthResult(authResult, formattedPhone);

      await context.read<AuthStateNotifier>().setAuthenticated(
        userId: authResult.uid,
        accessToken: authResult.accessToken,
        refreshToken: authResult.refreshToken,
        accessTokenExpiresIn: authResult.accessTokenExpiresIn,
        refreshTokenExpiresIn: authResult.refreshTokenExpiresIn,
        phoneNumber: formattedPhone,
        pendingBindingCount: authResult.pendingCount,
      );

      _state = const AuthPageState();
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
      notifyListeners();
    }
  }

  void resendCode() {
    _state = _state.copyWith(
      step: AuthStep.inputPhone,
      verificationId: null,
    );
    notifyListeners();
  }

  void changePhone() {
    _state = _state.copyWith(
      step: AuthStep.inputPhone,
      countdown: 0,
      verificationId: null,
    );
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  void resetToInputPhone() {
    _state = const AuthPageState();
    notifyListeners();
  }

  void _startCountdown() {
    _state = _state.copyWith(countdown: 60);
    notifyListeners();
    _countdownTimer();
  }

  Future<void> _countdownTimer() async {
    while (_state.countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (_state.countdown <= 0) break;
      _state = _state.copyWith(countdown: _state.countdown - 1);
      notifyListeners();
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
final authProvider = ChangeNotifierProvider<AuthNotifier>(
  create: (_) => AuthNotifier(),
);
