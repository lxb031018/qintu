import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
import '../../core/api/route_share_api.dart';
import '../../models/route_option_model.dart';
import '../../provider/map_navigation/map_navigation_provider.dart';
import '../../provider/map_navigation/route_share_notifier.dart';

/// ============================================
/// 路由分享卡片
///
/// 显示来自好友的路线分享，提供取消和开始导航操作
/// ============================================
class RouteReceiveCard extends StatelessWidget {
  final PendingRouteShare share;
  final String? senderNickname;
  final VoidCallback? onCancel;
  final VoidCallback? onNavigate;

  const RouteReceiveCard({
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

  String _routeTypeName(String type) => RouteTypeCodec.labelFromApiString(type);

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

/// 弹出路线分享接收卡片
///
/// [share] 待展示的分享数据
/// 显示在屏幕顶部（通过 Stack + Positioned 覆盖默认 dialog 居中行为）
Future<void> showRouteShareDialog(
  BuildContext context, {
  required PendingRouteShare share,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Consumer(
        builder: (context, ref, _) {
          return Stack(
            children: [
              Positioned(
                top: MediaQuery.of(dialogContext).padding.top + AppSpacings.smd,
                left: AppSpacings.smd,
                right: AppSpacings.smd,
                child: RouteReceiveCard(
                  share: share,
                  senderNickname: share.senderNickname,
                  onNavigate: () {
                    Navigator.of(dialogContext).pop();
                    // 路线已在收到分享时自动选中，直接开始导航
                    ref.read(mapNavigationProvider.notifier).startNavigation();
                    ref.read(routeShareNotifierProvider.notifier).clearLatestShare();
                  },
                  onCancel: () {
                    Navigator.of(dialogContext).pop();
                    ref.read(routeShareNotifierProvider.notifier).clearLatestShare();
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
