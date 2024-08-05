import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

ItemFactory<Signal<T>> signalFactory<T>(
  T value, {
  String? debugLabel,
  bool autoDispose = false,
}) =>
    (Ref ref) => ref.bindTo(
          Signal<T>(
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
    (Ref ref) => ref.bindTo(
          Signal<T>(
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
    (ref) => ref.bindTo(
          FutureSignal<T>(
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
    (ref) => ref.bindTo(
          FutureSignal<T>(
            callbackBuilder(ref),
            initialValue: initialValue,
            debugLabel: debugLabel,
            dependencies: dependencies,
            lazy: lazy,
            autoDispose: autoDispose,
          ),
        );
