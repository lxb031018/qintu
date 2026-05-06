import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_spacings.dart';
import '../../models/poi_models.dart';

/// ============================================
/// 历史位置列表项组件
///
/// 带选择圆圈的历史位置项，支持：
/// - 点击：在选择模式下切换选中状态，否则选择位置
/// - 长按：进入多选模式
/// ============================================

class HistoryListItem extends StatelessWidget {
  final PoiSuggestion poi;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const HistoryListItem({
    super.key,
    required this.poi,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacings.sm,
          horizontal: AppSpacings.xs,
        ),
        child: Row(
          children: [
            // 选择圆圈 - 仅在选择模式下显示
            if (isSelectionMode)
              AnimatedOpacity(
                opacity: isSelectionMode ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : AppColors.grey400,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primaryColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            if (isSelectionMode) const SizedBox(width: AppSpacings.sm),
            // 图标
            const Icon(
              Icons.history,
              color: AppColors.grey600,
              size: 20,
            ),
            const SizedBox(width: AppSpacings.sm),
            // 文字信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (poi.address.isNotEmpty)
                    Text(
                      poi.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}