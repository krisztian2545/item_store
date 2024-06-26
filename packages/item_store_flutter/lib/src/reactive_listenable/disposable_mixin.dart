import 'package:flutter/foundation.dart';

import 'change_observer.dart';

mixin DisposableMixin {
  final _disposeCallbacks = <VoidCallback>[];

  void onDispose(void Function() callback) => _disposeCallbacks.add(callback);

  void dispose() {
    for (final callback in _disposeCallbacks) {
      try {
        callback();
      } catch (e) {
        ReactiveListenableObserver.observer
            ?.onError(this, e, StackTrace.current);
      }
    }
  }
}
