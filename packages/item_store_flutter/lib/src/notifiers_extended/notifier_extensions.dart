import 'package:flutter/foundation.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/notifiers_extended/readonly_value_notifier.dart';
import 'async_state.dart';
import 'state_notifier.dart';

extension NotifierRefX on Ref {
  R bindToNotifier<T, R extends StateNotifier<T>>(R notifier) {
    return registerDisposable(notifier..onDispose(disposeSelf));
  }
}

extension ValueNotifierX<T> on ValueNotifier<T> {
  ReadonlyValueNotifier<T> get readonly => this as ReadonlyValueNotifier<T>;
  StateNotifier toStateNotifier() {
    final stateNotifier = StateNotifier(value);
    final listener = () => stateNotifier.value = value;

    addListener(listener);
    stateNotifier.onDispose(() => removeListener(listener));

    return stateNotifier;
  }
}

extension AsyncStateX<T> on AsyncState<T> {
  R when<R>({
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object? error, StackTrace? stackTrace) error,
  }) {
    return switch (this) {
      AsyncLoading() => loading(),
      AsyncData(data: final state) => data(state),
      AsyncError(error: final e, stackTrace: final stack) => error(e, stack),
    };
  }
}
