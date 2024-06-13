import 'package:flutter/foundation.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/notifiers_extended/notifier_extensions.dart';

import 'async_state.dart';

typedef WatchFunction = T Function<T extends Listenable>(T listenable);

class StateNotifier<T> extends ValueNotifier<T> {
  StateNotifier(super.value, {this.autoDispose = false});

  final _dependencies = <Listenable, VoidCallback>{};

  final bool autoDispose;

  final _disposeCallbacks = <VoidCallback>[];

  L listen<L extends Listenable>(L dependency, VoidCallback callback) {
    if (!_dependencies.containsKey(dependency)) {
      dependency.addListener(callback);
      _dependencies[dependency] = callback;
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
      callback();
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

    value = _compute(_watch);

    return value!;
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

// --------------------------------------------

class Counter extends StateNotifier {
  Counter(ValueNotifier jumpTo) : super(0) {
    listen(jumpTo, () => value = jumpTo.value);
  }
}

T Function(Ref) dof<T>(T Function(Ref) objectFactory) {
  return (ref) {
    final o = objectFactory(ref);
    try {
      // dispose object when being removed from the store
      final callback = (o as dynamic).dispose as void Function();
      ref.onDispose(callback);

      // dispose item from the store, when object gets disposed
      (o as dynamic).onDispose(ref.disposeSelf);
    } catch (e) {
      // disposable doesn't have a void dispose() function
      // or doesn't accept an onDispose callback.
    }

    return o;
  };
}

class CountDoubled extends StateNotifier<int> {
  CountDoubled(ValueNotifier count)
      : super(
          count.value * 2,
          autoDispose: true,
        ) {
    listen(count, () => value = count.value * 2);
  }
}

final counter = (Ref ref) {
  final count = ref.bindToNotifier(StateNotifier(0));
  return (
    count.readonly,
    increment: () => count.value++,
  );
};

(T Function(), void Function(T)) createState<T>(T initialValue) {
  T state = initialValue;
  return (() => state, (newState) => state = newState);
}

(T Function(), void Function(T)) Function(Ref) createStateFactory<T>(
    T initialValue) {
  return (_) => createState(initialValue);
}

T? Function(Ref) previousValueFactory<T>(T current) {
  return (ref) {
    final (getPrevious, setPrevious) =
        ref.local.get(createStateFactory<T?>(null));
    final previous = getPrevious();
    setPrevious(current);

    return previous;
  };
}

AsyncReactive<int> countDouble(Ref ref) {
  int? previous;
  final (getSome, setSome) = createState(0);
  return ref.bindToNotifier(AsyncReactive((watch) async {
    final prev = ref.local.get(previousValue<int?>());

    final count = watch(ref(counter).$1);
    final countDoubled = count.value * 2;
    print('$previous > $countDoubled');
    previous = countDoubled;
    return countDoubled;
  }));
}
