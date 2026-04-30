/// 带重试执行异步请求。
///
/// 重试最多 [maxRetries] 次，使用线性退避：
/// 首次重试延迟 [baseDelay]，第二次延迟 2 * [baseDelay]，以此类推。
/// 所有尝试失败后抛出最后的异常。
Future<T> withRetry<T>(
  Future<T> Function() request, {
  int maxRetries = 2,
  Duration baseDelay = const Duration(milliseconds: 200),
  String errorMessage = 'Operation failed',
}) async {
  Exception? lastError;
  for (int attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await request();
    } catch (e) {
      lastError = e is Exception ? e : Exception(e.toString());
      if (attempt < maxRetries) {
        await Future.delayed(baseDelay * (attempt + 1));
      }
    }
  }
  throw lastError ?? Exception(errorMessage);
}
