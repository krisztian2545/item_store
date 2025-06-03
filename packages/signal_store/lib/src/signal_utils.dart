import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

List<ReadonlySignal> _signalSubs(Ref ref) => [];

extension SignalUtilsX<T, S extends ReadonlySignal<T>> on S {
  void Function() sub() => subscribe((_) {});

  S subWith(Ref ref) {
    final subs = ref.local(_signalSubs);
    if (subs.contains(this)) return this;
    subs.add(this);
    final unsub = sub();
    ref.onDispose(unsub);
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

    map.forEach(update);
  }

  void disposeValues() {
    for (final signal in store.values) {
      signal.dispose();
    }
    store.clear();
  }
}
