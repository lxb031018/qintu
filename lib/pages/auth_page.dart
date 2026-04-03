import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import '../models/auth_result.dart';
import '../models/user_info.dart';
import 'role_selection_page.dart';

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
  // ==================== 颜色主题 ====================

  // 珊瑚橙主题
  static const Color primaryColor = Color(0xFFFF8C69); // 珊瑚橙
  static const Color backgroundColor = Color(0xFFFFF8F0); // 奶油白
  static const Color textColor = Color(0xFF4A5568); // 深灰蓝
  static const Color lightTextColor = Color(0xFF718096);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF48BB78);

  // ==================== 状态变量 ====================

  /// 手机号输入控制器
  final TextEditingController _phoneController = TextEditingController();

  /// 验证码输入控制器
  final TextEditingController _codeController = TextEditingController();

  /// 当前步骤：1=输入手机号，2=输入验证码，3=登录成功
  int _step = 1;

  /// verification_id（发送验证码后保存）
  String? _verificationId;

  /// 登录结果
  AuthResult? _authResult;

  /// 用户信息
  UserInfo? _userInfo;

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _errorMessage;

  /// 倒计时（秒）
  int _countdown = 0;

  // ==================== 核心方法 ====================

  /// 发送验证码
  Future<void> _sendCode() async {
    // 验证手机号格式
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      setState(() => _errorMessage = '请输入正确的 11 位手机号');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 格式化手机号：+86 13800138000（注意空格）
      final formattedPhone = '+86 $phone';

      // 调用发送验证码 API
      _verificationId = await CloudBaseAuthService.sendVerificationCode(formattedPhone);

      // 进入第 2 步
      setState(() {
        _step = 2;
        _isLoading = false;
      });

      // 开始倒计时
      _startCountdown();

    } catch (e) {
      // 提取用户友好的错误信息
      String errorMessage = _parseErrorMessage(e.toString());

      setState(() {
        _isLoading = false;
        _errorMessage = errorMessage;
      });
    }
  }

  /// 验证并登录/注册
  Future<void> _verifyAndLogin() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = '请输入 6 位验证码');
      return;
    }

    if (_verificationId == null) {
      setState(() => _errorMessage = '请先获取验证码');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 第 2 步：验证验证码
      final verificationToken = await CloudBaseAuthService.verifyCode(
        _verificationId!,
        code,
      );

      // 格式化手机号（+86 手机号）
      final formattedPhone = '+86 ${_phoneController.text.trim()}';

      // 第 3 步：智能登录/注册（自动判断新用户还是老用户）
      _authResult = await CloudBaseAuthService.signInOrSignUp(
        verificationToken: verificationToken,
        phoneNumber: formattedPhone,
      );

      // ✅ 保存登录信息到本地存储
      await TokenStorage.saveTokens(
        accessToken: _authResult!.accessToken,
        refreshToken: _authResult!.refreshToken,
        expiresIn: _authResult!.expiresIn,
        phoneNumber: formattedPhone,
      );

      // 第 4 步：获取用户信息（暂时跳过）
      // _userInfo = await CloudBaseAuthService.getUserInfo(_authResult!.accessToken);

      // 构造基本用户信息
      _userInfo = UserInfo(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}', // 临时ID
        phoneNumber: formattedPhone,
        createTime: DateTime.now().toIso8601String(),
        lastLoginTime: DateTime.now().toIso8601String(),
        loginCount: 1,
      );

      // 登录/注册成功
      setState(() {
        _step = 3;
        _isLoading = false;
      });

    } catch (e) {
      // 提取用户友好的错误信息
      String errorMessage = _parseErrorMessage(e.toString());

      setState(() {
        _isLoading = false;
        _errorMessage = errorMessage;
      });
    }
  }

  /// 解析错误信息，返回用户友好的提示
  String _parseErrorMessage(String error) {
    // 如果包含"验证码"，说明是验证码相关错误
    if (error.contains('验证码')) {
      if (error.contains('发送失败')) {
        return '验证码发送失败，请检查手机号是否正确';
      }
      if (error.contains('验证失败')) {
        return '验证码错误或已过期，请重新获取';
      }
      return '验证码错误，请重新输入';
    }

    // 如果包含"登录失败"
    if (error.contains('登录失败')) {
      return '登录失败，请稍后重试';
    }

    // 如果包含"注册失败"
    if (error.contains('注册失败')) {
      return '注册失败，请稍后重试';
    }

    // 如果包含"网络"
    if (error.contains('网络')) {
      return '网络连接失败，请检查网络设置';
    }

    // 默认错误信息
    return '操作失败，请稍后重试';
  }

  /// 重新发送验证码
  void _resendCode() {
    setState(() {
      _step = 1;
      _codeController.clear();
      _verificationId = null;
    });
  }

  /// 开始倒计时
  void _startCountdown() {
    setState(() => _countdown = 60);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _countdown--;
      });

      return _countdown > 0;
    });
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              primaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo 和标题
                  _buildHeader(),

                  const SizedBox(height: 60),

                  // 根据步骤显示不同内容
                  if (_step == 1) ..._buildStep1(),
                  if (_step == 2) ..._buildStep2(),
                  if (_step == 3) ..._buildStep3(),

                  // 错误提示
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 24),
                    _buildErrorCard(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 标题区域
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo 图标
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.family_restroom,
            size: 60,
            color: primaryColor,
          ),
        ),

        const SizedBox(height: 24),

        // 标题
        Text(
          '欢迎来到亲途',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'PingFang SC',
          ),
        ),

        const SizedBox(height: 12),

        // 副标题
        Text(
          '使用手机号验证码登录',
          style: TextStyle(
            fontSize: 18,
            color: lightTextColor,
            fontFamily: 'PingFang SC',
          ),
        ),
      ],
    );
  }

  /// 第 1 步：输入手机号
  List<Widget> _buildStep1() {
    return [
      // 手机号输入框
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          style: TextStyle(
            fontSize: 24,
            color: textColor,
            fontFamily: 'PingFang SC',
          ),
          decoration: InputDecoration(
            labelText: '手机号',
            labelStyle: TextStyle(
              color: primaryColor,
              fontSize: 20,
            ),
            hintText: '请输入 11 位手机号',
            hintStyle: TextStyle(
              color: lightTextColor,
              fontSize: 18,
            ),
            prefixText: '+86 ',
            prefixStyle: TextStyle(
              color: primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
        ),
      ),

      const SizedBox(height: 32),

      // 发送验证码按钮
      Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              Color(0xFFFF9F7F),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _sendCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  '获取验证码',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'PingFang SC',
                  ),
                ),
        ),
      ),
    ];
  }

  /// 第 2 步：输入验证码
  List<Widget> _buildStep2() {
    return [
      // 手机号显示
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.phone_android,
              color: primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              '验证码已发送至 ${_phoneController.text}',
              style: TextStyle(
                fontSize: 18,
                color: textColor,
                fontFamily: 'PingFang SC',
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      // 验证码输入框
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: TextStyle(
            fontSize: 32,
            color: textColor,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            labelText: '验证码',
            labelStyle: TextStyle(
              color: primaryColor,
              fontSize: 20,
            ),
            hintText: '请输入 6 位验证码',
            hintStyle: TextStyle(
              color: lightTextColor,
              fontSize: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
        ),
      ),

      const SizedBox(height: 16),

      // 重新发送按钮
      Row(
        children: [
          TextButton.icon(
            onPressed: _countdown > 0 ? null : _resendCode,
            icon: Icon(
              Icons.refresh,
              size: 20,
              color: _countdown > 0 ? lightTextColor : primaryColor,
            ),
            label: Text(
              _countdown > 0 ? '重新发送 ($_countdown 秒)' : '重新发送验证码',
              style: TextStyle(
                color: _countdown > 0 ? lightTextColor : primaryColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 24),

      // 登录按钮
      Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              Color(0xFFFF9F7F),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _verifyAndLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  '登录',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'PingFang SC',
                  ),
                ),
        ),
      ),
    ];
  }

  /// 第 3 步：登录成功
  List<Widget> _buildStep3() {
    return [
      // 成功图标
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: successColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          color: successColor,
          size: 64,
        ),
      ),

      const SizedBox(height: 24),

      // 成功文字
      Text(
        '登录成功！',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'PingFang SC',
        ),
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 40),

      // 用户信息卡片
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '用户信息',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'PingFang SC',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('手机号', _userInfo?.phoneNumber ?? '加载中...'),
          ],
        ),
      ),

      const SizedBox(height: 32),

      // 进入应用按钮
      Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              Color(0xFFFF9F7F),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // 跳转到角色选择页面
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => RoleSelectionPage(
                  userId: _userInfo?.uid ?? '',
                  accessToken: _authResult?.accessToken ?? '',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            '进入应用',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'PingFang SC',
            ),
          ),
        ),
      ),

      const SizedBox(height: 16),

      // 重新测试按钮
      TextButton(
        onPressed: () {
          setState(() {
            _step = 1;
            _phoneController.clear();
            _codeController.clear();
            _verificationId = null;
            _authResult = null;
            _userInfo = null;
          });
        },
        child: Text(
          '重新登录',
          style: TextStyle(
            color: lightTextColor,
            fontSize: 18,
          ),
        ),
      ),
    ];
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textColor,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: lightTextColor,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 错误提示卡片
  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: errorColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: errorColor,
                fontSize: 18,
                fontFamily: 'PingFang SC',
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