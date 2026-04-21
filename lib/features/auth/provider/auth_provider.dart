import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/providers/auth_state_manager.dart';
import 'package:qintu/core/http/api_client.dart';
import 'package:qintu/constants/api_endpoints.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/utils/exceptions.dart';
import 'package:qintu/utils/phone_utils.dart';
import '../api/auth_api.dart';
import '../service/auth_service.dart';

/// ============================================
/// 认证 Provider 层
///
/// 持有 UI 状态，通过 notifyListeners() 驱动 UI 更新
/// ============================================

/// 登录步骤枚举
enum AuthStep {
  inputPhone,   // 第1步：输入手机号
  inputCode,     // 第2步：输入验证码
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
      // 验证验证码
      final verificationToken = await AuthApi.verifyCode(
        state.verificationId!,
        code,
      );

      // 智能登录/注册
      final formattedPhone = PhoneUtils.formatForApi(state.phone);
      final authResult = await AuthService.signInOrSignUp(
        verificationToken: verificationToken,
        phone: formattedPhone,
      );

      // 保存认证信息
      await AuthService.saveAuthResult(authResult, formattedPhone);

      // 设置全局认证状态
      final authStateNotifier = ref.read(authStateProvider.notifier);
      await authStateNotifier.setAuthenticated(
        userId: authResult.uid,
        accessToken: authResult.accessToken,
        refreshToken: authResult.refreshToken,
        accessTokenExpiresIn: authResult.accessTokenExpiresIn,
        refreshTokenExpiresIn: authResult.refreshTokenExpiresIn,
        phoneNumber: formattedPhone,
        pendingBindingCount: authResult.pendingCount,
      );

      // 同步用户到后端
      await _syncUser(authResult.uid, formattedPhone);

      // 登录成功，重置 authProvider 状态为初始状态
      // 这样下次进入登录页面时是干净的
      state = const AuthPageState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
    }
  }

  /// 重新发送验证码（返回第一步）
  void resendCode() {
    state = state.copyWith(
      step: AuthStep.inputPhone,
      verificationId: null,
    );
  }

  /// 修改手机号（返回第一步）
  void changePhone() {
    state = state.copyWith(
      step: AuthStep.inputPhone,
      countdown: 0,
      verificationId: null,
    );
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 重置到输入手机号状态（退出登录后调用）
  void resetToInputPhone() {
    state = const AuthPageState();
  }

  /// 同步用户到 MySQL
  Future<void> _syncUser(String uid, String phone) async {
    try {
      final apiClient = ApiClient();
      await apiClient.post(
        ApiEndpoints.syncUser,
        data: {'openid': uid, 'phone': phone},
      );
      Logs.auth.info('用户同步成功');
    } catch (e) {
      Logs.auth.warning('用户同步失败，将继续使用', data: {'error': e.toString()});
    }
  }

  /// 启动倒计时
  void _startCountdown() {
    state = state.copyWith(countdown: 60);
    _countdownTimer();
  }

  Future<void> _countdownTimer() async {
    while (state.countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (state.countdown <= 0) break;
      state = state.copyWith(countdown: state.countdown - 1);
    }
  }

  /// 解析错误信息
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
