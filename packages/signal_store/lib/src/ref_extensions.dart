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

  FutureSignal<T> boundComputedAsync<T>(
    Future<T> Function() fn, {
    T? initialValue,
    String? debugLabel,
    bool autoDispose = true,
    List<ReadonlySignal<dynamic>> dependencies = const [],
    bool lazy = true,
  }) =>
      FutureSignal<T>(
        fn,
        initialValue: initialValue,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
        dependencies: dependencies,
        lazy: lazy,
      )..bindTo(this);

  void cancelSignalDependency(ReadonlySignal signal) {
    local.disposeItem((signalDependency: signal));
  }
}
