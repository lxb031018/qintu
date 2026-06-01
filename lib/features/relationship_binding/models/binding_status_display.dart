import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/binding/binding.dart';

/// ============================================
/// 绑定/请求状态显示工具
///
/// 集中管理 status 字符串到 UI 元素（颜色 / 图标）的映射，
/// 避免在多个 card widget 中重复实现相同的 switch 逻辑。
///
/// 文案来源：
/// - SentRequest.statusText（model 内已实现）
/// - Binding 卡片的 status 标签从 [BindingStatusText] 取得
/// ============================================

/// 颜色/图标助手
class BindingStatusDisplay {
  BindingStatusDisplay._();

  /// SentRequest 状态对应的颜色
  ///
  /// pending + 即将过期 → 警告色（橙）
  /// pending → 信息色（蓝）
  /// rejected → 错误色（红）
  /// expired → 中性灰
  /// active → 成功色（绿）
  static Color colorFor(SentRequest request) {
    if (request.isPending) {
      return request.isExpiringSoon ? AppColors.warningColor : AppColors.infoColor;
    }
    if (request.isRejected) return AppColors.errorColor;
    if (request.isExpired) return AppColors.disabledColor;
    if (request.isActive) return AppColors.successColor;
    return AppColors.disabledColor;
  }

  /// SentRequest 状态对应的图标
  static IconData iconFor(SentRequest request) {
    if (request.isPending) {
      return request.isExpiringSoon
          ? Icons.warning_amber_rounded
          : Icons.access_time;
    }
    if (request.isRejected) return Icons.close_outlined;
    if (request.isExpired) return Icons.timer_outlined;
    if (request.isActive) return Icons.check_circle_outlined;
    return Icons.help_outline;
  }

  /// Binding 列表卡片用的状态颜色（按 status 字符串）
  static Color colorForBindingStatus(String status) {
    switch (status) {
      case 'active':
        return AppColors.successColor;
      case 'pending':
        return AppColors.warningColor;
      case 'expired':
      case 'rejected':
        return AppColors.disabledColor;
      default:
        return AppColors.disabledColor;
    }
  }
}

/// Binding 状态文案
class BindingStatusText {
  BindingStatusText._();

  /// 展示给用户的简短状态标签
  static String labelFor(String status) {
    switch (status) {
      case 'active':
        return '已绑定';
      case 'pending':
        return '待确认';
      case 'expired':
        return '已过期';
      case 'rejected':
      case 'revoked':
        return '已解除';
      default:
        return '未知';
    }
  }
}
