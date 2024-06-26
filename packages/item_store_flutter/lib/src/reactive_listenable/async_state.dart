sealed class AsyncState<T> {}

final class AsyncLoading<T> extends AsyncState<T> {}

final class AsyncData<T> extends AsyncState<T> {
  AsyncData(this.data);
  final T data;
}

final class AsyncError<T> extends AsyncState<T> {
  AsyncError([this.error, this.stackTrace]);
  final Object? error;
  final StackTrace? stackTrace;
}

extension AsyncStateX<T> on AsyncState<T> {
  /// Calls the appropriate callback based on the state of the [AsyncState].
  ///
  /// The [loading] callback is called when the state is [AsyncLoading].
  /// The [data] callback is called when the state is [AsyncData] and contains the data.
  /// The [error] callback is called when the state is [AsyncError] and contains the error and stack trace.
  ///
  /// Returns the result of the called callback.
  R when<R>({
    required R Function() loading, // Callback for [AsyncLoading] state.
    required R Function(T data) data, // Callback for [AsyncData] state.
    required R Function(Object? error, StackTrace? stackTrace)
        error, // Callback for [AsyncError] state.
  }) =>
      switch (this) {
        AsyncLoading() => loading(),
        AsyncData(data: final state) => data(state),
        AsyncError(error: final e, stackTrace: final stack) => error(e, stack),
      };
}
