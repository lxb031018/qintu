import 'package:flutter/material.dart';

/// ============================================
/// 角色选择页面
///
/// 用户登录后选择身份：长辈 或 晚辈
/// 设计风格：柔和粉彩风格，大字体，适合老年人
/// ============================================

class RoleSelectionPage extends StatefulWidget {
  final String userId;
  final String accessToken;

  const RoleSelectionPage({
    super.key,
    required this.userId,
    required this.accessToken,
  });

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  // ==================== 状态变量 ====================

  /// 是否正在保存
  bool _isLoading = false;

  // ==================== 核心方法 ====================

  /// 选择角色
  Future<void> _selectRole(String role) async {
    setState(() => _isLoading = true);

    try {
      // TODO: 将角色信息保存到服务器
      // await saveUserRole(widget.userId, role, widget.accessToken);

      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));

      // 跳转到对应的主页面
      if (role == 'elder') {
        // TODO: 跳转到长辈端主页
        _showSuccessDialog('长辈端');
      } else {
        // TODO: 跳转到晚辈端主页
        _showSuccessDialog('晚辈端');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  /// 显示成功对话框
  void _showSuccessDialog(String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('角色设置成功'),
        content: Text('您已选择$role，即将进入主页'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _isLoading = false);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示错误对话框
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置失败'),
        content: Text('保存角色信息失败，请重试\n错误：$error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 奶油白背景
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // 标题区域
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '欢迎使用亲途',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A5568),
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '选择后可以在设置中更改',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xFF4A5568).withOpacity(0.6),
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // 角色选择按钮
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 我是长辈按钮
                    _buildRoleButton(
                      role: 'elder',
                      title: '我是长辈',
                      subtitle: '接受子女的导航帮助',
                      icon: Icons.elderly,
                      color: const Color(0xFFFF8C69), // 珊瑚橙
                    ),

                    const SizedBox(height: 40),

                    // 我是晚辈按钮
                    _buildRoleButton(
                      role: 'junior',
                      title: '我是晚辈',
                      subtitle: '为长辈规划导航路线',
                      icon: Icons.family_restroom,
                      color: const Color(0xFF87CEEB), // 天空蓝
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

  /// 构建角色选择按钮
  Widget _buildRoleButton({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => _selectRole(role),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                // 图标
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: color,
                  ),
                ),

                const SizedBox(width: 24),

                // 文字
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A5568),
                          fontFamily: 'PingFang SC',
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 副标题
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFF4A5568).withOpacity(0.6),
                          fontFamily: 'PingFang SC',
                        ),
                      ),
                    ],
                  ),
                ),

                // 箭头图标
                if (!_isLoading)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 28,
                    color: color,
                  ),

                // 加载指示器
                if (_isLoading)
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}