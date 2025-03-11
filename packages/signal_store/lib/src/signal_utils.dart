import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

List<ReadonlySignal> _signalSubs(Ref ref) => [];

extension SignalUtilsX<T, S extends ReadonlySignal<T>> on S {
  void Function() sub() => subscribe((_) {});

  S subWith(Ref ref) {
    final subs = ref.local(_signalSubs.p());
    if (subs.contains(this)) return this;
    subs.add(this);
    final unsub = sub();
    ref.onDispose(unsub);
    return this;
  }
}
