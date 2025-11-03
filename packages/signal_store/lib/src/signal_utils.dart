import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';
import 'ref_extensions.dart';

Map<ReadonlySignal, void Function()> _signalSubCleanups(Ref ref) {
  // subscribed signals and subscribe cleanups
  final cleanups = <ReadonlySignal, void Function()>{};
  ref.onDispose(() {
    for (final cleanup in cleanups.values) {
      cleanup();
    }
    cleanups.clear();
  });
  return cleanups;
}

extension SignalUtilsX<T, S extends ReadonlySignal<T>> on S {
  void Function() sub() => subscribe((_) {});

  S subWith(Ref ref) {
    final signalSubCleanupsOfRef = ref.local(_signalSubCleanups);
    if (signalSubCleanupsOfRef.keys.contains(this)) return this;

    final forgetSignalTiesToRefSub = onDispose(() {
      // tell ref to forget this signal sub
      signalSubCleanupsOfRef
          .remove(this)
          // dispose effect
          ?.call();
    });

    final cleanupSub = sub();

    // on disposal of ref, cleanup effect and remove the signal's onDispose callback
    signalSubCleanupsOfRef[this] = () {
      cleanupSub();
      forgetSignalTiesToRefSub();
    };

    return this;
  }

  /// Also look at [SignalsRefUtilsX.cancelSignalDependency].
  S makeDependencyOf(Ref ref) {
    ref.local(
      (_) {
        bool disposing = false;
        late final void Function() cleanup;
        cleanup = onDispose(() {
          if (disposing) return;
          disposing = true;
          if (ref.itemMetaData.disposed) return;
          // prevent removal of this callback during execution
          ref.removeDisposeCallback(cleanup);
          // dispose item
          ref.disposeSelf();
        });

        // make signal forget this ref
        ref.onDispose(() {
          if (disposing) return;
          disposing = true;
          cleanup();
        });
      },
      key: (signalDependency: this),
    );
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

extension SharedSignalContainerExtension<T, Arg, S extends ReadonlySignal<T>>
    on SignalContainer<T, Arg, S> {
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
