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

  R bindToSignal<R extends ReadonlySignal<T>, T>(R signal) {
    signal.bindTo(this, dispose: (signal) {
      if (signal.disposed) return;
      signal.dispose();
    });
    return signal;
  }

  Signal<T> boundSignal<T>(
    T value, {
    String? debugLabel,
    bool autoDispose = true,
  }) =>
      bindToSignal(Signal<T>(
        value,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
      ));

  Computed<T> boundComputed<T>(
    T Function() fn, {
    String? debugLabel,
    bool autoDispose = true,
  }) =>
      bindToSignal(Computed<T>(
        fn,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
      ));

  FutureSignal<T> boundComputedAsync<T>(
    Future<T> Function() fn, {
    T? initialValue,
    String? debugLabel,
    bool autoDispose = true,
    List<ReadonlySignal<dynamic>> dependencies = const [],
    bool lazy = true,
  }) =>
      bindToSignal(FutureSignal<T>(
        fn,
        initialValue: initialValue,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
        dependencies: dependencies,
        lazy: lazy,
      ));

  void cancelSignalDependency(ReadonlySignal signal) {
    local.disposeItem((signalDependency: signal));
  }
}
