import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

Map<ReadonlySignal, void Function()> _signalSubs(Ref ref) {
  // subscribed signals and subscribe cleanups
  final subs = <ReadonlySignal, void Function()>{};
  ref.onDispose(() {
    for (final unsub in subs.values) {
      unsub();
    }
  });
  return subs;
}

extension SignalUtilsX<T, S extends ReadonlySignal<T>> on S {
  void Function() sub() => subscribe((_) {});

  S subWith(Ref ref) {
    final subs = ref.local(_signalSubs);
    if (subs.keys.contains(this)) return this;
    subs[this] = sub();
    onDispose(() => subs.remove(this));
    return this;
  }
}

extension SharedAsyncSignalExtension<T> on AsyncSignal<T> {
  void setFutureValue(Future<T> newFutureValue) {
    setLoading();
    newFutureValue.then(setValue, onError: setError);
  }
}

class CachedFutureSignalContainer<T, Arg>
    extends SignalContainer<AsyncState<T>, Arg, FutureSignal<T>> {
  CachedFutureSignalContainer(super.create) : super(cache: true);

  CachedFutureSignalContainer.from(
    Future<T> Function(Arg) getData,
  ) : super(
          (arg) => FutureSignal<T>(
            autoDispose: true,
            () async => getData(arg),
          ),
          cache: true,
        );
}

extension SharedSignalContainerExtension<T, Arg,
    S extends ReadonlySignalMixin<T>> on SignalContainer<T, Arg, S> {
  void setSignalValues(Map<Arg, T> map, {bool putIfAbsent = true}) {
    void tryUpdateSignal(S maybeSignal, T value) {
      if (maybeSignal case final Signal signal) {
        signal.value = value;
      }
    }

    void Function(Arg, T) update;
    if (putIfAbsent) {
      update = (key, value) => tryUpdateSignal(call(key), value);
    } else {
      update = (key, value) {
        final maybeSignal = store[key];
        if (maybeSignal == null) return;
        tryUpdateSignal(maybeSignal, value);
      };
    }

    batch(() {
      map.forEach(update);
    });
  }

  void disposeValues() {
    batch(() {
      for (final signal in store.values) {
        signal.dispose();
      }
    });
    store.clear();
  }
}
