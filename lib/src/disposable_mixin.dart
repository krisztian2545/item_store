mixin DisposableMixin {
  final _disposeCallbacks = <void Function()>[];

  void onDispose(void Function() callback) => _disposeCallbacks.add(callback);

  void removeDisposeCallback(void Function() callback) {
    _disposeCallbacks.remove(callback);
  }

  void dispose() {
    for (final callback in _disposeCallbacks) {
      callback();
    }
  }
}

extension type ExposedDisposableMixin(DisposableMixin _disposableMixin)
    implements DisposableMixin {
  List<void Function()> get disposeCallbacks => List.from(
        _disposableMixin._disposeCallbacks,
        growable: false,
      );
}
