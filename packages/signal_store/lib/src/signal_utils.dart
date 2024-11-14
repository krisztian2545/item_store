import 'package:signal_store/signal_store.dart';

extension SignalUtilsX<T> on ReadonlySignal<T> {
  void Function() sub() => subscribe((_) {});
}
