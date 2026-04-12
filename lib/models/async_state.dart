import 'package:freezed_annotation/freezed_annotation.dart';

part 'async_state.freezed.dart';

/// 异步状态（Freezed Union）
///
/// 统一表示异步操作的四种状态：
/// - initial: 初始状态
/// - loading: 加载中
/// - success: 成功
/// - error: 错误
///
/// 使用 sealed class 确保状态完整性，
/// 编译时检查所有分支是否处理
@freezed
sealed class AsyncState<T> with _$AsyncState<T> {
  const factory AsyncState.initial() = AsyncInitial<T>;
  const factory AsyncState.loading({T? previousData}) = AsyncLoading<T>;
  const factory AsyncState.success(T data) = AsyncSuccess<T>;
  const factory AsyncState.error(String message, [Object? exception, StackTrace? stackTrace]) = AsyncError<T>;

  const AsyncState._();

  /// 是否为初始状态
  bool get isInitial => maybeWhen(initial: () => true, orElse: () => false);

  /// 是否为加载状态
  bool get isLoading => maybeWhen(loading: (previousData) => true, orElse: () => false);

  /// 是否为成功状态
  bool get isSuccess => maybeWhen(success: (data) => true, orElse: () => false);

  /// 是否为错误状态
  bool get isError => maybeWhen(error: (message, exception, stackTrace) => true, orElse: () => false);

  /// 获取数据（仅成功时有效）
  T? get data => maybeWhen(success: (data) => data, orElse: () => null);

  /// 获取错误信息（仅错误时有效）
  String? get errorMessage => maybeWhen(error: (message, exception, stackTrace) => message, orElse: () => null);
}
