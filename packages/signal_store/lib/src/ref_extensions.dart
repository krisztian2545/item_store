import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

extension SignalsRefUtilsX on Ref {
  void Function() disposableEffect(
    void Function() compute, {
    String? debugLabel,
    dynamic Function()? onDispose,
  }) {
    final cleanup = effect(
      compute,
      debugLabel: debugLabel,
      onDispose: onDispose,
    );

    this.onDispose(cleanup);

    return cleanup;
  }

  Signal<T> boundSignal<T>(
    T value, {
    String? debugLabel,
    bool autoDispose = true,
  }) =>
      Signal<T>(
        value,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
      )..bindTo(this);

  Computed<T> boundComputed<T>(
    T Function() fn, {
    String? debugLabel,
    bool autoDispose = true,
  }) =>
      Computed<T>(
        fn,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
      )..bindTo(this);
}
