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
