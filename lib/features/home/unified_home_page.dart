import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/settings_manager.dart';
import 'tabs/route_planning_tab.dart';
import '../binding/binding_page.dart';
import '../settings/settings_page.dart';

/// 统一主页 - 所有用户使用相同的界面
/// 
/// 顶部 Tab Bar 架构（防止老人误触）：
/// - 路线规划：地图 + 起点终点输入 + 规划按钮
/// - 关系绑定：管理绑定关系
/// - 设置：应用设置、账号管理
/// 
/// 设计理念：
/// - 每个人都能看到所有功能，不再区分"发送者"和"接收者"
/// - 会用的年轻人自然使用所有功能
/// - 不会用的老人不接触看不懂的按钮即可
/// - 年轻人发来规划路线，一键接收就直接开始导航

class UnifiedHomePage extends StatefulWidget {
  final String userId;

  const UnifiedHomePage({
    super.key,
    required this.userId,
  });

  @override
  State<UnifiedHomePage> createState() => _UnifiedHomePageState();
}

class _UnifiedHomePageState extends State<UnifiedHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _pressedIndex = -1;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 切换到指定 Tab
  void _switchTo(int index) {
    _tabController.animateTo(index);
  }

  /// 处理 Tab 单击（显示提示）
  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _pressedIndex = index;
      _showHint = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _pressedIndex = -1);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  /// 自定义 Tab Bar（完全手写，避免 TabBar 内部单击冲突）
  Widget _buildTabBar(BuildContext context, bool isDark, bool doubleTapMode) {
    final tabs = [
      const {
        'icon': Icons.route,
        'label': AppStrings.tabRoutePlanning,
      },
      const {
        'icon': Icons.people_alt_outlined,
        'label': AppStrings.tabBindingRelation,
      },
      const {
        'icon': Icons.settings_outlined,
        'label': AppStrings.tabSettingsPage,
      },
    ];

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkDividerColor : AppColors.borderColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isSelected = _tabController.index == i;
              final tabColor = isSelected
                  ? AppColors.primaryColor
                  : isDark
                      ? AppColors.darkLightTextColor
                      : AppColors.lightTextColor;

              return Expanded(
                child: GestureDetector(
                  onTap: doubleTapMode
                      ? () => _onTabTap(i)
                      : () => _switchTo(i),
                  onDoubleTap: doubleTapMode ? () => _switchTo(i) : null,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: (isSelected && doubleTapMode) ? AppColors.primaryColor : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: AnimatedScale(
                      scale: _pressedIndex == i ? 0.88 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeInOut,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tabs[i]['icon'] as IconData,
                            size: 16,
                            color: tabColor,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            tabs[i]['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: tabColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;
    final settingsManager = Provider.of<SettingsManager>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: _buildTabBar(context, isDark, settingsManager.doubleTapToSwitchTab),
        ),
      ),
      body: Column(
        children: [
          // 提示文本（仅在双击模式下显示）
          if (settingsManager.doubleTapToSwitchTab)
            AnimatedOpacity(
              opacity: _showHint ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    '💡 双击顶部标签切换页面',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            ),
          // 内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                RoutePlanningTab(),
                BindingPage(),
                SettingsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
