import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

ItemFactory<StreamSignal<T>> streamSignalFactory<T>(
  Stream<T> Function() Function(Ref) callbackBuilder, {
  T? initialValue,
  String? debugLabel,
  List<ReadonlySignal<dynamic>> dependencies = const [],
  void Function()? onDone,
  bool? cancelOnError,
  bool lazy = true,
  bool autoDispose = false,
}) =>
    (ref) => ref.bindTo(
          StreamSignal<T>(
            callbackBuilder(ref),
            initialValue: initialValue,
            debugLabel: debugLabel,
            dependencies: dependencies,
            onDone: onDone,
            cancelOnError: cancelOnError,
            lazy: lazy,
            autoDispose: autoDispose,
          ),
        );
