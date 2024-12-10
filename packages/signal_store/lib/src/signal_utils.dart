import 'package:signals_core/signals_core.dart';

extension SignalUtilsX<T> on ReadonlySignal<T> {
  void Function() sub() => subscribe((_) {});
}
