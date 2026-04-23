import '../../utils/phone_utils.dart';

/// 登录信息模型
///
/// 强类型封装用户登录后的完整信息
/// 替代原来的 `Map<String, dynamic>` 返回方式
/// 
/// 注意：已删除 userRole 字段，所有用户使用统一主页
class LoginInfo {
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? phoneNumber;
  final String? userId;
  final DateTime? accessTokenSaveTime;
  final DateTime? refreshTokenSaveTime;

  const LoginInfo({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.phoneNumber,
    this.userId,
    this.accessTokenSaveTime,
    this.refreshTokenSaveTime,
  });

  /// 从存储数据创建
  factory LoginInfo.fromStorage({
    required String accessToken,
    String? refreshToken,
    int? expiresIn,
    String? phoneNumber,
    String? userId,
    int? accessTokenSaveTime,
    int? refreshTokenSaveTime,
  }) {
    return LoginInfo(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      phoneNumber: phoneNumber,
      userId: userId,
      accessTokenSaveTime: accessTokenSaveTime != null
          ? DateTime.fromMillisecondsSinceEpoch(accessTokenSaveTime)
          : null,
      refreshTokenSaveTime: refreshTokenSaveTime != null
          ? DateTime.fromMillisecondsSinceEpoch(refreshTokenSaveTime)
          : null,
    );
  }

  /// 是否有效（accessToken 存在）
  bool get isValid => accessToken.isNotEmpty;

  /// 转换为 Map（兼容旧代码）
  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'phone_number': phoneNumber,
      'user_id': userId,
      'access_token_save_time': accessTokenSaveTime?.millisecondsSinceEpoch,
      'refresh_token_save_time': refreshTokenSaveTime?.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'LoginInfo(userId: $userId, phone: ${PhoneUtils.maskPhone(phoneNumber ?? '')})';
  }
}
