import 'package:flutter/widgets.dart';

/// 获取键盘高度
double getKeyboardHeight(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom;
}
