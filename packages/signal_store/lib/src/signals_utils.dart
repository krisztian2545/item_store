import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

ItemFactory<Signal<T>> signalFactory<T>(
  T value, {
  String? debugLabel,
  bool autoDispose = false,
}) =>
    (Ref ref) => ref.bindToDisposable(
          signal(
            value,
            debugLabel: debugLabel,
            autoDispose: autoDispose,
          ),
        );

ItemFactory<Signal<T>> signalFactoryBuilder<T>(
  T Function(Ref) builder, {
  String? debugLabel,
  bool autoDispose = false,
}) =>
    (Ref ref) => ref.bindToDisposable(
          signal(
            builder(ref),
            debugLabel: debugLabel,
            autoDispose: autoDispose,
          ),
        );

ItemFactory<FutureSignal<T>> futureSignalFactory<T>(
  Future<T> asyncValue, {
  T? initialValue,
  String? debugLabel,
  List<ReadonlySignal<dynamic>> dependencies = const [],
  bool lazy = true,
  bool autoDispose = false,
}) =>
    (ref) => ref.bindToDisposable(
          futureSignal(
            () async => asyncValue,
            initialValue: initialValue,
            debugLabel: debugLabel,
            dependencies: dependencies,
            lazy: lazy,
            autoDispose: autoDispose,
          ),
        );

ItemFactory<FutureSignal<T>> futureSignalFactoryBuilder<T>(
  Future<T> Function() Function(Ref) callbackBuilder, {
  T? initialValue,
  String? debugLabel,
  List<ReadonlySignal<dynamic>> dependencies = const [],
  bool lazy = true,
  bool autoDispose = false,
}) =>
    (ref) => ref.bindToDisposable(
          futureSignal(
            callbackBuilder(ref),
            initialValue: initialValue,
            debugLabel: debugLabel,
            dependencies: dependencies,
            lazy: lazy,
            autoDispose: autoDispose,
          ),
        );

ItemFactory<Computed<T>> computedFactory<T>(
  T Function() Function(Ref) computeBuilder, {
  String? debugLabel,
  bool autoDispose = false,
}) =>
    (Ref ref) => ref.bindToDisposable(
          computed(
            computeBuilder(ref),
            debugLabel: debugLabel,
            autoDispose: autoDispose,
          ),
        );

ItemFactory<void Function()> effectFactory(
  void Function() Function(Ref) computeBuilder, {
  String? debugLabel,
  dynamic Function()? onDispose,
}) =>
    (Ref ref) {
      final cleanup = effect(
        computeBuilder(ref),
        debugLabel: debugLabel,
        onDispose: () {
          onDispose?.call();
          ref.disposeSelf();
        },
      );

      ref.onDispose(cleanup);

      return cleanup;
    };

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

  // void Function()
}
