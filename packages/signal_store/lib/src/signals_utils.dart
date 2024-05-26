import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

ItemFactory<Signal<T>> signalFactory<T>({
  T? value,
  T Function(Ref)? builder,
  String? debugLabel,
  bool autoDispose = false,
}) {
  assert(
    (value != null && builder == null) || (value == null && builder != null),
    "Either value or builder must be specified, but not both.",
  );
  return (Ref ref) => ref.registerDisposable(signal(
        builder?.call(ref) ?? value!,
        debugLabel: debugLabel,
        autoDispose: autoDispose,
      )..onDispose(() => ref.disposeSelf()));
}

ItemFactory<Computed<T>> computedFactory<T>(
  T Function() compute, {
  String? debugLabel,
  bool autoDispose = false,
}) =>
    (Ref ref) => ref.registerDisposable(computed(
          compute,
          debugLabel: debugLabel,
          autoDispose: autoDispose,
        )..onDispose(() => ref.disposeSelf()));

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
