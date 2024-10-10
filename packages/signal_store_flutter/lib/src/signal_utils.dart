import 'package:signal_store_flutter/signal_store_flutter.dart';

extension WidgetRefSignalUtilsExtensionX on WidgetRef {
  Signal<T> signal<T>(Object globalKey) =>
      this<Signal<T>>(((_) => lazySignal<T>()).p(), globalKey: globalKey);
}
