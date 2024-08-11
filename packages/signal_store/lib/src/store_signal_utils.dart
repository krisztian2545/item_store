import 'package:signal_store/signal_store.dart';

extension StoreSignalUtilsX on ItemStore {
  Signal<T> signal<T>(Object globalKey) =>
      get((_) => lazySignal<T>(), globalKey: globalKey);
}

extension RefSignalUtilsX on Ref {
  Signal<T> signal<T>(Object globalKey) =>
      this((_) => lazySignal<T>(), globalKey: globalKey);
}
