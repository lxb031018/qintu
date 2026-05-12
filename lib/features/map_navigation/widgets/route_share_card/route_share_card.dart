import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
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
  final String senderNickname;
  final VoidCallback? onCancel;
  final VoidCallback? onNavigate;

  const RouteShareCard({
    super.key,
    required this.share,
    required this.senderNickname,
    this.onCancel,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.all(AppRadii.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity10,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.md,
      ),
      child: Text(
        '来自$senderNickname的路线分享',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.grey600,
        ),
      ),
    );
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

@Preview(name: '路由分享卡片', group: 'route_share')
Widget previewRouteShareCard() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacings.lg),
        child: RouteShareCard(
          share: PendingRouteShare(
            id: '1',
            senderOpenid: 'sender_123',
            receiverOpenid: 'receiver_456',
            originLat: 39.9042,
            originLng: 116.4074,
            originName: '起点',
            originAddress: '北京市朝阳区',
            destLat: 39.9142,
            destLng: 116.4174,
            destName: '终点',
            destAddress: '北京市海淀区',
            routeType: 'driving',
            createdAt: DateTime.now().toIso8601String(),
          ),
          senderNickname: '小明',
          onCancel: () {},
          onNavigate: () {},
        ),
      ),
    ),
  );
}
