import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

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
