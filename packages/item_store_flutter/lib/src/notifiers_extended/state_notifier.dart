import 'package:flutter/foundation.dart';

import 'async_state.dart';
import 'state_notifier_observer.dart';

typedef WatchFunction = T Function<T extends Listenable>(T listenable);

class StateNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  StateNotifier(this._value, {this.autoDispose = false, this.debugLabel}) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  static StateNotifierObserver? observer;

  final String? debugLabel;

  @override
  T get value => _value;
  T _value;
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    observer?.onChange(this);
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';

  final _dependencies = <Listenable, VoidCallback>{};

  final bool autoDispose;

  final _disposeCallbacks = <VoidCallback>[];

  L listen<L extends Listenable>(L dependency, VoidCallback callback) {
    if (!_dependencies.containsKey(dependency)) {
      final callbackWithObserver = () {
        try {
          callback();
        } catch (e) {
          observer?.onError(this, e, StackTrace.current);
        }
      };

      dependency.addListener(callbackWithObserver);
      _dependencies[dependency] = callbackWithObserver;
    }
    return dependency;
  }

  void _clearDependencies() {
    for (final MapEntry(key: dependency, value: callback)
        in _dependencies.entries) {
      dependency.removeListener(callback);
    }
    _dependencies.clear();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (hasListeners || !autoDispose) return;
    dispose();
  }

  void onDispose(void Function() callback) => _disposeCallbacks.add(callback);

  @override
  void dispose() {
    for (final callback in _disposeCallbacks) {
      try {
        callback();
      } catch (e) {
        observer?.onError(this, e, StackTrace.current);
      }
    }
    _clearDependencies();
    super.dispose();
  }
}

class Reactive<T> extends StateNotifier<T?> {
  Reactive(
    this._compute, {
    bool lazy = true,
    super.autoDispose,
  }) : super(null) {
    if (!lazy) {
      _computeAndCache();
    }
  }

  L _watch<L extends Listenable>(L dependency) {
    return listen(dependency, _handleDependencyChanged);
  }

  void _handleDependencyChanged() {
    _computeAndCache();
  }

  @override
  T get value => super.value ?? _computeAndCache();

  final T Function(WatchFunction) _compute;

  T _computeAndCache() {
    _clearDependencies();

    try {
      value = _compute(_watch);
    } catch (e) {
      StateNotifier.observer?.onError(this, e, StackTrace.current);
      rethrow;
    }

    return super.value!;
  }

  void invalidate() => value = null;

  void recompute() => _computeAndCache();
}

class AsyncReactive<T> extends StateNotifier<AsyncState<T>?> {
  AsyncReactive(
    this._compute, {
    bool lazy = true,
    super.autoDispose,
  }) : super(null) {
    if (!lazy) {
      _computeAndCache();
    }
  }

  L _watch<L extends Listenable>(L dependency) {
    return listen(dependency, _handleDependencyChanged);
  }

  void _handleDependencyChanged() {
    _computeAndCache();
  }

  @override
  AsyncState<T> get value => super.value ?? _computeAndCache();

  final Future<T> Function(WatchFunction) _compute;

  AsyncState<T> _computeAndCache() {
    value = AsyncLoading();
    _clearDependencies();

    _compute(_watch).then((data) => value = AsyncData(data)).catchError((err) {
      value = AsyncError(err, StackTrace.current);
    });

    return super.value!;
  }

  void invalidate() => value = null;

  void recompute() => _computeAndCache();
}
