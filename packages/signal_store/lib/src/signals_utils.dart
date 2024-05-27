import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

ItemFactory<Signal<T>> signalFactory<T>(
  T value, {
  String? debugLabel,
  bool autoDispose = false,
}) {
  return (Ref ref) => ref.registerDisposable(signal(
        value,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
      )..onDispose(() => ref.disposeSelf()));
}

ItemFactory<Signal<T>> signalFactoryBuilder<T>(
  T Function(Ref) builder, {
  String? debugLabel,
  bool autoDispose = false,
}) {
  return (Ref ref) => ref.registerDisposable(signal(
        builder(ref),
        debugLabel: debugLabel,
        autoDispose: autoDispose,
      )..onDispose(() => ref.disposeSelf()));
}

ItemFactory<Computed<T>> computedFactory<T>(
  T Function() Function(Ref) computeBuilder, {
  String? debugLabel,
  bool autoDispose = false,
}) =>
    (Ref ref) => ref.registerDisposable(computed(
          computeBuilder(ref),
          debugLabel: debugLabel,
          autoDispose: autoDispose,
        )..onDispose(() => ref.disposeSelf()));

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

      ref.onDispose((_) => cleanup());

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

    this.onDispose((_) => cleanup());

    return cleanup;
  }
}
