import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/font_size_options.dart';

/// ============================================
/// 设置管理器
///
/// 管理用户设置（字体大小等）
/// 通过 Provider 进行依赖注入，不使用单例模式
/// ============================================

class SettingsManager extends ChangeNotifier {
  static const String _fontSizeKey = 'font_size_scale';

  /// 当前字体大小乘数
  double _fontSizeScale = FontSizeOption.standard.scale;

  /// 获取当前字体大小乘数
  double get fontSizeScale => _fontSizeScale;

  /// 获取当前字体大小选项
  FontSizeOption get currentFontSizeOption {
    return FontSizeOption.values.firstWhere(
      (option) => option.scale == _fontSizeScale,
      orElse: () => FontSizeOption.standard,
    );
  }

  /// 初始化设置
  Future<void> init() async {
    _fontSizeScale = await loadFontSizeScale();
    notifyListeners();
  }

  /// 加载字体大小设置
  static Future<double> loadFontSizeScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? FontSizeOption.standard.scale;
  }

  /// 设置字体大小
  Future<void> setFontSizeScale(double scale) async {
    if (_fontSizeScale == scale) return;

    _fontSizeScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, scale);

    notifyListeners();
  }

  /// 获取字体大小选项名称（用于显示）
  String getFontSizeLabel(double scale) {
    final option = FontSizeOption.values.firstWhere(
      (option) => option.scale == scale,
      orElse: () => FontSizeOption.standard,
    );
    return option.label;
  }
}
