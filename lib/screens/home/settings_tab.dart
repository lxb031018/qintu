import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/secure_storage.dart';
import '../../utils/logger.dart';
import '../../features/auth/auth_page.dart';

/// 设置 Tab
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 用户信息
        const _UserProfile(),
        const Divider(),

        // 账号设置
        const _SectionTitle(title: '账号设置'),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('个人资料'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 跳转到个人资料页面
          },
        ),
        ListTile(
          leading: const Icon(Icons.link),
          title: const Text('绑定管理'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 跳转到绑定 Tab
          },
        ),
        const Divider(),

        // 通知设置
        const _SectionTitle(title: '通知设置'),
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('接收新任务通知'),
          value: true,
          onChanged: (value) {
            // TODO: 保存设置
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.location_on),
          title: const Text('位置共享通知'),
          value: true,
          onChanged: (value) {
            // TODO: 保存设置
          },
        ),
        const Divider(),

        // 隐私与安全
        const _SectionTitle(title: '隐私与安全'),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('隐私政策'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 显示隐私政策
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('关于我们'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: '亲途',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(
                Icons.navigation,
                size: 48,
                color: AppColors.brandGreen,
              ),
              children: [
                const Text(
                  '亲途是一款解决老年群体"导航难"痛点的移动应用。\n'
                  '通过"远程代操作"模式，将复杂的路径规划、路线修改等操作转移给发送者，\n'
                  '接收者仅需"一键接受"即可享受导航服务。',
                ),
              ],
            );
          },
        ),
        const Divider(),

        // 退出登录
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              '退出登录',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // 清除本地登录状态
                await SecureStorage.clearTokens();
                Logs.auth.info('🔓 已清除登录状态');
                
                // 跳转到登录页
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthPage()),
                    (route) => false, // 清除所有路由
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('退出登录'),
            ),
          ],
        );
      },
    );
  }
}

/// 用户资料卡片
class _UserProfile extends StatelessWidget {
  const _UserProfile();

  @override
  Widget build(BuildContext context) {
    // TODO: 从 Provider 获取用户信息
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: const CircleAvatar(
        radius: 30,
        backgroundColor: AppColors.brandGreen,
        child: Icon(
          Icons.person,
          size: 36,
          color: Colors.white,
        ),
      ),
      title: const Text(
        '张三',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(
        '+86 138****8000',
        style: TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: 跳转到个人资料页面
      },
    );
  }
}

/// 区域标题
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
