import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import 'sender_home_content.dart';
import '../binding/binding_page.dart';
import '../settings/settings_page.dart';

/// 发送者端主页（底部导航栏）
///
/// 底部三 Tab 架构：
/// - Home Tab：路径规划、发送导航
/// - 绑定 Tab：管理绑定关系
/// - 设置 Tab：应用设置、账号管理

class SenderMainScreen extends StatefulWidget {
  final String userId;

  const SenderMainScreen({
    super.key,
    required this.userId,
  });

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
            label: AppStrings.tabHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.link_outlined),
            selectedIcon: Icon(Icons.link),
            label: AppStrings.tabBinding,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: AppStrings.tabSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        // Home Tab - 路径规划内容
        return SenderHomeContent(userId: widget.userId);
      case 1:
        // 绑定 Tab - 使用 Provider 包装
        return const _BindingTabWrapper();
      case 2:
        // 设置 Tab
        return const SettingsPage();
      default:
        return SenderHomeContent(userId: widget.userId);
    }
  }
}

/// 绑定 Tab 包装器（提供必要的 Provider）
class _BindingTabWrapper extends StatelessWidget {
  const _BindingTabWrapper();

  @override
  Widget build(BuildContext context) {
    // 这里需要提供 BindingProvider
    // AuthStateManager 在 main.dart 中已全局注册
    // 如果 Provider 已经在更高层级提供，可以直接使用 BindingPage
    return const BindingPage();
  }
}
