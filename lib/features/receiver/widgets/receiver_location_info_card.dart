import 'package:flutter/material.dart';
import 'package:x_amap_base/x_amap_base.dart';
import '../../../constants/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// 位置信息卡片 - 显示当前位置的经纬度信息

class ReceiverLocationInfoCard extends StatelessWidget {
  /// 当前位置
  final LatLng currentPosition;

  /// 定位到当前位置的回调
  final VoidCallback? onLocateMe;

  const ReceiverLocationInfoCard({
    super.key,
    required this.currentPosition,
    this.onLocateMe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.my_location,
              color: AppColors.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前位置',
                    style: AppTextStyles.locationTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '纬度: ${currentPosition.latitude.toStringAsFixed(6)}',
                    style: AppTextStyles.locationDetail,
                  ),
                  Text(
                    '经度: ${currentPosition.longitude.toStringAsFixed(6)}',
                    style: AppTextStyles.locationDetail,
                  ),
                ],
              ),
            ),
            // 定位到当前位置按钮
            IconButton(
              icon: Icon(
                Icons.my_location,
                color: AppColors.primaryColor,
              ),
              onPressed: onLocateMe,
              tooltip: '定位到当前位置',
            ),
          ],
        ),
      ),
    );
  }
}
