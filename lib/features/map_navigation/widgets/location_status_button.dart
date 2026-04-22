import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../../../providers/location_status_provider.dart';
import '../../../theme/app_text_styles.dart';

/// ============================================
/// 定位状态引导按钮
///
/// 纯 UI 组件，只负责根据状态显示按钮
/// 状态由 lib/providers/location_provider.dart 提供
///
/// 功能：
/// - 定位未开启时：显示橙色按钮，文本为"点击开启定位"
/// - 定位已开启时：显示绿色按钮
/// - 定位权限被拒绝时：显示黄色按钮
/// - 检测中：显示加载指示器
///
/// 注意：此组件不包含 Positioned，由父组件负责定位
/// ============================================

class LocationStatusButton extends ConsumerWidget {
  const LocationStatusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 订阅定位状态
    final status = ref.watch(locationProvider);
    // 获取 notifier 用于处理点击
    final notifier = ref.read(locationProvider.notifier);

    return _buildLocationStatusChip(
      context: context,
      status: status,
      onTap: status != LocationStatus.unknown
          ? () => notifier.requestPermission()
          : null,
    );
  }

  Widget _buildLocationStatusChip({
    required BuildContext context,
    required LocationStatus status,
    VoidCallback? onTap,
  }) {
    // 根据状态决定样式
    final styles = _getStatusStyles(status);

    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacings.md,
            vertical: AppSpacings.sm,
          ),
          decoration: BoxDecoration(
            color: styles.backgroundColor,
            borderRadius: const BorderRadius.all(AppRadii.medium),
            border: Border.all(
              color: styles.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackOpacity10,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContent(status, styles),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LocationStatus status, _StatusStyles styles) {
    // 加载中状态
    if (status == LocationStatus.unknown) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: styles.textColor,
            ),
          ),
          const SizedBox(width: AppSpacings.xs),
          Text(
            '检测定位状态...',
            style: AppTextStyles.captionSmall.copyWith(
              color: styles.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    // 正常状态
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(styles.icon, color: styles.textColor, size: 18),
        const SizedBox(width: AppSpacings.xs),
        Text(
          styles.text,
          style: AppTextStyles.captionSmall.copyWith(
            color: styles.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 获取状态对应的样式
  _StatusStyles _getStatusStyles(LocationStatus status) {
    switch (status) {
      case LocationStatus.enabled:
        return _StatusStyles(
          text: '定位已开启',
          icon: Icons.check_circle,
          backgroundColor: AppColors.successOpacity10,
          borderColor: AppColors.successColor.withValues(alpha: 0.3),
          textColor: AppColors.successColor,
        );
      case LocationStatus.disabled:
        return _StatusStyles(
          text: '点击开启定位',
          icon: Icons.location_off,
          backgroundColor: AppColors.primaryOpacity15,
          borderColor: AppColors.primaryColor.withValues(alpha: 0.3),
          textColor: AppColors.primaryColor,
        );
      case LocationStatus.denied:
        return _StatusStyles(
          text: '定位权限已拒绝',
          icon: Icons.security,
          backgroundColor: AppColors.warningColor.withValues(alpha: 0.15),
          borderColor: AppColors.warningColor.withValues(alpha: 0.3),
          textColor: AppColors.warningColor,
        );
      case LocationStatus.unknown:
        return _StatusStyles(
          text: '检测定位状态...',
          icon: Icons.location_searching,
          backgroundColor: AppColors.primaryOpacity15,
          borderColor: AppColors.primaryColor.withValues(alpha: 0.3),
          textColor: AppColors.primaryColor,
        );
    }
  }
}

/// 状态样式数据类
class _StatusStyles {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _StatusStyles({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
