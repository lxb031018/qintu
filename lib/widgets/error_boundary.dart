import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/logger.dart';
import '../theme/app_text_styles.dart';

/// 全局错误边界组件
/// 
/// 捕获子组件树中的所有错误,并显示友好的错误页面
/// 防止应用因未处理的异常而白屏或崩溃
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? errorWidget;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorWidget,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  String _errorMessage = '';
  String _errorDetails = '';

  @override
  void initState() {
    super.initState();
    // 设置 Flutter 全局错误处理
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _handleError(details.exception.toString(), details.stack?.toString());
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 重置错误状态
    _hasError = false;
    _errorMessage = '';
    _errorDetails = '';
  }

  void _handleError(String message, String? stackTrace) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
        _errorDetails = stackTrace ?? '';
      });

      Logs.ui.error('ErrorBoundary 捕获错误: $_errorMessage');
      Logs.ui.error('错误堆栈: $_errorDetails');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? _buildDefaultErrorWidget();
    }
    return widget.child;
  }

  /// 构建默认错误页面
  Widget _buildDefaultErrorWidget() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.errorColor,
              ),
              const SizedBox(height: 24),
              const Text(
                '出现错误',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              if (_errorDetails.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorDetails,
                    style: AppTextStyles.errorDetail,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = '';
                    _errorDetails = '';
                  });
                },
                child: const Text('重试'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // 返回上一页
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('返回上一页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ErrorWidget 扩展,用于捕获构建错误
class SafeErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const SafeErrorWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    Logs.ui.error('SafeErrorWidget: ${details.exception}');
    Logs.ui.error('堆栈: ${details.stack}');

    return Container(
      color: AppColors.errorOpacity10,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: AppColors.errorColor),
          const SizedBox(height: 8),
          Text(
            '组件加载失败',
            style: TextStyle(
              color: AppColors.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details.exception.toString(),
            style: AppTextStyles.captionSmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
