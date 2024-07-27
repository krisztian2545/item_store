import 'package:item_store/item_store.dart';
import 'package:signals_core/signals_core.dart';

ItemFactory<Computed<T>> computedFactory<T>(
  T Function() Function(Ref) computeBuilder, {
  String? debugLabel,
  bool autoDispose = false,
}) =>
    (Ref ref) => ref.bindToDisposable(
          Computed<T>(
            computeBuilder(ref),
            debugLabel: debugLabel,
            autoDispose: autoDispose,
          ),
        );

ItemFactory<FutureSignal<T>> computedAsyncFactory<T>(
  Future<T> Function() Function(Ref) callbackBuilder, {
  T? initialValue,
  String? debugLabel,
  List<ReadonlySignal<dynamic>> dependencies = const [],
  bool lazy = true,
  bool autoDispose = false,
}) =>
    (ref) => ref.bindToDisposable(
          FutureSignal<T>(
            callbackBuilder(ref),
            initialValue: initialValue,
            debugLabel: debugLabel,
            dependencies: dependencies,
            lazy: lazy,
            autoDispose: autoDispose,
          ),
        );

ItemFactory<FutureSignal<T>> computedFromFactory<T, A>(
  Future<T> Function(List<A>) Function(Ref) callbackBuilder,
  List<ReadonlySignal<A>> signals, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  bool lazy = true,
}) =>
    (ref) => ref.bindToDisposable(
          computedFrom<T, A>(
            signals,
            callbackBuilder(ref),
            initialValue: initialValue,
            debugLabel: debugLabel,
            autoDispose: autoDispose,
            lazy: lazy,
          ),
        );
