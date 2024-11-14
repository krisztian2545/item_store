import 'package:signal_store_flutter/signal_store_flutter.dart';

extension WidgetRefSignalUtilsExtensionX on WidgetRef {
  Signal<T> signal<T>(Object globalKey) =>
      this<Signal<T>>(((_) => lazySignal<T>()).p(), globalKey: globalKey);

  ReadonlySignal<T> subToSignal<T>(ReadonlySignal<T> signal) {
    onDispose(signal.subscribe((_) {}));
    return signal;
  }
}

extension SignalUtilsX<T> on ReadonlySignal<T> {
  ReadonlySignal<T> subWithWidget(WidgetRef ref) {
    return ref.subToSignal(this);
  }
}
