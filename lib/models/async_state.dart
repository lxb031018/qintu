/// 异步状态（Sealed Class）
///
/// 统一表示异步操作的四种状态：
/// - initial: 初始状态
/// - loading: 加载中
/// - success: 成功
/// - error: 错误
///
/// 使用 sealed class 确保状态完整性，
/// 编译时检查所有分支是否处理
sealed class AsyncState<T> {
  const AsyncState();

  /// 是否为初始状态
  bool get isInitial => this is AsyncInitial<T>;

  /// 是否为加载状态
  bool get isLoading => this is AsyncLoading<T>;

  /// 是否为成功状态
  bool get isSuccess => this is AsyncSuccess<T>;

  /// 是否为错误状态
  bool get isError => this is AsyncError<T>;

  /// 获取数据（仅成功时有效）
  T? get data {
    if (this is AsyncSuccess<T>) {
      return (this as AsyncSuccess<T>).data;
    }
    return null;
  }

  /// 获取错误信息（仅错误时有效）
  String? get errorMessage {
    if (this is AsyncError<T>) {
      return (this as AsyncError<T>).message;
    }
    return null;
  }
}

/// 初始状态
class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial();
}

/// 加载状态
class AsyncLoading<T> extends AsyncState<T> {
  /// 之前的数据（用于刷新时显示）
  final T? previousData;

  const AsyncLoading([this.previousData]);
}

/// 成功状态
class AsyncSuccess<T> extends AsyncState<T> {
  @override
  final T data;

  const AsyncSuccess(this.data);
}

/// 错误状态
class AsyncError<T> extends AsyncState<T> {
  final String message;
  final Object? exception;
  final StackTrace? stackTrace;

  const AsyncError(this.message, [this.exception, this.stackTrace]);
}
