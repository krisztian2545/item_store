import 'package:flutter/widgets.dart';
import 'package:signal_store_flutter/signal_store_flutter.dart';
import 'package:signals_flutter/signals_flutter.dart';

extension WidgetRefSignalUtilsExtensionX on WidgetRef {
  Signal<T> signal<T>(Object key) => this<Signal<T>>((_) => lazySignal<T>(), key: key);

  // ReadonlySignal<T> subToSignal<T>(ReadonlySignal<T> signal) {
  //   callOnce(signal.sub, tag: (subToSignal, signal));
  //   return signal;
  // }
}

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

extension FlutterSignalUtilsX<T, S extends ReadonlySignal<T>> on S {
  void Function() sub() => subscribe((_) {});

  S subWith(Ref ref) {
    final subs = ref.local(_signalSubs);
    if (subs.keys.contains(this)) return this;
    subs[this] = sub();
    onDispose(() => subs.remove(this));
    return this;
  }

  /// Also look at [SignalsRefUtilsX.cancelSignalDependency].
  S makeDependencyOf(Ref ref) {
    ref.local(
      (_) {
        late final void Function() rebuild;
        if (ref is WidgetRef) {
          final element = ref.local.readValue<BuildContext>() as Element;
          rebuild = element.markNeedsBuild;
        } else {
          rebuild = ref.disposeSelf;
        }

        final cleanup = onDispose(rebuild);
        ref.onDispose(cleanup);
        return cleanup;
      },
      key: (signalDependency: this),
    );
    return this;
  }
}

// extension FlutterSignalUtilsX<T> on ReadonlySignal<T> {
//   ReadonlySignal<T> subWithWidget(WidgetRef ref) {
//     return ref.subToSignal(this);
//   }
// }
