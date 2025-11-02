import 'package:flutter/widgets.dart';
import 'package:signal_store/signal_store.dart';
import 'package:signal_store_flutter/signal_store_flutter.dart';
import 'package:signals_flutter/signals_flutter.dart';

extension WidgetRefSignalUtilsExtensionX on WidgetRef {
  Signal<T> signal<T>(Object key) => this<Signal<T>>((_) => lazySignal<T>(), key: key);
}

extension FlutterSignalUtilsX<T, S extends ReadonlySignal<T>> on S {
  void Function() sub() => SignalUtilsX(this).sub();

  S subWith(Ref ref) => SignalUtilsX(this).subWith(ref);

  /// Also look at [SignalsRefUtilsX.cancelSignalDependency].
  S makeDependencyOf(Ref ref) {
    if (ref is WidgetRef) {
      ref.local(
        (_) {
          final cleanup = onDispose(() {
            // rebuild widget
            final element = ref.local.readValue<BuildContext>() as Element;
            if (!element.mounted) return;
            element.markNeedsBuild();
          });

          ref.onDispose(cleanup);
        },
        key: (signalDependency: this),
      );
      return this;
    }

    return SignalUtilsX(this).makeDependencyOf(ref);
  }
}
