import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 登录页面
/// 
/// 支持手机号 + 验证码登录
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _canSendCode = true;
  int _countdown = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    if (_phoneController.text.isEmpty) {
      _showError('请输入手机号');
      return;
    }

    setState(() {
      _canSendCode = false;
      _countdown = 60;
    });

    // TODO: 调用 API 发送验证码
    // await apiService.sendSmsCode(_phoneController.text);

    _showSuccess('验证码已发送');

    // 倒计时
    while (_countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
      }
    }

    if (mounted) {
      setState(() {
        _canSendCode = true;
      });
    }
  }

  /// 登录
  Future<void> _login() async {
    if (_phoneController.text.isEmpty) {
      _showError('请输入手机号');
      return;
    }

    if (_codeController.text.isEmpty) {
      _showError('请输入验证码');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 调用登录 API
      // final response = await apiService.login(
      //   phone: _phoneController.text,
      //   code: _codeController.text,
      // );
      
      // 模拟登录
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _showSuccess('登录成功');
        // TODO: 跳转到主页
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (_) => const MainScreen()),
        // );
      }
    } catch (e) {
      _showError('登录失败：$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo 和标题
              const Icon(
                Icons.navigation,
                size: 80,
                color: AppColors.brandGreen,
              ),
              const SizedBox(height: 16),
              const Text(
                '亲途',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '远程代操作，让导航更简单',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              // 手机号输入
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入手机号',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 验证码输入
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: '验证码',
                        hintText: '请输入验证码',
                        prefixIcon: Icon(Icons.security),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: _canSendCode ? _sendCode : null,
                      child: Text(
                        _canSendCode ? '发送验证码' : '$_countdown 秒',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 登录按钮
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '登录',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(height: 24),

              // 角色选择提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 提示',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '登录后可选择作为发送者或接收者，也可两者皆可。',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
