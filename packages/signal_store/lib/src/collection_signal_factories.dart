import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

ItemFactory<ChangeStackSignal<T>> changeStackFactory<T>(
  T Function(Ref) valueBuilder, {
  String? debugLabel,
  int? limit,
  bool autoDispose = false,
}) =>
    (ref) => ref.bindTo(
          ChangeStackSignal<T>(
            valueBuilder(ref),
            debugLabel: debugLabel,
            limit: limit,
            autoDispose: autoDispose,
          ),
        );
