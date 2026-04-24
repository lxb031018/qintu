import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_durations.dart';
import '../../constants/app_strings.dart';
import '../../providers/settings_manager.dart';
import '../map_navigation/map_navigation_tab.dart';
import '../relationship_binding/relationship_binding_tab.dart';
import '../settings/settings_page.dart';

/// 应用主页面 - 三大业务模块的容器
///
/// 职责：
/// - 编排三个业务模块（地图导航、关系绑定、设置），不处理具体业务逻辑
/// - 管理顶部 Tab Bar 的 UI 和切换动画
/// - 创建并传递模块级控制器（如 [MapNavigationController]）
/// - 处理防误触模式下的单击/双击切换逻辑
///
/// 架构说明：
/// - 顶部 Tab Bar 架构，包含三个 Tab：地图导航、关系绑定、设置
/// - 每个 Tab 对应一个独立的功能模块，模块之间互不依赖
/// - 路线规划是地图导航的子模块，不作为独立 Tab
/// - 本文件只负责组装和切换，不感知模块内部实现
///
/// 设计理念：
/// - 每个人都能看到所有功能，不再区分"发送者"和"接收者"
/// - 会用的年轻人自然使用所有功能
/// - 不会用的老人不接触看不懂的按钮即可
/// - 年轻人发来规划路线，一键接收就直接开始导航

class UnifiedHomePage extends ConsumerStatefulWidget {
  /// 用户ID，用于初始化认证状态
  final String userId;

  /// 创建应用主页面
  ///
  /// [userId] 当前登录用户的唯一标识
  const UnifiedHomePage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UnifiedHomePage> createState() => _UnifiedHomePageState();
}

class _UnifiedHomePageState extends ConsumerState<UnifiedHomePage>
    with SingleTickerProviderStateMixin {
  /// Tab 控制器，管理三个 Tab 的切换动画
  late TabController _tabController;

  /// 当前被单击的 Tab 索引（用于按下动画）
  int _pressedIndex = -1;

  /// 是否显示双击提示文本
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

  /// 切换到指定 Tab（带动画）
  void _switchTo(int index) {
    _tabController.animateTo(index);
  }

  /// 处理防误触模式下的 Tab 单击事件
  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _pressedIndex = index;
      _showHint = true;
    });
    Future.delayed(AppDurations.fastAnimation, () {
      if (mounted) setState(() => _pressedIndex = -1);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHint = false);
    });

    if (index == 0) {
      _switchTo(index);
    }
  }

  /// 构建自定义 Tab Bar
  Widget _buildTabBar(BuildContext context, bool isDark, bool doubleTapMode) {
    final tabs = [
      const {
        'icon': Icons.map_outlined,
        'label': '地图导航',
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
                      duration: AppDurations.fastAnimation,
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
    final settingsState = ref.watch(settingsManagerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: _buildTabBar(context, isDark, settingsState.doubleTapToSwitchTab),
        ),
      ),
      body: Column(
        children: [
          // 防误触提示文本
          if (settingsState.doubleTapToSwitchTab)
            AnimatedOpacity(
              opacity: _showHint ? 1.0 : 0.0,
              duration: AppDurations.fastAnimation,
              child: AnimatedSize(
                duration: AppDurations.fastAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    AppStrings.doubleTapSettingsHint,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                MapNavigationTab(),
                RelationshipBindingTab(),
                SettingsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
