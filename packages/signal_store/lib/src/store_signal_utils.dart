import 'package:signal_store/signal_store.dart';

extension StoreSignalUtilsX on ItemStore {
  Signal<T> signal<T>(Object globalKey) =>
      get<Signal<T>>(((Ref _) => lazySignal<T>()).p(), globalKey: globalKey);
}

extension RefSignalUtilsX on Ref {
  Signal<T> signal<T>(Object globalKey) =>
      this<Signal<T>>(((_) => lazySignal<T>()).p(), globalKey: globalKey);
}
