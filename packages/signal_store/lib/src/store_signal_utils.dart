import 'package:signal_store/signal_store.dart';
import 'package:signals_core/signals_core.dart';

extension StoreSignalUtilsX on ItemStore {
  Signal<T> signal<T>(Object globalKey) =>
      get<Signal<T>>((Ref _) => lazySignal<T>(), globalKey: globalKey);
}

extension RefSignalUtilsX on Ref {
  Signal<T> signal<T>(Object globalKey) =>
      this<Signal<T>>((_) => lazySignal<T>(), globalKey: globalKey);
}
