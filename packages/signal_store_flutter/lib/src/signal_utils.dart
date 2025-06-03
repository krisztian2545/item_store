import 'package:signal_store_flutter/signal_store_flutter.dart';
import 'package:signals_flutter/signals_flutter.dart';

extension WidgetRefSignalUtilsExtensionX on WidgetRef {
  Signal<T> signal<T>(Object key) =>
      this<Signal<T>>((_) => lazySignal<T>(), key: key);

  ReadonlySignal<T> subToSignal<T>(ReadonlySignal<T> signal) {
    callOnce(signal.sub, tag: (subToSignal, signal));
    return signal;
  }
}

extension FlutterSignalUtilsX<T> on ReadonlySignal<T> {
  ReadonlySignal<T> subWithWidget(WidgetRef ref) {
    return ref.subToSignal(this);
  }
}
