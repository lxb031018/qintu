import 'package:flutter/material.dart';
import '../../../../constants/app_spacings.dart';
import '../../../../theme/app_text_styles.dart';
import 'empty_state_widget.dart';

/// ============================================
/// 绑定请求列表通用组件
///
/// 三个 tab（received / sent / rejected）共享的布局：
/// - 加载中：全屏 spinner
/// - 空数据：EmptyStateWidget（支持下拉刷新）
/// - 有数据：ListView.builder + 底部"30 天后自动清理"提示
///
/// item 类型由 [itemBuilder] 决定，保持泛型。
/// ============================================

/// 请求 30 天后自动清理的提示文案（与后端策略保持一致）
const String _kRequestAutoCleanupHint = '30 天后自动清理';

/// 滚动占位高度：让空状态也能触发下拉刷新
const double _kEmptyListPlaceholderHeight = 200;

class BindingRequestListView<T> extends StatelessWidget {
  /// 要展示的请求列表
  final List<T> requests;

  /// 是否正在加载
  final bool isLoading;

  /// 下拉刷新回调
  final Future<void> Function() onRefresh;

  /// 空状态图标
  final IconData emptyIcon;

  /// 空状态主文案
  final String emptyMessage;

  /// 列表项构造器
  final Widget Function(BuildContext context, T request) itemBuilder;

  const BindingRequestListView({
    super.key,
    required this.requests,
    required this.isLoading,
    required this.onRefresh,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: requests.isEmpty
          ? _buildEmptyList(context)
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacings.lg),
              itemCount: requests.length + 1,
              itemBuilder: (context, index) {
                if (index == requests.length) {
                  return _buildExpireHint(context);
                }
                return itemBuilder(context, requests[index]);
              },
            ),
    );
  }

  /// 空列表：必须包在可滚动组件里才能触发下拉刷新
  Widget _buildEmptyList(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - _kEmptyListPlaceholderHeight,
        child: Center(
          child: EmptyStateWidget(
            icon: emptyIcon,
            message: emptyMessage,
            subMessage: _kRequestAutoCleanupHint,
          ),
        ),
      ),
    );
  }

  /// 列表底部过期提示
  Widget _buildExpireHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacings.md),
      child: Text(
        _kRequestAutoCleanupHint,
        style: AppTextStyles.bottomTab.copyWith(
          color: Theme.of(context).hintColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
