import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
import '../../core/api/route_share_api.dart';

/// ============================================
/// 路由分享卡片
///
/// 显示来自好友的路线分享，提供取消和开始导航操作
/// ============================================
class RouteShareCard extends StatelessWidget {
  final PendingRouteShare share;
  final String? senderNickname;
  final VoidCallback? onCancel;
  final VoidCallback? onNavigate;

  const RouteShareCard({
    super.key,
    required this.share,
    this.senderNickname,
    this.onCancel,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(AppSpacings.smd),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildContent(),
          const Divider(height: 1),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final nickname = senderNickname ?? '好友';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.md,
      ),
      child: Text(
        '来自$nickname的路线分享',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.grey600,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('起点', share.originName, share.originAddress),
          const SizedBox(height: AppSpacings.sm),
          _buildInfoRow('终点', share.destName, share.destAddress),
          const SizedBox(height: AppSpacings.sm),
          _buildInfoRow('方式', _routeTypeName(share.routeType), null),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String name, String? address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey500,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey800,
                ),
              ),
              if (address != null && address.isNotEmpty)
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _routeTypeName(String type) {
    switch (type) {
      case 'driving':
        return '驾车';
      case 'walking':
        return '步行';
      case 'riding':
        return '骑行';
      case 'transit':
        return '公交';
      default:
        return '驾车';
    }
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grey500,
                side: const BorderSide(color: AppColors.grey300),
                padding: const EdgeInsets.symmetric(vertical: AppSpacings.md),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(AppRadii.small),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: AppSpacings.md),
          Expanded(
            child: ElevatedButton(
              onPressed: onNavigate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.whiteText,
                padding: const EdgeInsets.symmetric(vertical: AppSpacings.md),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(AppRadii.small),
                ),
              ),
              child: const Text('开始导航'),
            ),
          ),
        ],
      ),
    );
  }
}
