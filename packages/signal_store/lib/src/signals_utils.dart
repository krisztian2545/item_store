import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

ItemFactory<Signal<T>> signalFactory<T>(
  T value, {
  String? debugLabel,
  bool autoDispose = false,
}) =>
    (Ref ref) => signal(
          value,
          debugLabel: debugLabel,
          autoDispose: autoDispose,
        )..onDispose(() => ref.disposeSelf());

ItemFactory<Computed<T>> computedFactory<T>(
  T Function() compute, {
  String? debugLabel,
  bool autoDispose = false,
}) =>
    (Ref ref) => computed(
          compute,
          debugLabel: debugLabel,
          autoDispose: autoDispose,
        )..onDispose(() => ref.disposeSelf());

ItemFactory<void Function()> effectFactory(
  void Function() compute, {
  String? debugLabel,
  dynamic Function()? onDispose,
}) =>
    (Ref ref) => effect(
          compute,
          debugLabel: debugLabel,
          onDispose: () {
            onDispose?.call();
            ref.disposeSelf();
          },
        );
