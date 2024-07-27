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
}
