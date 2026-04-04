import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../binding/binding_page.dart';

/// 发送者端主页（底部导航栏）
///
/// 底部三 Tab 架构：
/// - Home Tab：路径规划、发送导航
/// - 绑定 Tab：管理绑定关系
/// - 设置 Tab：应用设置、账号管理
class SenderMainScreen extends StatefulWidget {
  const SenderMainScreen({super.key});

  @override
  State<SenderMainScreen> createState() => _SenderMainScreenState();
}

class _SenderMainScreenState extends State<SenderMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '主页',
          ),
          NavigationDestination(
            icon: Icon(Icons.link_outlined),
            selectedIcon: Icon(Icons.link),
            label: '绑定',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return const _HomeTab();
      case 1:
        return const BindingPage();  // 使用绑定管理页面
      case 2:
        return const _SettingsTab();
      default:
        return const _HomeTab();
    }
  }
}

/// Home Tab - 路径规划、发送导航
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.navigation,
              size: 80,
              color: AppColors.brandGreen,
            ),
            SizedBox(height: 24),
            Text(
              '主页 - 路径规划',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '选择接收者，规划路线并发送导航',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings Tab - 应用设置、账号管理
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings,
              size: 80,
              color: AppColors.brandGreen,
            ),
            SizedBox(height: 24),
            Text(
              '设置',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '通知设置、账号管理、帮助反馈',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
