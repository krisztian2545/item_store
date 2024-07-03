mixin DisposableMixin {
  final _disposeCallbacks = <void Function()>[];

  void onDispose(void Function() callback) => _disposeCallbacks.add(callback);

  void dispose() {
    for (final callback in _disposeCallbacks) {
      callback();
    }
  }
}
